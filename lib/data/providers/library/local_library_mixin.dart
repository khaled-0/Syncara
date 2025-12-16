part of 'library_provider.dart';

mixin _LocalLibraryMixin {
  List<Playlist> get entries;

  Store get store;

  void notifyListeners();

  int _dirItemCount(Uri uri) {
    final dir = Directory(uri.toFilePath());
    return dir.existsSync() ? dir.listSync().length : 0;
  }

  void refreshLocal(int index, Playlist playlist) {
    entries[index] = playlist.copyWith(
      itemCount: _dirItemCount(Uri.parse(playlist.url)),
    );
    notifyListeners();
  }

  Future<void> importLocalPlaylist(Uri url) async {
    if (url.scheme != "file") throw UnsupportedError("Scheme: ${url.scheme}");
    entries.add(
      Playlist(
        url: url.toString(),
        title: p.basename(url.toFilePath()).toCapitalCase(),
        author: "Local",
        thumbnail: Uri.file(p.join(url.path, ".thumb")).toString(),
        itemCount: _dirItemCount(url),
      ),
    );
    store.box<Playlist>().put(entries.last);
    notifyListeners();
  }
}
