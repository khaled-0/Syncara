import 'package:objectbox/objectbox.dart';
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

  @Transient()
  // TODO Cache download in DB and update asynchronously
  bool? downloaded;

  Duration? get duration =>
      durationMs == null ? null : Duration(milliseconds: durationMs!);

  Media(
    this.id,
    this.title,
    this.author,
    this.description,
    this.durationMs,
    this.thumbnailStd,
    this.thumbnailMax,
  );

  factory Media.fromYTVideo(yt.Video video) => Media(
        video.id.value,
        video.title,
        video.author,
        video.description,
        video.duration?.inMilliseconds,
        video.thumbnails.mediumResUrl,
        video.thumbnails.maxResUrl,
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
