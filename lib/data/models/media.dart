import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:objectbox/objectbox.dart';
import 'package:syncara/extensions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

part 'media.g.dart';

@Entity()
@CopyWith(copyWithNull: true)
class Media {
  @Id()
  int objectId = 0;

  @Index()
  @Unique(onConflict: ConflictStrategy.replace)
  final String url;
  final String title, author;

  final int? durationMs;

  final String? thumbnail;
  final String? thumbnailHiRes;

  final String? localPath;

  bool get downloaded {
    return localPath != null && File(localPath!).existsSync();
  }

  Duration? get duration =>
      durationMs == null ? null : Duration(milliseconds: durationMs!);

  AudioMetadata? fileMetadata({bool withImage = true}) {
    if (!downloaded) return null;
    return readMetadata(File(localPath!), getImage: withImage);
  }

  Media({
    required this.url,
    required this.title,
    required this.author,
    this.durationMs,
    this.thumbnail,
    this.thumbnailHiRes,
    this.localPath,
  });

  factory Media.fromYTVideo(yt.Video video) => Media(
    url: video.url,
    title: video.title,
    author: video.author,
    durationMs: video.duration?.inMilliseconds,
    thumbnail: video.thumbnails.mediumResUrl,
    thumbnailHiRes: video.thumbnails.maxResUrl,
  );

  factory Media.fromAudioMetadata(AudioMetadata audio) => Media(
    localPath: audio.file.path,
    url: audio.file.path,
    title: audio.title ?? audio.file.filename,
    author: audio.artist ?? "Unknown Artist",
    durationMs: audio.duration?.inMilliseconds,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Media && runtimeType == other.runtimeType && url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() {
    return 'Media{objectId: $objectId, url: $url, title: $title, author: $author, durationMs: $durationMs, thumbnail: $thumbnail, thumbnailHiRes: $thumbnailHiRes, localPath: $localPath}';
  }
}
