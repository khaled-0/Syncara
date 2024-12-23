import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:syncara/clients/yt_media_client.dart';
import 'package:syncara/model/common.dart';
import 'package:syncara/model/media.dart';
import 'package:syncara/services/downloader_service.dart';

abstract class BaseMediaClient {
  Future<AudioSource> getMediaSource(Media media);

  Future<List<LyricMetadata>> getAvailableLyrics(Media media);

  Future<List<String>> getLRCLyrics(LyricMetadata lyric);
}

class MediaClient implements BaseMediaClient {
  /// <-- Singleton
  static late final MediaClient _instance;

  factory MediaClient() => _instance;

  MediaClient._();

  /// Singleton -->

  late final String _storageDir;
  late final YTMediaClient _ytMediaClient = YTMediaClient();

  static Future<void> init() async {
    _instance = MediaClient._();
    _instance._storageDir = (await getApplicationSupportDirectory()).path;
    Directory(_instance.downloadsDir).createSync(recursive: true);
    Directory(_instance.thumbnailsDir).createSync(recursive: true);
  }

  String get downloadsDir => path.join(_storageDir, "downloads");

  String get thumbnailsDir => path.join(_storageDir, "thumbnails");

  File mediaFile(Media media) => File(path.join(downloadsDir, media.id));

  File thumbnailFile(String url) => File(
        path.join(thumbnailsDir, url.hashCode.toString()),
      );

  bool isDownloaded(Media media) => mediaFile(media).existsSync();

  void delete(Media media) {
    final file = mediaFile(media);
    if (file.existsSync()) file.deleteSync();
  }

  @override
  Future<AudioSource> getMediaSource(Media media) async {
    // Try from offline
    final downloaded = mediaFile(media);
    if (downloaded.existsSync()) return AudioSource.file(downloaded.path);

    if (!await DownloaderService.hasInternet) {
      throw const HttpException("No internet!");
    }
    // Try online clients (YT For now)
    return await _ytMediaClient.getMediaSource(media);
  }

  @override
  Future<List<LyricMetadata>> getAvailableLyrics(Media media) {
    return _ytMediaClient.getAvailableLyrics(media);
  }

  @override
  Future<List<String>> getLRCLyrics(LyricMetadata lyric) {
    return _ytMediaClient.getLRCLyrics(lyric);
  }
}
