import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tubesync/model/media.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

part 'common.g.dart';

@Embedded(ignore: {"props", "stringify"})
class Thumbnails with EquatableMixin {
  //low, high has vertical black borders
  final String low, medium, high;

  Thumbnails(this.low, this.medium, this.high);

  factory Thumbnails.fromYTThumbnails(yt.ThumbnailSet thumbs) =>
      Thumbnails(thumbs.lowResUrl, thumbs.mediumResUrl, thumbs.highResUrl);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [low, medium, high];
}

@Embedded(ignore: {"props", "stringify"})
class LyricMetadata with EquatableMixin {
  final String mediaID;
  final String lang, langCode;

  @ignore
  final yt.ClosedCaptionTrackInfo? ytCCObj;

  LyricMetadata(
    this.mediaID,
    this.lang,
    this.langCode, {
    this.ytCCObj,
  });

  factory LyricMetadata.fromYTCaption(
          Media media, yt.ClosedCaptionTrackInfo cc) =>
      LyricMetadata(
        media.id,
        cc.language.name,
        cc.language.code,
        ytCCObj: cc,
      );

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [mediaID, lang, langCode];
}

@JsonSerializable()
class LastPlayedMedia with EquatableMixin {
  String playlistId;
  String mediaId;

  LastPlayedMedia({
    required this.playlistId,
    required this.mediaId,
  });

  factory LastPlayedMedia.fromJson(Map<String, dynamic> json) =>
      _$LastPlayedMediaFromJson(json);

  Map<String, dynamic> toJson() => _$LastPlayedMediaToJson(this);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [playlistId, mediaId];
}
