import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/model/playlist.dart';
import 'package:tubesync/services/downloader_service.dart';
import 'package:tubesync/services/media_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class PlaylistProvider extends ChangeNotifier {
  final Isar isar;
  final _ytClient = yt.YoutubeExplode().playlists;
  final Playlist playlist;
  final List<Media> medias = List.empty(growable: true);

  PlaylistProvider(this.isar, this.playlist, {bool sync = true}) {
    for (final id in playlist.videoIds) {
      final media = isar.medias.where().idEqualTo(id).findFirst();
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
      isar.writeAsyncWith(playlist, (db, data) => db.playlists.put(data));
      isar.writeAsyncWith(medias, (db, data) => db.medias.putAll(data));
      updateDownloadStatus();
      notifyListeners();
    } catch (_) {
      //TODO Error
    }
  }

  void shuffle() {
    medias.shuffle();
    notifyListeners();
  }

  void updateDownloadStatus({Media? media}) {
    if (media != null) {
      media.downloaded = MediaService().isDownloaded(media);
      return;
    }

    for (final media in medias) {
      media.downloaded = MediaService().isDownloaded(media);
    }
  }

  void reorderList(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;

    final item = medias.removeAt(oldIndex);
    medias.insert(newIndex, item);
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
