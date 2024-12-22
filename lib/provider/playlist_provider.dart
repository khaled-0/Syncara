import 'package:flutter/foundation.dart';
import 'package:myusync/clients/media_client.dart';
import 'package:myusync/model/media.dart';
import 'package:myusync/model/objectbox.g.dart';
import 'package:myusync/model/playlist.dart';
import 'package:myusync/services/downloader_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class PlaylistProvider extends ChangeNotifier {
  final Store store;
  final _ytClient = yt.YoutubeExplode().playlists;
  final Playlist playlist;
  final List<Media> medias = List.empty(growable: true);

  PlaylistProvider(this.store, this.playlist, {bool sync = true}) {
    for (final id in playlist.videoIds) {
      final media =
          store.box<Media>().query(Media_.id.equals(id)).build().findFirst();
      if (media != null) medias.add(media);
    }
    updateDownloadStatus();
    notifyListeners();
    if (sync) refresh();
  }

  Future<void> refresh() async {
    try {
      if (!await DownloaderService.hasInternet) {
        updateDownloadStatus();
        notifyListeners();
        return;
      }

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
      updateDownloadStatus();
      notifyListeners();
    } catch (_) {
      //TODO Error
    }
  }

  void updateDownloadStatus({Media? media}) {
    if (media != null) {
      media.downloaded = MediaClient().isDownloaded(media);
      return;
    }

    for (final media in medias) {
      media.downloaded = MediaClient().isDownloaded(media);
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
