import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:tubesync/model/playlist.dart';
import 'package:tubesync/provider/playlist_provider.dart';
import 'package:tubesync/services/downloader_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class LibraryProvider extends ChangeNotifier {
  final Isar isar;
  final _ytClient = yt.YoutubeExplode().playlists;
  final List<Playlist> entries = List.empty(growable: true);

  LibraryProvider(this.isar) {
    entries.addAll(isar.playlists.where().findAll());
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
    await PlaylistProvider(isar, entries.last, sync: false).refresh();
    isar.writeAsyncWith(entries.last, (db, data) => db.playlists.put(data));
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
    isar.writeAsyncWith(entries, (db, data) => db.playlists.putAll(data));
    notifyListeners();
  }

  void delete(Playlist playlist) {
    entries.removeWhere((element) => element.id == playlist.id);
    isar.writeAsync(
      (isar) => isar.playlists.where().idEqualTo(playlist.id).deleteFirst(),
    );
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
