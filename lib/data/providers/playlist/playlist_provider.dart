import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart' as audio;
import 'package:flutter/foundation.dart';
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
  void updateItems(Iterable<PlaylistItem> items) {
    _items.clear();
    _items.addAll(items);
  }
}
