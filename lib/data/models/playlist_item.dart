import 'package:objectbox/objectbox.dart';

import 'media.dart';
import 'playlist.dart';

@Entity()
class PlaylistItem {
  @Id()
  int objectId = 0;

  final int position;

  final ToOne<Playlist> playlist = ToOne<Playlist>();
  final ToOne<Media> media = ToOne<Media>();

  PlaylistItem({required this.position});
}
