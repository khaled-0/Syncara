part of 'playlist_provider.dart';

mixin _LocalPlaylistMixin {
  Store get store;

  Playlist get playlist;

  void notifyListeners();

  @visibleForOverriding
  Future<void> updateMediaEntries(List<Media> medias);

  Future<void> refreshLocalPlaylist() async {
    final directory = Directory(Uri.parse(playlist.url).toFilePath());
    if (!directory.existsSync()) {
      updateMediaEntries([]);
      return notifyListeners();
    }

    final medias = directory.listSync().map<Media?>((e) {
      try {
        final data = audio.readMetadata(File(e.path));
        return Media.fromAudioMetadata(data);
      } catch (_) {
        return Media(
          localPath: e.path,
          url: e.path,
          title: p.basename(e.path),
          author: "Unknown Artist",
        );
      }
    });

    await updateMediaEntries(medias.nonNulls.toList());
    notifyListeners();
  }
}
