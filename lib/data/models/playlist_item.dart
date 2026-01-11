import 'package:objectbox/objectbox.dart';

import 'media.dart';
import 'playlist.dart';

@Entity()
class PlaylistItem {
  @Id(assignable: true)
  int objectId = 0;

  final int position;

  final ToOne<Playlist> playlist = ToOne<Playlist>();
  final ToOne<Media> media = ToOne<Media>();

  @Unique(onConflict: ConflictStrategy.replace)
  @Index()
  late String uid;

  PlaylistItem({required this.position});

  factory PlaylistItem.create({
    required final int position,
    required final Media media,
    required final Playlist playlist,
  }) {
    final item = PlaylistItem(position: position);
    item.playlist.target = playlist;
    item.media.target = media;
    item.uid = "${playlist.objectId}_${media.objectId}";
    return item;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistItem &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'PlaylistItem{objectId: $objectId, position: $position, playlist: $playlist, media: $media, uid: $uid}';
  }
}
