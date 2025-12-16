import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
// ignore: depend_on_referenced_packages Just for Types. Doesn't matter
import 'package:rxdart/rxdart.dart' show BehaviorSubject;
import 'package:syncara/clients/media_client.dart';
import 'package:syncara/data/models/media.dart';
import 'package:syncara/data/models/playlist.dart';
import 'package:syncara/data/providers/playlist/playlist_provider.dart';
import 'package:syncara/extensions.dart';
import 'package:syncara/model/common.dart';
import 'package:syncara/model/objectbox.g.dart';
import 'package:syncara/model/preferences.dart';
import 'package:syncara/services/media_service.dart';

class PlayerProvider extends ChangeNotifier {
  final player = AudioPlayer();
  final Store _store;

  final List<Playlist> _playlistInfo = List.empty(growable: true);
  final List<Media> _playlist = List.empty(growable: true);
  final List<String> _originalPlaylistOrderIds = List.empty(growable: true);

  List<Playlist> get playlistInfo => List.of(_playlistInfo);

  List<Media> get playlist => List.of(_playlist);

  // Keeping track of the currently playing media
  // TODO Don't use seperate ValueNotifier
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
  late LoopMode _loopMode =
      LoopMode.values[_store.box<Preferences>().value<int>(
        Preference.loopMode,
      )];

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
    _originalPlaylistOrderIds.addAll(_playlist.map((e) => e.url));
    prepare?.call(this);
    nowPlaying = ValueNotifier(start ?? _playlist.first);
    nowPlaying.addListener(beginPlay);

    MediaService().bind(this);

    player.processingStateStream.listen((state) {
      if (state == ProcessingState.ready) storeNowPlaying();
      if (state == ProcessingState.completed) nextTrack(ignoreLoopMode: false);
    });

    player.bufferedPositionStream.listen(
      (buffer) => notificationState?.add(
        notificationState!.value.copyWith(
          bufferedPosition: buffer,
        ),
      ),
    );

    player.positionStream.listen(
      (position) => notificationState?.add(
        notificationState!.value.copyWith(
          updatePosition: position,
        ),
      ),
    );

    player.playerStateStream.listen(
      (state) => notificationState?.add(
        notificationState!.value.copyWith(
          playing: state.playing,
          updatePosition: player.position,
          processingState:
              _buffering
                  ? AudioProcessingState.loading
                  : AudioProcessingState.values.byName(
                    state.processingState.name,
                  ),
          controls: mediaControls,
          systemActions: mediaActions,
        ),
      ),
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
    final uniqueMedias = provider.medias.where(
      (media) => !_playlist.contains(media),
    );
    _playlist.addAll(uniqueMedias);
    _originalPlaylistOrderIds.addAll(uniqueMedias.map((e) => e.url));
    notifyListeners();
  }

  Future<void> beginPlay() async {
    final media = nowPlaying.value;

    try {
      // HACK: Quickly toggle _disposed flag so stop event doesn't get emitted by notificationState causing spam
      _buffering = true;
      _disposed = true;
      await player.stop();
      _disposed = false;
      await player.seek(Duration.zero);
      if (_sleepAfterSongEnd) setSleepTimer(afterSong: _sleepAfterSongEnd);

      final thumbnail = MediaClient().thumbnailFile(
        nowPlaying.value.thumbnail ?? "",
      );

      var artUri = Uri.parse(nowPlaying.value.thumbnail ?? "");
      if (thumbnail.existsSync()) artUri = thumbnail.uri;

      // Post service notification update
      notificationMetadata?.add(
        MediaItem(
          id: nowPlaying.value.url,
          title: nowPlaying.value.title,
          artist: nowPlaying.value.author,
          duration: nowPlaying.value.duration,
          album: nowPlayingPlaylist?.displayTitle,
          artUri: artUri,
        ),
      );

      notificationState?.add(
        notificationState!.value.copyWith(
          processingState: AudioProcessingState.loading,
          playing: false,
          updatePosition: Duration.zero,
          controls: mediaControls,
          systemActions: mediaActions,
        ),
      );

      final source = await MediaClient().getMediaSource(media);

      if (media != nowPlaying.value) return;
      await player.setAudioSource(source);

      if (_disposed) return;
      player.play();
      _buffering = false;
      if (_sleepAfterSongEnd) setSleepTimer(afterSong: _sleepAfterSongEnd);
    } catch (err, stack) {
      if (kDebugMode) debugPrintStack(stackTrace: stack, label: err.toString());
      if (_disposed) return;
      if (media != nowPlaying.value) return;
      nextTrack(ignoreLoopMode: false);
    } finally {
      notifyListeners();
    }
  }

  Playlist? get nowPlayingPlaylist {
    return _playlistInfo.cast<Playlist?>().firstWhere(
      (element) => element!.videoIds.contains(nowPlaying.value.id),
      orElse: () => null,
    );
  }

  /// Store the currently playing media for resuming later
  void storeNowPlaying() {
    if (nowPlayingPlaylist == null) return;
    _store.box<Preferences>().set<LastPlayedMedia>(
      Preference.lastPlayed,
      LastPlayedMedia(
        mediaId: nowPlaying.value.id,
        playlistId: nowPlayingPlaylist!.id,
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
    notificationState?.add(
      notificationState!.value.copyWith(
        controls: mediaControls,
        systemActions: mediaActions,
      ),
    );
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

  void reorderList(int oldIndex, int newIndex, {bool notify = true}) {
    if (oldIndex < newIndex) newIndex -= 1;

    final item = _playlist.removeAt(oldIndex);
    _playlist.insert(newIndex, item);
    if (notify) notifyListeners();
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

  void setPlaybackSpeed(double speed) {
    player.setSpeed(speed);
  }

  void sortQueue(SortOption option) {
    switch (option) {
      case SortOption.Ascending:
        _playlist.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.Descending:
        _playlist.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.Reverse:
        final reversed = _playlist.reversed.toList();
        _playlist.clear();
        _playlist.addAll(reversed);
        break;

      case SortOption.Author:
        _playlist.sort((a, b) => a.author.compareTo(b.author));
        break;

      case SortOption.Reset:
        for (final (index, id) in _originalPlaylistOrderIds.indexed) {
          final old = _playlist.indexWhere((element) => element.id == id);
          reorderList(old, index, notify: false);
        }
        break;
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

      final timeLeft =
          _sleepAfterSongEnd
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

  void seekForward() {
    if (nowPlaying.value.duration == null) return;
    final position = player.position + const Duration(seconds: 10);
    player.seek(position.clampMax(nowPlaying.value.duration!));
  }

  void seekBackward() {
    final position = player.position - const Duration(seconds: 10);
    player.seek(position.clampMin(Duration.zero));
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

  Set<MediaAction> get mediaActions => {
    MediaAction.play,
    MediaAction.pause,
    if (!buffering) MediaAction.seek,
    MediaAction.skipToPrevious,
    MediaAction.skipToNext,
  };

  List<MediaControl> get mediaControls => [
    if (_store.box<Preferences>().value(Preference.notifShowShuffle))
      const MediaControl(
        androidIcon: "drawable/shuffle_24px",
        label: "Shuffle",
        action: MediaAction.custom,
        customAction: CustomMediaAction(name: "Shuffle"),
      ),
    if (hasPrevious)
      const MediaControl(
        androidIcon: 'drawable/skip_previous_24px',
        label: 'Previous',
        action: MediaAction.skipToPrevious,
      ),
    if (!buffering) ...{
      if (player.playing)
        const MediaControl(
          androidIcon: 'drawable/pause_24px',
          label: 'Pause',
          action: MediaAction.pause,
        )
      else
        const MediaControl(
          androidIcon: 'drawable/play_arrow_24px',
          label: 'Play',
          action: MediaAction.play,
        ),
    },
    if (hasNext)
      const MediaControl(
        androidIcon: 'drawable/skip_next_24px',
        label: 'Next',
        action: MediaAction.skipToNext,
      ),
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
    if (_stopButtonCustom != null) _stopButtonCustom!,
  ];

  MediaControl? get _stopButtonCustom {
    final action = _store.box<Preferences>().value<int>(
      Preference.notifCloseButtonAction,
    );

    return switch (NotificationCloseButton.values[action]) {
      NotificationCloseButton.Close => const MediaControl(
        androidIcon: 'drawable/close_24px',
        label: 'Close',
        action: MediaAction.stop,
      ),
      NotificationCloseButton.Shuffle => const MediaControl(
        androidIcon: "drawable/shuffle_24px",
        label: "Shuffle",
        action: MediaAction.stop,
      ),
      NotificationCloseButton.SeekForward => const MediaControl(
        androidIcon: "drawable/fast_forward_24px",
        label: "Seek Forward",
        action: MediaAction.stop,
      ),
      NotificationCloseButton.SeekBackward => const MediaControl(
        androidIcon: "drawable/fast_rewind_24px",
        label: "Seek Backward",
        action: MediaAction.stop,
      ),
      NotificationCloseButton.None => null,
    };
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
