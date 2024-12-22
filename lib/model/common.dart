import 'package:objectbox/objectbox.dart';
import 'package:myusync/model/media.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

@Entity()
class LyricMetadata {
  @Id()
  int objectId = 0;
  @Index()
  @Unique(onConflict: ConflictStrategy.replace)
  final String mediaID;
  final String lang, langCode;

  @Transient()
  final yt.ClosedCaptionTrackInfo? ytCCObj;

  LyricMetadata(
    this.mediaID,
    this.lang,
    this.langCode, {
    this.ytCCObj,
  });

  factory LyricMetadata.fromYTCaption(
    Media media,
    yt.ClosedCaptionTrackInfo cc,
  ) {
    return LyricMetadata(
      media.id,
      cc.language.name.split("-").first.trim(),
      cc.language.code,
      ytCCObj: cc,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricMetadata &&
          runtimeType == other.runtimeType &&
          mediaID == other.mediaID &&
          langCode == other.langCode;

  @override
  int get hashCode => mediaID.hashCode ^ langCode.hashCode;
}

class LastPlayedMedia {
  final String playlistId;
  final String mediaId;

  LastPlayedMedia({
    required this.playlistId,
    required this.mediaId,
  });

  factory LastPlayedMedia.fromJson(Map<String, dynamic> json) =>
      LastPlayedMedia(
        playlistId: json["playlistId"] as String,
        mediaId: json["mediaId"] as String,
      );

  Map<String, dynamic> toJson() => {
        "playlistId": playlistId,
        "mediaId": mediaId,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LastPlayedMedia &&
          runtimeType == other.runtimeType &&
          playlistId == other.playlistId &&
          mediaId == other.mediaId;

  @override
  int get hashCode => playlistId.hashCode ^ mediaId.hashCode;
}
