import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:objectbox/objectbox.dart';
import 'package:syncara/model/common.dart';
import 'package:syncara/model/preferences.dart';

import '../data/providers/player_provider.dart';
import '../data/providers/playlist/playlist_provider.dart';

class MediaService extends BaseAudioHandler {
  /// <-- Singleton
  static late final MediaService _instance;

  factory MediaService() => _instance;

  MediaService._();

  /// Singleton -->

  PlayerProvider? _playerProvider;
  late final Store _store;

  /// Must call before runApp
  static Future<void> init(Store db) async {
    _instance = await AudioService.init(
      builder: () => MediaService._(),
      config: const AudioServiceConfig(
        androidNotificationChannelName: 'Syncara',
        androidNotificationChannelId: 'io.github.khaled_0.TubeSync',
        androidNotificationIcon: 'drawable/ic_launcher_monochrome',
        preloadArtwork: true,
      ),
    );

    _instance._store = db;
    JustAudioMediaKit.ensureInitialized(iOS: true, macOS: true, windows: true);
  }

  /// Call this method for back and forth communication
  /// TODO Make player an internal of this, no need for player provider
  /// Do PlayerProvider -> QueueProvider
  void bind(PlayerProvider playerProvider) => _playerProvider = playerProvider;

  void unbind(PlayerProvider playerProvider) async {
    // No need to unbind if some other player is re binded
    if (_playerProvider != playerProvider) return;

    _playerProvider = null;
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
      ),
    );
  }

  void enqueue(PlaylistProvider playlist) => _playerProvider?.enqueue(playlist);

  bool get isPlayerActive => _playerProvider != null;

  @override
  Future<void> play() async => _playerProvider?.player.play();

  @override
  Future<void> pause() async => _playerProvider?.player.pause();

  Future<void> togglePlayPause() async {
    if (_playerProvider?.player.playing == true) {
      return _playerProvider?.player.pause();
    } else {
      return _playerProvider?.player.play();
    }
  }

  @override
  Future<void> seekBackward(_) async => _playerProvider?.seekBackward();

  @override
  Future<void> seekForward(_) async => _playerProvider?.seekForward();

  @override
  Future<void> stop() async {
    final action = _store.box<Preferences>().value<int>(
      Preference.notifCloseButtonAction,
    );

    return switch (NotificationCloseButton.values[action]) {
      (NotificationCloseButton.Close || NotificationCloseButton.None) =>
        _playerProvider?.player.stop(),
      NotificationCloseButton.Shuffle => _playerProvider?.shuffle(
        preserveCurrentIndex: false,
      ),
      NotificationCloseButton.SeekForward => _playerProvider?.seekForward(),
      NotificationCloseButton.SeekBackward => _playerProvider?.seekBackward(),
    };
  }

  @override
  Future<void> seek(Duration position) async {
    _playerProvider?.player.seek(position);
    playbackState.add(playbackState.value.copyWith(updatePosition: position));
  }

  @override
  Future<void> skipToPrevious() async => _playerProvider?.previousTrack();

  @override
  Future<void> skipToNext() async => _playerProvider?.nextTrack();

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case "Shuffle":
        _playerProvider?.shuffle();
        break;
      case "Repeat":
        _playerProvider?.toggleLoopMode();
        break;
    }
  }
}

abstract class MediaIntent extends Intent {}

class PlayPauseIntent extends MediaIntent {}

class SeekBackIntent extends MediaIntent {}

class SeekForwardIntent extends MediaIntent {}

class PreviousMediaIntent extends MediaIntent {}

class NextMediaIntent extends MediaIntent {}

class PlaybackAction<T extends MediaIntent> extends Action {
  @override
  Object? invoke(Intent intent) {
    return switch (T) {
      const (PlayPauseIntent) => MediaService().togglePlayPause(),
      const (SeekBackIntent) => MediaService().seekBackward(false),
      const (SeekForwardIntent) => MediaService().seekForward(false),
      const (PreviousMediaIntent) => MediaService().skipToPrevious(),
      const (NextMediaIntent) => MediaService().skipToNext(),
      _ => throw UnimplementedError(),
    };
  }
}
