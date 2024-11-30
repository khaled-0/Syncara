import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:just_audio/just_audio.dart';
// ignore: depend_on_referenced_packages Just for Types. Doesn't matter
import 'package:rxdart/rxdart.dart' show BehaviorSubject;
import 'package:tubesync/clients/media_client.dart';
import 'package:tubesync/model/common.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/model/playlist.dart';
import 'package:tubesync/model/preferences.dart';
import 'package:tubesync/provider/playlist_provider.dart';
import 'package:tubesync/services/media_service.dart';

class PlayerProvider extends ChangeNotifier {
  final player = AudioPlayer();
  final Isar _isar;

  final List<Playlist> _playlistInfo = List.empty(growable: true);
  final List<Media> _playlist = List.empty(growable: true);

  List<Playlist> get playlistInfo => List.of(_playlistInfo);

  List<Media> get playlist => List.of(_playlist);

  // Keeping track of the currently playing media
  late final ValueNotifier<Media> nowPlaying;

  // Buffering state because we fetch Uri on demand
  bool _buffering = false;

  bool get buffering => _buffering;

  // We can't use the AudioPlayer based one because nextTrack isn't called
  LoopMode _loopMode = LoopMode.all;

  LoopMode get loopMode => _loopMode;

  PlayerProvider(
    this._isar,
    PlaylistProvider provider, {
    Media? start,

    /// Used to modify playlist beforehand, e.g shuffle
    void Function(PlayerProvider provider)? prepare,
  }) {
    _playlistInfo.add(provider.playlist);
    _playlist.addAll(provider.medias);
    prepare?.call(this);
    nowPlaying = ValueNotifier(start ?? _playlist.first);
    nowPlaying.addListener(beginPlay);

    MediaService().bind(this);

    player.processingStateStream.listen((state) {
      if (state == ProcessingState.ready) storeNowPlaying();
      if (state == ProcessingState.completed) nextTrack(ignoreLoopMode: false);
    });

    player.bufferedPositionStream.listen(
      (position) => notificationState?.add(notificationState!.value.copyWith(
        updatePosition: player.position,
        bufferedPosition: position,
      )),
    );

    player.playerStateStream.listen(
      (state) => notificationState?.add(notificationState!.value.copyWith(
        playing: state.playing,
        processingState: _buffering
            ? AudioProcessingState.loading
            : AudioProcessingState.values.byName(state.processingState.name),
        controls: mediaControls,
        systemActions: {
          if (hasPrevious) MediaAction.skipToPrevious,
          if (!buffering) ...{
            if (player.playing) MediaAction.pause else MediaAction.pause
          },
          if (hasNext) MediaAction.skipToNext,
          if (!_buffering) MediaAction.seek,
          MediaAction.custom,
        },
      )),
    );

    beginPlay();
  }

  void enqueue(PlaylistProvider provider) {
    if (_playlistInfo.contains(provider.playlist)) return;

    _playlistInfo.add(provider.playlist);
    _playlist.addAll(provider.medias.where(
      (media) => !_playlist.contains(media),
    ));
    notifyListeners();
  }

  Future<void> beginPlay() async {
    final media = nowPlaying.value;
    try {
      // HACK: Quickly toggle _disposed flag so stop event doesn't get emitted by notificationState
      _buffering = true;
      _disposed = true;
      await player.stop();
      _disposed = false;
      await player.seek(Duration.zero);

      final thumbnail = MediaClient().thumbnailFile(
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

      final source = await MediaClient().getMediaSource(media);

      if (media != nowPlaying.value) return;
      await player.setAudioSource(source);

      if (_disposed) return;
      // Don't await this. Ever.
      // Fuck. I wasted whole day on this
      player.play();
      _buffering = false;
    } catch (err) {
      if (_disposed) return;
      if (media != nowPlaying.value) return;
      nextTrack(ignoreLoopMode: false);
      //TODO Show error
    } finally {
      notifyListeners();
    }
  }

  Playlist get nowPlayingPlaylist {
    return _playlistInfo.firstWhere(
      (element) => element.videoIds.contains(nowPlaying.value.id),
    );
  }

  /// Store the currently playing media for resuming later
  void storeNowPlaying() {
    _isar.preferences.setValue<LastPlayedMedia>(
      Preference.lastPlayed,
      LastPlayedMedia(
        mediaId: nowPlaying.value.id,
        playlistId: nowPlayingPlaylist.id,
      ),
    );
  }

  bool get hasPrevious => _playlist.indexOf(nowPlaying.value) > 0;

  bool get hasNext {
    return _playlist.indexOf(nowPlaying.value) < _playlist.length - 1;
  }

  void toggleLoopMode() {
    int next = (LoopMode.values.indexOf(_loopMode) + 1);
    _loopMode = LoopMode.values[next % LoopMode.values.length];
    // Force notification update
    notificationState?.add(notificationState!.value.copyWith(
      controls: mediaControls,
    ));
    notifyListeners();
  }

  void previousTrack() {
    final currentIndex = _playlist.indexOf(nowPlaying.value);
    if (currentIndex == 0) return;
    nowPlaying.value = _playlist[currentIndex - 1];
  }

  void nextTrack({bool ignoreLoopMode = true}) {
    final currentIndex = _playlist.indexOf(nowPlaying.value);
    final int? nextIndex = switch (_loopMode) {
      LoopMode.off => hasNext ? currentIndex + 1 : null,
      LoopMode.all => hasNext ? currentIndex + 1 : 0,
      LoopMode.one => currentIndex,
    };

    if (currentIndex == nextIndex) {
      if (ignoreLoopMode && hasNext) {
        nowPlaying.value = _playlist[nextIndex! + 1];
        return;
      }

      player.seek(Duration.zero);
      player.play();
    } else if (nextIndex != null) {
      nowPlaying.value = _playlist[nextIndex];
    }
  }

  void jumpTo(int index) => nowPlaying.value = _playlist[index];

  void reorderList(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;

    final item = _playlist.removeAt(oldIndex);
    _playlist.insert(newIndex, item);
    notifyListeners();
  }

  /// preserveCurrentIndex: Put currently playing song at first
  void shuffle({bool preserveCurrentIndex = true}) {
    _playlist.shuffle();

    if (preserveCurrentIndex) {
      final nowPlayingIndex = _playlist.indexOf(nowPlaying.value);
      if (nowPlayingIndex == -1) {
        nowPlaying.value = _playlist.first;
      } else {
        reorderList(nowPlayingIndex, 0);
      }
    }

    notifyListeners();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    nowPlaying.dispose();
    player.stop().whenComplete(player.dispose);
    MediaService().unbind(this);
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  List<MediaControl> get mediaControls => [
        const MediaControl(
          androidIcon: "drawable/shuffle_24px",
          label: "Shuffle",
          action: MediaAction.custom,
          customAction: CustomMediaAction(name: "Shuffle"),
        ),
        if (hasPrevious) MediaControl.skipToPrevious,
        if (!buffering) ...{
          if (player.playing) MediaControl.pause else MediaControl.pause
        },
        if (hasNext) MediaControl.skipToNext,
        MediaControl(
          androidIcon: switch (_loopMode) {
            LoopMode.off => "drawable/repeat_off_24px",
            LoopMode.one => "drawable/repeat_one_24px",
            LoopMode.all => "drawable/repeat_all_24px",
          },
          label: "Repeat",
          action: MediaAction.custom,
          customAction: const CustomMediaAction(name: "Repeat"),
        ),
      ];

  BehaviorSubject<PlaybackState>? get notificationState {
    if (_disposed) return null;
    return MediaService().playbackState;
  }

  BehaviorSubject<MediaItem?>? get notificationMetadata {
    if (_disposed) return null;
    return MediaService().mediaItem;
  }
}
