part of 'playlist_provider.dart';

mixin _YtPlaylistMixin {
  Store get store;

  Playlist get playlist;

  late final _box = store.box<PlaylistItem>();

  void notifyListeners();

  @visibleForOverriding
  void updateItems(List<PlaylistItem> items);

  final _ytClient = yt.YoutubeExplode().playlists;

  Future<void> refreshYoutubePlaylist() async {
    if (!await DownloaderService.hasInternet) return;

    final medias = await compute(
      (data) async {
        final ytClient = data[0] as yt.PlaylistClient;
        final videos = await ytClient.getVideos(data[1]).toList();
        return videos.map(Media.fromYTVideo);
      },
      [_ytClient, playlist.url],
    );

    final items = List<PlaylistItem>.of([]);
    final withExistingMediaIds = _withExistingMediaData(medias);
    for (final (i, media) in withExistingMediaIds.indexed) {
      items.add(
        PlaylistItem.create(position: i, media: media, playlist: playlist),
      );
    }

    updateItems(await _box.putAndGetManyAsync(items));
    notifyListeners();
  }

  List<Media> _withExistingMediaData(Iterable<Media> medias) {
    final urls = medias.map((e) => e.url).toList(growable: false);
    final query = store.box<Media>().query(Media_.url.oneOf(urls));

    // Map Url to Item
    final results = query.build().find().fold<Map<String, Media>>(
      {},
      (result, item) {
        result[item.url] = item;
        return result;
      },
    );

    final updatedItems = List<Media>.of([]);
    for (Media item in medias) {
      final existing = results[item.url];

      // Preserve necessary fields
      if (existing != null) {
        item = item.copyWith(localPath: existing.localPath);
        item.objectId = existing.objectId;
      }

      updatedItems.add(item);
    }

    return updatedItems;
  }
}
