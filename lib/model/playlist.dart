import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

@Entity()
class Playlist with EquatableMixin {
  @Id()
  int objectId = 0;

  @Index()
  @Unique(onConflict: ConflictStrategy.replace)
  final String id;
  final String title, author;

  final String? description;

  final String thumbnailStd;
  final String thumbnailMax;
  final int videoCount;

  final List<String> videoIds;

  Playlist(
    this.id,
    this.title,
    this.author,
    this.thumbnailStd,
    this.thumbnailMax,
    this.videoCount,
    this.description,
    this.videoIds,
  );

  factory Playlist.fromYTPlaylist(
    yt.Playlist playlist, {
    List<String>? videoIds,
  }) =>
      Playlist(
        playlist.id.value,
        playlist.title,
        playlist.author,
        playlist.thumbnails.mediumResUrl,
        playlist.thumbnails.maxResUrl,
        playlist.videoCount ?? -1,
        playlist.description.isNotEmpty ? playlist.description : null,
        videoIds ?? List.empty(growable: true),
      );

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [id];
}
