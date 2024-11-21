import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/provider/player_provider.dart';
import 'package:tubesync/provider/playlist_provider.dart';
import 'package:tubesync/services/downloader_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class MediaService extends BaseAudioHandler {
  /// <-- Singleton
  static late final MediaService _instance;

  factory MediaService() => _instance;

  MediaService._();

  /// Singleton -->

  late final String _storageDir;
  final _ytClient = yt.YoutubeExplode().videos.streamsClient;
  PlayerProvider? _playerProvider;

  String get downloadsDir => path.join(_storageDir, "downloads");

  String get thumbnailsDir => path.join(_storageDir, "thumbnails");

  /// Must call before runApp
  static Future<void> init() async {
    _instance = await AudioService.init(
      builder: () => MediaService._(),
      config: const AudioServiceConfig(
        rewindInterval: Duration(seconds: 5),
        androidNotificationChannelName: 'TubeSync',
        androidNotificationChannelId: 'io.github.khaled_0.TubeSync',
        androidNotificationIcon: 'drawable/ic_launcher_foreground',
        preloadArtwork: true,
      ),
    );

    _instance._storageDir = (await getApplicationSupportDirectory()).path;
    Directory(_instance.downloadsDir).createSync(recursive: true);
    Directory(_instance.thumbnailsDir).createSync(recursive: true);
    JustAudioMediaKit.ensureInitialized();
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

  File mediaFile(Media media) => File(path.join(downloadsDir, media.id));

  File thumbnailFile(String url) => File(
        path.join(thumbnailsDir, url.hashCode.toString()),
      );

  void enqueue(PlaylistProvider playlist) => _playerProvider?.enqueue(playlist);

  Future<AudioSource> getMediaSource(Media media) async {
    // Try from offline
    final downloaded = mediaFile(media);
    if (downloaded.existsSync()) return AudioSource.file(downloaded.path);

    if (!await DownloaderService.hasInternet) {
      throw const HttpException("No internet!");
    }

    final streamUri = await compute(
      (data) async {
        final ytClient = data[0] as yt.StreamClient;
        final videoManifest = await ytClient.getManifest(data[1]);
        return videoManifest.audioOnly.withHighestBitrate().url;
      },
      [_ytClient, media.id],
    );

    return AudioSource.uri(streamUri);
  }

  bool isDownloaded(Media media) => mediaFile(media).existsSync();

  void delete(Media media) {
    final file = mediaFile(media);
    if (file.existsSync()) file.deleteSync();
  }

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
  Future<void> rewind() async {
    _playerProvider?.player
        .seek(_playerProvider!.player.position - const Duration(seconds: 5))
        .whenComplete(() => playbackState.add(playbackState.value
            .copyWith(updatePosition: _playerProvider!.player.position)));
  }

  @override
  Future<void> fastForward() async {
    _playerProvider?.player
        .seek(_playerProvider!.player.position + const Duration(seconds: 5))
        .whenComplete(() => playbackState.add(playbackState.value
            .copyWith(updatePosition: _playerProvider!.player.position)));
  }
}
