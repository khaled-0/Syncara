import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart' as audio;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:syncara/clients/yt_media_client.dart';
import 'package:syncara/data/models/media.dart';
import 'package:syncara/data/models/playlist.dart';
import 'package:syncara/model/objectbox.g.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../../../services/downloader_service.dart';
import '../../models/playlist_item.dart';

part 'local_playlist_mixin.dart';
part 'yt_playlist_mixin.dart';

class PlaylistProvider extends ChangeNotifier
    with _LocalPlaylistMixin, _YtPlaylistMixin {
  @override
  final Store store;
  @override
  final Playlist playlist;
  final List<PlaylistItem> _items = List.of([]);

  List<Media> get medias => _items.map((e) => e.media.target).nonNulls.toList();

  PlaylistProvider(this.store, this.playlist, {bool sync = true}) {
    final box = store.box<PlaylistItem>();
    final query = box.query(PlaylistItem_.playlist.equals(playlist.objectId));
    _items.addAll(query.order(PlaylistItem_.position).build().find());
    notifyListeners();
    if (sync) refresh();
  }

  Future<void> refresh() async {
    switch (playlist.type) {
      case PlaylistType.local:
        return refreshLocalPlaylist();

      case PlaylistType.youtube:
        return refreshYoutubePlaylist();
    }
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

  @override
  Future<void> updateMediaEntries(List<Media> medias) async {
    final items = List<PlaylistItem>.of([]);

    final existingMedias = store.box<Media>().query(
      Media_.url.oneOf(medias.map((e) => e.url).toList()),
    );

    for (final existing in existingMedias.build().find()) {
      final index = medias.indexWhere((e) => e.url == existing.url);
      if (index == -1) continue;
      medias[index] = medias[index].copyWith(localPath: existing.localPath);
      medias[index].objectId = existing.objectId;
    }

    for (final (i, media) in medias.indexed) {
      items.add(
        PlaylistItem.create(
          position: i,
          media: media,
          playlist: playlist,
        ),
      );
    }

    final existingPlaylistItem = _box
        .query(PlaylistItem_.uid.oneOf(items.map((e) => e.uid).toList()))
        .build()
        .find();

    for (final existing in existingPlaylistItem) {
      final index = items.indexWhere((e) => e.uid == existing.uid);
      if (index == -1) continue;
      items[index].objectId = existing.objectId;
    }

    final remove = _box.query(PlaylistItem_.playlist.equals(playlist.objectId));
    _box.removeMany(remove.build().findIds());

    _items.clear();
    _items.addAll(await _box.putAndGetManyAsync(items));
  }
}
