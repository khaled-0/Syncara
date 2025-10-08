import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart' as local;
import 'package:objectbox/objectbox.dart';
import 'package:syncara/extensions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

@Entity()
class Media {
  @Id()
  int objectId = 0;

  @Index()
  @Unique(onConflict: ConflictStrategy.replace)
  final String id;
  final String title, author;

  final String? description;

  final int? durationMs;

  final String thumbnailStd;
  final String thumbnailMax;

  local.Picture? get thumbnailLocal {
    if (localPath == null) return null;
    final pics = local.readMetadata(File(localPath!), getImage: true).pictures;
    print(pics);
    return pics.firstOrNull;
  }

  @Transient()
  bool? downloaded;

  @Transient()
  final String? localPath;

  String get externalURL {
    return "https://youtube.com/watch?v=$id";
  }

  Duration? get duration =>
      durationMs == null ? null : Duration(milliseconds: durationMs!);

  Media(
    this.id,
    this.title,
    this.author,
    this.description,
    this.durationMs,
    this.thumbnailStd,
    this.thumbnailMax, {
    this.localPath,
  });

  factory Media.fromYTVideo(yt.Video video) => Media(
    video.id.value,
    video.title,
    video.author,
    video.description,
    video.duration?.inMilliseconds,
    video.thumbnails.mediumResUrl,
    video.thumbnails.maxResUrl,
  );

  factory Media.fromAudioMetadata(local.AudioMetadata audio) => Media(
    localPath: audio.file.path,
    audio.file.path.hashCode.toString(),
    audio.title ?? audio.file.filename,
    audio.artist ?? "Unknown Artist",
    "Album: ${audio.album} \u2022 ${audio.genres.take(2).join(",")}",
    audio.duration?.inMilliseconds,
    "",
    "",
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Media &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          durationMs == other.durationMs;

  @override
  int get hashCode => id.hashCode ^ durationMs.hashCode;
}
