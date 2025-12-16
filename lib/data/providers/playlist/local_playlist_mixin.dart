part of 'playlist_provider.dart';

mixin _LocalPlaylistMixin {
  Store get store;

  Playlist get playlist;

  late final _box = store.box<PlaylistItem>();

  void notifyListeners();

  @visibleForOverriding
  void updateItems(List<PlaylistItem> items);

  Future<void> refreshLocalPlaylist() async {
    final directory = Directory.fromUri(Uri.file(playlist.url));
    final musics = directory.listSync().map<Media?>((e) {
      try {
        final data = audio.readMetadata(File(e.path));
        return Media.fromAudioMetadata(data);
      } catch (_) {
        return null;
      }
    });

    final items = List<PlaylistItem>.of([]);
    for (final (i, media) in musics.nonNulls.indexed) {
      items.add(
        PlaylistItem.create(position: i, media: media, playlist: playlist),
      );
    }

    updateItems(await _box.putAndGetManyAsync(items));
    notifyListeners();
  }
}
