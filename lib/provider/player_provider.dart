import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:just_audio/just_audio.dart';
// ignore: depend_on_referenced_packages Just for Types. Doesn't matter
import 'package:rxdart/rxdart.dart' show BehaviorSubject;
import 'package:tubesync/model/common.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/model/playlist.dart';
import 'package:tubesync/model/preferences.dart';
import 'package:tubesync/provider/playlist_provider.dart';
import 'package:tubesync/services/media_service.dart';

class PlayerProvider extends ChangeNotifier {
  final player = AudioPlayer();
  final Isar isar;

  // Passing shouldRebuild => true is probably better that reconstructing list
  final List<Playlist> playlistInfo = List.empty(growable: true);
  final List<Media> playlist = List.empty(growable: true);

  late ValueNotifier<Media> _nowPlaying;

  //TODO Use Selector
  ValueNotifier<Media> get nowPlaying => _nowPlaying;

  // Buffering state because we fetch Uri on demand
  final ValueNotifier<bool> buffering = ValueNotifier(false);

  // We can't use the default player one because nextTrack isn't called
  // I don't want to migrate to just_audio dependent queue system
  final ValueNotifier<LoopMode> loopMode = ValueNotifier(LoopMode.all);

  PlayerProvider(this.isar, PlaylistProvider provider, {Media? start}) {
    playlistInfo.add(provider.playlist);
    playlist.addAll(provider.medias);
    _nowPlaying = ValueNotifier(start ?? playlist.first);
    nowPlaying.addListener(beginPlay);

    MediaService().bind(
      player: player,
      nextTrackCallback: nextTrack,
      previousTrackCallback: previousTrack,
    );

    player.processingStateStream.listen((state) {
      if (state == ProcessingState.ready) storeNowPlaying();
      if (state == ProcessingState.completed) nextTrack();
    });

    player.positionStream.listen(
      (position) => notificationState?.add(notificationState!.value.copyWith(
        updatePosition: position,
        bufferedPosition: player.bufferedPosition,
      )),
    );

    player.playerStateStream.listen(
      (state) => notificationState?.add(notificationState!.value.copyWith(
        playing: state.playing,
        processingState: buffering.value
            ? AudioProcessingState.loading
            : AudioProcessingState.values.byName(state.processingState.name),
        controls: [
          if (hasPrevious) MediaControl.skipToPrevious,
          if (hasNext) MediaControl.skipToNext,
          if (!buffering.value) MediaControl.rewind,
          if (!buffering.value) MediaControl.fastForward,
        ],
        systemActions: {
          if (!hasPrevious) MediaAction.skipToPrevious,
          if (!hasNext) MediaAction.skipToNext,
          if (!buffering.value) MediaAction.seek,
          if (!buffering.value) MediaAction.rewind,
          if (!buffering.value) MediaAction.fastForward,
        },
      )),
    );

    beginPlay();
  }

  void addToQueue(PlaylistProvider provider) {
    if (playlistInfo.contains(provider.playlist)) return;

    playlistInfo.add(provider.playlist);
    playlist.addAll(provider.medias.where(
      (media) => !playlist.contains(media),
    ));
  }

  Future<void> beginPlay() async {
    final media = nowPlaying.value;
    try {
      buffering.value = true;
      //todo notification rebuilds unnecessarily
      await player.stop();
      await player.seek(Duration.zero);

      final thumbnail = MediaService().thumbnailFile(
        nowPlaying.value.thumbnail.medium,
      );

      var artUri = Uri.parse(nowPlaying.value.thumbnail.medium);
      if (thumbnail.existsSync()) artUri = thumbnail.uri;

      // Post service notification update
      notificationMetadata?.add(MediaItem(
        id: nowPlaying.value.id,
        title: nowPlaying.value.title,
        artist: nowPlaying.value.author,
        duration: nowPlaying.value.duration,
        album: nowPlayingPlaylist.title,
        artUri: artUri,
      ));

      notificationState?.add(notificationState!.value.copyWith(
        processingState: AudioProcessingState.loading,
        playing: false,
        updatePosition: Duration.zero,
      ));

      final source = await MediaService().getMediaSource(media);

      if (media != nowPlaying.value) return;
      await player.setAudioSource(source);

      if (_disposed) return;
      // Don't await this. Ever.
      // Fuck. I wasted whole day on this
      player.play();
      buffering.value = false;
    } catch (err) {
      if (_disposed) return;
      if (media != nowPlaying.value) return;
      nextTrack();
      //TODO Show error
    }
  }

  Playlist get nowPlayingPlaylist {
    return playlistInfo.firstWhere(
      (element) => element.videoIds.contains(nowPlaying.value.id),
    );
  }

  /// Store the currently playing media for resuming later
  void storeNowPlaying() {
    isar.preferences.setValue<LastPlayedMedia>(
      Preference.lastPlayed,
      LastPlayedMedia(
        mediaId: nowPlaying.value.id,
        playlistId: nowPlayingPlaylist.id,
      ),
    );
  }

  bool get hasPrevious => playlist.indexOf(nowPlaying.value) > 0;

  bool get hasNext => playlist.indexOf(nowPlaying.value) < playlist.length - 1;

  void toggleLoopMode() {
    int next = (LoopMode.values.indexOf(loopMode.value) + 1);
    loopMode.value = LoopMode.values[next % LoopMode.values.length];
  }

  void previousTrack() {
    final currentIndex = playlist.indexOf(nowPlaying.value);
    if (currentIndex == 0) return;
    nowPlaying.value = playlist[currentIndex - 1];
  }

  void nextTrack() {
    final currentIndex = playlist.indexOf(nowPlaying.value);
    final int? nextIndex = switch (loopMode.value) {
      LoopMode.one => currentIndex,
      LoopMode.off => hasNext ? currentIndex + 1 : null,
      LoopMode.all => hasNext ? currentIndex + 1 : 0,
    };

    if (nextIndex != null) nowPlaying.value = playlist[nextIndex];
  }

  void jumpTo(int index) => nowPlaying.value = playlist[index];

  void reorderList(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;

    final item = playlist.removeAt(oldIndex);
    playlist.insert(newIndex, item);
    notifyListeners();
  }

  void shuffle() {
    playlist.shuffle();
    // Put currently playing song at first when looping disabled
    if (loopMode.value == LoopMode.off) {
      reorderList(playlist.indexOf(nowPlaying.value), 0);
    }
    notifyListeners();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    nowPlaying.dispose();
    buffering.dispose();
    player.stop().whenComplete(player.dispose);
    MediaService().unbind(player);
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  BehaviorSubject<PlaybackState>? get notificationState {
    if (_disposed) return null;
    return MediaService().playbackState;
  }

  BehaviorSubject<MediaItem?>? get notificationMetadata {
    if (_disposed) return null;
    return MediaService().mediaItem;
  }
}
