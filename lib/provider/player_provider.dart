import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
// ignore: depend_on_referenced_packages Just for Types. Doesn't matter
import 'package:rxdart/rxdart.dart' show BehaviorSubject;
import 'package:tubesync/clients/media_client.dart';
import 'package:tubesync/model/common.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/model/objectbox.g.dart';
import 'package:tubesync/model/playlist.dart';
import 'package:tubesync/model/preferences.dart';
import 'package:tubesync/provider/playlist_provider.dart';
import 'package:tubesync/services/media_service.dart';

class PlayerProvider extends ChangeNotifier {
  final player = AudioPlayer();
  final Store _store;

  final List<Playlist> _playlistInfo = List.empty(growable: true);
  final List<Media> _playlist = List.empty(growable: true);

  List<Playlist> get playlistInfo => List.of(_playlistInfo);

  List<Media> get playlist => List.of(_playlist);

  // Keeping track of the currently playing media
  late final ValueNotifier<Media> nowPlaying;

  // Buffering state because we fetch Uri on demand
  bool _buffering = false;

  bool get buffering => _buffering;

  // Sleep Timer
  bool _sleepAfterSongEnd = false;
  Timer? _sleepTimerCountDown;
  Duration? _sleepAfterDuration;
  final StreamController<Duration?> _sleepTimerState =
      StreamController.broadcast();

  Stream<Duration?> get sleepTimerCountdown => _sleepTimerState.stream;

  Duration? get sleepTimer => _sleepAfterDuration;

  // We can't use the AudioPlayer based one because nextTrack isn't called
  late LoopMode _loopMode = LoopMode
      .values[_store.box<Preferences>().value<int>(Preference.loopMode)];

  LoopMode get loopMode => _loopMode;

  PlayerProvider(
    this._store,
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
        systemActions: mediaActions,
      )),
    );

    _sleepTimerState.stream.listen((event) {
      if (event == null) {
        _sleepTimerCountDown?.cancel();
        _sleepAfterSongEnd = false;
        _sleepAfterDuration = null;
      } else if (event <= Duration.zero) {
        player.stop();
        _sleepTimerState.add(null);
      }
    });

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
      if (_sleepAfterSongEnd) setSleepTimer(afterSong: _sleepAfterSongEnd);

      final thumbnail = MediaClient().thumbnailFile(
        nowPlaying.value.thumbnailStd,
      );

      var artUri = Uri.parse(nowPlaying.value.thumbnailStd);
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
        controls: mediaControls,
        systemActions: mediaActions,
      ));

      final source = await MediaClient().getMediaSource(media);

      if (media != nowPlaying.value) return;
      await player.setAudioSource(source);

      if (_disposed) return;
      // Don't await this. Ever.
      // Fuck. I wasted whole day on this
      player.play();
      _buffering = false;
      if (_sleepAfterSongEnd) setSleepTimer(afterSong: _sleepAfterSongEnd);
    } catch (err) {
      if (_disposed) return;
      if (media != nowPlaying.value) return;
      nextTrack(ignoreLoopMode: false);
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
    _store.box<Preferences>().set<LastPlayedMedia>(
          Preference.lastPlayed,
          LastPlayedMedia(
            mediaId: nowPlaying.value.id,
            playlistId: nowPlayingPlaylist.id,
          ),
        );
  }

  bool get hasPrevious {
    if (loopMode == LoopMode.all) return true;
    return _playlist.indexOf(nowPlaying.value) > 0;
  }

  bool get hasNext {
    if (loopMode == LoopMode.all) return true;
    return _playlist.indexOf(nowPlaying.value) < _playlist.length - 1;
  }

  void toggleLoopMode() {
    int next = (LoopMode.values.indexOf(_loopMode) + 1);
    _loopMode = LoopMode.values[next % LoopMode.values.length];
    // Force notification update
    notificationState?.add(notificationState!.value.copyWith(
      controls: mediaControls,
      systemActions: mediaActions,
    ));
    _store.box<Preferences>().set<int>(Preference.loopMode, _loopMode.index);
    notifyListeners();
  }

  void previousTrack() {
    if (!hasPrevious) return;
    final current = _playlist.indexOf(nowPlaying.value);
    if (current == 0 && loopMode == LoopMode.all) {
      nowPlaying.value = _playlist.last;
      return;
    }
    nowPlaying.value = _playlist[current - 1];
  }

  void nextTrack({bool ignoreLoopMode = true}) {
    final current = _playlist.indexOf(nowPlaying.value);
    final int? nextIndex = switch (_loopMode) {
      LoopMode.off => hasNext ? current + 1 : null,
      LoopMode.all => current + 1 == playlist.length ? 0 : current + 1,
      LoopMode.one => ignoreLoopMode && hasNext ? current + 1 : current,
    };

    if (current == nextIndex) {
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

  /// Passing null duration & afterSong will cancel the timer
  void setSleepTimer({Duration? duration, bool? afterSong}) {
    if (duration == null && afterSong == null) {
      // Cancel sleepTimer if null
      _sleepTimerState.add(null);
      return;
    }

    _sleepTimerCountDown?.cancel();
    _sleepAfterSongEnd = afterSong == true;
    _sleepAfterDuration = duration;

    if (_sleepAfterSongEnd) {
      final nowPlayingDuration = nowPlaying.value.duration;
      if (nowPlayingDuration == null) return _sleepTimerState.add(null);
      _sleepAfterDuration = nowPlayingDuration - player.position;
    }

    void countDown(Duration elapsed) {
      final nowPlayingDuration = nowPlaying.value.duration;
      if (_sleepAfterSongEnd && nowPlayingDuration == null) {
        _sleepTimerState.add(null);
        return;
      }

      final timeLeft = _sleepAfterSongEnd
          ? nowPlayingDuration! - player.position
          : _sleepAfterDuration! - elapsed;

      _sleepAfterDuration = timeLeft;
      _sleepTimerState.add(timeLeft);
    }

    countDown(Duration.zero);
    _sleepTimerCountDown = Timer.periodic(const Duration(seconds: 1), (_) {
      // Don't countdown if paused
      if (!buffering && player.playing) countDown(const Duration(seconds: 1));
    });
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    nowPlaying.dispose();
    _sleepTimerCountDown?.cancel();
    _sleepTimerState.close();
    player.stop().whenComplete(player.dispose);
    MediaService().unbind(this);
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Set<MediaAction> get mediaActions => {if (!buffering) MediaAction.seek};

  List<MediaControl> get mediaControls => [
        if (_store.box<Preferences>().value(Preference.notifShowShuffle))
          const MediaControl(
            androidIcon: "drawable/shuffle_24px",
            label: "Shuffle",
            action: MediaAction.custom,
            customAction: CustomMediaAction(name: "Shuffle"),
          ),
        if (hasPrevious) MediaControl.skipToPrevious,
        if (!buffering) ...{
          if (player.playing) MediaControl.pause else MediaControl.play
        },
        if (hasNext) MediaControl.skipToNext,
        if (_store.box<Preferences>().value(Preference.notifShowRepeat))
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
