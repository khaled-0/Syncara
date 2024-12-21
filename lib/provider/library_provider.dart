import 'package:flutter/foundation.dart';
import 'package:tubesync/model/objectbox.g.dart';
import 'package:tubesync/model/playlist.dart';
import 'package:tubesync/provider/playlist_provider.dart';
import 'package:tubesync/services/downloader_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class LibraryProvider extends ChangeNotifier {
  final Store store;
  final _ytClient = yt.YoutubeExplode().playlists;
  final List<Playlist> entries = List.empty(growable: true);

  LibraryProvider(this.store) {
    entries.addAll(store.box<Playlist>().getAll());
    notifyListeners();
    refresh();
  }

  Future<void> importPlaylist(String url) async {
    var playlist = await _ytClient.get(url);
    if (playlist.videoCount == 0) throw "Playlist is empty!";

    if (entries.contains(Playlist.fromYTPlaylist(playlist))) {
      throw "Playlist already exists!";
    }

    playlist = await _playlistWithThumbnail(_ytClient, playlist);

    entries.add(Playlist.fromYTPlaylist(playlist));
    // Preload the playlist for faster initial load time
    await PlaylistProvider(store, entries.last, sync: false).refresh();

    store.box<Playlist>().put(entries.last);
    notifyListeners();
  }

  Future<void> refresh() async {
    if (!await DownloaderService.hasInternet) return;
    for (final (index, playlist) in entries.indexed) {
      try {
        final updatedPlaylist = await compute(
          (ytClient) async {
            final update = await ytClient.get(playlist.id);
            return await _playlistWithThumbnail(ytClient, update);
          },
          _ytClient,
        );
        entries[index] = Playlist.fromYTPlaylist(
          updatedPlaylist,
          videoIds: entries[index].videoIds, // Pass previously cached videoIds
        );
      } catch (_) {
        // TODO Error
      }
    }
    store.box<Playlist>().putMany(entries);
    notifyListeners();
  }

  void delete(Playlist playlist) {
    entries.removeWhere((element) => element.id == playlist.id);
    store
        .box<Playlist>()
        .query(Playlist_.id.equals(playlist.id))
        .build()
        .removeAsync();
    notifyListeners();
  }

  // Workaround for playlist thumbnail (thumb of first vid)
  // still no custom thumbnails tho
  // Isolates require static methods
  static Future<yt.Playlist> _playlistWithThumbnail(
      yt.PlaylistClient ytClient, yt.Playlist playlist) async {
    return playlist.copyWith(
      thumbnails: yt.ThumbnailSet(
        (await ytClient.getVideos(playlist.id).first).id.value,
      ),
    );
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}
