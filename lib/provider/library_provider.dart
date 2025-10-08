import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart';
import 'package:syncara/extensions.dart';
import 'package:syncara/model/objectbox.g.dart';
import 'package:syncara/model/playlist.dart';
import 'package:syncara/provider/playlist_provider.dart';
import 'package:syncara/services/downloader_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

// TODO: Refactor to use yt_media_client
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
    final playlist = await _ytClient.get(url);
    if (playlist.videoCount == 0) throw "Playlist is empty!";

    if (entries.contains(Playlist.fromYTPlaylist(playlist))) {
      throw "Playlist already exists!";
    }

    final playlistWithThumb = await _playlistWithThumbnail(
      Playlist.fromYTPlaylist(playlist),
    );

    entries.add(playlistWithThumb);
    // Preload the playlist for faster initial load time
    await PlaylistProvider(store, entries.last, sync: false).refresh();

    store.box<Playlist>().put(entries.last);
    notifyListeners();
  }

  Future<void> refresh() async {
    final internet = await DownloaderService.hasInternet;
    for (final (index, playlist) in entries.indexed) {
      if (playlist.isLocal) {
        entries[index] = entries[index].copyWith(
          title: playlist.localDir.filename,
          videoCount: playlist.localDir.listSync().length,
        );
        notifyListeners();
        continue;
      }

      if (!internet) continue;

      try {
        final updatedPlaylist = await compute(
          (ytClient) async {
            final pl = await ytClient.get(playlist.id);
            return await _playlistWithThumbnail(Playlist.fromYTPlaylist(pl));
          },
          _ytClient,
        );

        entries[index] = updatedPlaylist.copyWith(
          videoIds: entries[index].videoIds, // Pass previously cached videoIds
          customTitle: entries[index].customTitle, // User defined title
        );
        notifyListeners();
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

  // Parse html page to retrieve custom thumbnails
  static Future<Playlist> _playlistWithThumbnail(
    Playlist playlist,
  ) async {
    try {
      final response = await yt.YoutubeHttpClient().getString(
        playlist.externalURL,
      );
      final img = parse(response).querySelectorAll("meta[property='og:image']");

      final max = img.last.attributes["content"]!;
      final std = (img.elementAtOrNull(1) ?? img.first).attributes["content"]!;

      return playlist.copyWith(thumbnailStd: std, thumbnailMax: max);
    } catch (_) {
      return playlist;
    }
  }

  /// Passing null will remove the name
  void renamePlaylist(Playlist playlist, {String? name}) {
    final index = entries.indexOf(playlist);
    if (index == -1) throw Exception("$playlist not in library");

    if (name == null) {
      entries[index] = playlist.copyWithNull(customTitle: true);
    } else {
      entries[index] = playlist.copyWith(customTitle: name);
    }

    store.box<Playlist>().putMany(entries);
    notifyListeners();
  }

  Future<void> importLocalPlaylist(Directory path) async {
    entries.add(
      Playlist(
        id: path.hashCode.toString(),
        title: path.path.split(Platform.pathSeparator).last.toCapitalCase(),
        author: "Local",
        thumbnailStd: "",
        thumbnailMax: "",
        videoCount: path.listSync().length,
        videoIds: [],
        localPath: path.path,
      ),
    );
    store.box<Playlist>().put(entries.last);
    notifyListeners();
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
