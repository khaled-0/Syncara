import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:objectbox/objectbox.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

part 'playlist.g.dart';

enum PlaylistType {
  local,
  youtube
  ;

  static PlaylistType fromUrl(String url) {
    return switch (Uri.parse(url).scheme) {
      "file" => PlaylistType.local,
      "http" || "https" => PlaylistType.youtube,
      _ => PlaylistType.local,
    };
  }
}

@Entity()
@CopyWith(copyWithNull: true)
class Playlist {
  @Id(assignable: true)
  int objectId = 0;

  @Index()
  @Unique(onConflict: ConflictStrategy.replace)
  final String url;

  final String title, author;
  final String? description;
  final int itemCount;

  final String? thumbnail;
  final String? thumbnailHiRes;

  /// User defined title
  final String? customTitle;

  PlaylistType get type => PlaylistType.fromUrl(url);

  String get displayTitle => customTitle ?? title;

  Playlist({
    required this.url,
    required this.title,
    required this.author,
    this.thumbnail,
    this.thumbnailHiRes,
    required this.itemCount,
    this.description,
    this.customTitle,
  });

  factory Playlist.fromYTPlaylist(yt.Playlist playlist) {
    return Playlist(
      url: playlist.url,
      title: playlist.title,
      author: playlist.author.isEmpty ? "Youtube" : playlist.author,
      thumbnail: playlist.thumbnails.mediumResUrl,
      thumbnailHiRes: playlist.thumbnails.maxResUrl,
      itemCount: playlist.videoCount ?? -1,
      description: playlist.description.isEmpty ? null : playlist.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist && runtimeType == other.runtimeType && url == other.url;

  @override
  int get hashCode => url.hashCode;
}
