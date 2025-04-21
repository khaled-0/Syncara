import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:objectbox/objectbox.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

part 'playlist.g.dart';

@Entity()
@CopyWith(copyWithNull: true)
class Playlist {
  @Id()
  int objectId = 0;

  @Index()
  @Unique(onConflict: ConflictStrategy.replace)
  final String id;
  final String title, author;

  /// User defined title
  final String? customTitle;

  final String? description;

  final String thumbnailStd;
  final String thumbnailMax;
  final int videoCount;

  final List<String> videoIds;

  String get externalURL {
    return "https://youtube.com/playlist?list=$id";
  }

  /// Read custom title if available
  String get getTitle => customTitle ?? title;

  Playlist({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnailStd,
    required this.thumbnailMax,
    required this.videoCount,
    this.description,
    required this.videoIds,
    this.customTitle,
  });

  factory Playlist.fromYTPlaylist(
    yt.Playlist playlist, {
    List<String>? videoIds,
  }) {
    return Playlist(
      id: playlist.id.value,
      title: playlist.title,
      author: playlist.author.isEmpty ? "Youtube" : playlist.author,
      thumbnailStd: playlist.thumbnails.mediumResUrl,
      thumbnailMax: playlist.thumbnails.maxResUrl,
      videoCount: playlist.videoCount ?? -1,
      description:
          playlist.description.isNotEmpty ? playlist.description : null,
      videoIds: videoIds ?? List.empty(growable: true),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
