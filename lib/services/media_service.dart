import 'package:audio_service/audio_service.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:syncara/provider/player_provider.dart';
import 'package:syncara/provider/playlist_provider.dart';

class MediaService extends BaseAudioHandler {
  /// <-- Singleton
  static late final MediaService _instance;

  factory MediaService() => _instance;

  MediaService._();

  /// Singleton -->

  PlayerProvider? _playerProvider;

  /// Must call before runApp
  static Future<void> init() async {
    _instance = await AudioService.init(
      builder: () => MediaService._(),
      config: const AudioServiceConfig(
        androidNotificationChannelName: 'Syncara',
        androidNotificationChannelId: 'io.github.khaled_0.TubeSync',
        androidNotificationIcon: 'drawable/ic_launcher_monochrome',
        preloadArtwork: true,
      ),
    );

    JustAudioMediaKit.ensureInitialized(iOS: true, macOS: true);
  }

  /// Call this method for back and forth communication
  /// TODO Make player an internal of this, no need for player provider
  /// Do PlayerProvider -> QueueProvider
  void bind(PlayerProvider playerProvider) => _playerProvider = playerProvider;

  void unbind(PlayerProvider playerProvider) async {
    // No need to unbind if some other player is re binded
    if (_playerProvider != playerProvider) return;

    _playerProvider = null;
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
  }

  void enqueue(PlaylistProvider playlist) => _playerProvider?.enqueue(playlist);

  bool get isPlayerActive => _playerProvider != null;

  @override
  Future<void> play() async => _playerProvider?.player.play();

  @override
  Future<void> pause() async => _playerProvider?.player.pause();

  @override
  Future<void> stop() async => _playerProvider?.player.stop();

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
