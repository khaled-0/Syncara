import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';
import 'package:tubesync/model/media.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

@Entity()
class LyricMetadata with EquatableMixin {
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
  bool get stringify => true;

  @override
  List<Object?> get props => [mediaID, lang, langCode];
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
}
