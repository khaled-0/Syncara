import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html;
import 'package:objectbox/objectbox.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../../../services/downloader_service.dart';
import '../../models/playlist.dart';
import '../playlist/playlist_provider.dart';

mixin YTLibraryMixin {
  final _ytClient = yt.YoutubeExplode().playlists;

  List<Playlist> get entries;

  Store get store;

  void notifyListeners();

  Future<void> refreshYoutube(int index, Playlist playlist) async {
    if (!await DownloaderService.hasInternet) return;

    try {
      final updatedPlaylist = await compute(
        (ytClient) async {
          final pl = await ytClient.get(playlist.url);
          return await _ytPlaylistWithThumbnail(Playlist.fromYTPlaylist(pl));
        },
        _ytClient,
      );

      entries[index] = updatedPlaylist.copyWith(
        customTitle: entries[index].customTitle, // User defined title
      );
      notifyListeners();
    } catch (_) {}
  }

  // Parse html page to retrieve custom thumbnails
  Future<Playlist> _ytPlaylistWithThumbnail(
    Playlist playlist,
  ) async {
    try {
      final res = await yt.YoutubeHttpClient().getString(playlist.url);
      final img = html.parse(res).querySelectorAll("meta[property='og:image']");

      final max = img.last.attributes["content"]!;
      final std = (img.elementAtOrNull(1) ?? img.first).attributes["content"]!;

      return playlist.copyWith(thumbnail: std, thumbnailHiRes: max);
    } catch (_) {
      return playlist;
    }
  }

  Future<void> importYTPlaylist(String url) async {
    final playlist = await _ytClient.get(url);
    if (playlist.videoCount == 0) throw "Playlist is empty!";

    if (entries.contains(Playlist.fromYTPlaylist(playlist))) {
      throw "Playlist already exists!";
    }

    final playlistWithThumb = await _ytPlaylistWithThumbnail(
      Playlist.fromYTPlaylist(playlist),
    );

    entries.add(playlistWithThumb);
    // Preload the playlist for faster initial load time
    await PlaylistProvider(store, entries.last, sync: false).refresh();

    store.box<Playlist>().put(entries.last);
  }
}
