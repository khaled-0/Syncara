import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:html/parser.dart' as html;
import 'package:path/path.dart' as p;
import 'package:syncara/data/models/playlist.dart';
import 'package:syncara/extensions.dart';
import 'package:syncara/model/objectbox.g.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../../../services/downloader_service.dart';
import '../playlist/playlist_provider.dart';

part 'local_library_mixin.dart';
part 'yt_library_mixin.dart';

class LibraryProvider extends ChangeNotifier
    with _YtLibraryMixin, _LocalLibraryMixin {
  @override
  final Store store;
  @override
  final List<Playlist> entries = List.empty(growable: true);

  LibraryProvider(this.store) {
    entries.addAll(store.box<Playlist>().getAll());
    notifyListeners();
    refresh();
  }

  Future<void> importPlaylist(String url) async {
    return switch (PlaylistType.fromUrl(url)) {
      PlaylistType.local => importLocalPlaylist(Uri.parse(url)),
      PlaylistType.youtube => importYTPlaylist(url),
    };
  }

  Future<void> refresh() async {
    for (final (index, playlist) in entries.indexed) {
      switch (playlist.type) {
        case PlaylistType.local:
          refreshLocal(index, playlist);
        case PlaylistType.youtube:
          await refreshYoutube(index, playlist);
      }

      notifyListeners();
    }

    store.box<Playlist>().putMany(entries);
    notifyListeners();
  }

  void delete(Playlist playlist) {
    entries.removeWhere((element) => element.url == playlist.url);
    final query = store.box<Playlist>().query(
      Playlist_.url.equals(playlist.url),
    );
    query.build().removeAsync();
    notifyListeners();
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
