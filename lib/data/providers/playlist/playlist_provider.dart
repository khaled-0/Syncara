import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:syncara/data/models/media.dart';
import 'package:syncara/data/models/playlist.dart';
import 'package:syncara/model/objectbox.g.dart';
import 'package:syncara/services/downloader_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../../models/playlist_item.dart';

class PlaylistProvider extends ChangeNotifier {
  final Store store;
  final _ytClient = yt.YoutubeExplode().playlists;
  final Playlist playlist;
  final List<PlaylistItem> items = List.of([]);
  final List<Media> medias = List.empty(growable: true);

  PlaylistProvider(this.store, this.playlist, {bool sync = true}) {
    final playlistItemBox = store.box<PlaylistItem>();

    final items = playlistItemBox.query(PlaylistItem_.playlist.equals(playlist.objectId))
            .order(PlaylistItem_.position)
            .build()
            .find();

    final box = store.box<Media>();
    for (final id in playlist.videoIds) {
      final media = box.query(Media_.id.equals(id)).build().findFirst();
      if (media != null) medias.add(media);
    }
    notifyListeners();
    if (sync) refresh();
  }

  Future<void> refresh() async {
    try {
      if (playlist.isLocal) {
        final files = playlist.localDir.listSync();
        final musics = files.map<Media?>((e) {
          try {
            final data = readMetadata(File(e.path));
            return Media.fromAudioMetadata(data);
          } catch (_) {
            return null;
          }
        });

        medias.clear();
        medias.addAll(musics.nonNulls);
        notifyListeners();
        return;
      }

      if (!await DownloaderService.hasInternet) return;

      final vids = await compute(
        (data) async {
          final ytClient = data[0] as yt.PlaylistClient;
          final videos = await ytClient.getVideos(data[1]).toList();
          return videos.map(Media.fromYTVideo);
        },
        [_ytClient, playlist.id],
      );

      medias.clear();
      medias.addAll(vids);

      // Update playlist
      playlist.videoIds.clear();
      playlist.videoIds.addAll(medias.map((m) => m.id));

      // Save to DB
      store.box<Playlist>().put(playlist);
      store.box<Media>().putMany(medias);
      notifyListeners();
    } catch (_) {
      //TODO Error
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
}
