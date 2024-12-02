import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:tubesync/model/common.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

part 'playlist.g.dart';

@Collection(ignore: {"props", "stringify"})
class Playlist with EquatableMixin {
  @Id()
  final String id;
  final String title, author;

  final String? description;

  final Thumbnails thumbnail;
  final int videoCount;

  final List<String> videoIds;

  Playlist(
    this.id,
    this.title,
    this.author,
    this.thumbnail,
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
        Thumbnails.fromYTThumbnails(playlist.thumbnails),
        playlist.videoCount ?? -1,
        playlist.description.isNotEmpty ? playlist.description : null,
        videoIds ?? List.empty(growable: true),
      );

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [id];
}
