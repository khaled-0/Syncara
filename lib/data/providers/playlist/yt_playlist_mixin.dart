part of 'playlist_provider.dart';

mixin _YtPlaylistMixin {
  Store get store;

  Playlist get playlist;

  late final _box = store.box<PlaylistItem>();

  void notifyListeners();

  @visibleForOverriding
  void updateItems(List<PlaylistItem> items);

  Future<void> refreshYoutubePlaylist() async {
    if (!await DownloaderService.hasInternet) return;

    final medias = await compute(
      (data) async {
        final ytClient = yt.YoutubeExplode(
          httpClient: YTCookieClient(cookies: data[1] as List<Cookie>),
        ).playlists;
        final videos = await ytClient.getVideos(data[0]).toList();
        return videos.map(Media.fromYTVideo).toList();
      },
      [playlist.url, await YTCookieClient.values],
    );

    final items = List<PlaylistItem>.of([]);

    final existingMedias = store.box<Media>().query(
      Media_.url.oneOf(medias.map((e) => e.url).toList()),
    );

    for (final existing in existingMedias.build().find()) {
      final index = medias.indexWhere((e) => e.url == existing.url);
      if (index == -1) continue;
      medias[index].objectId = existing.objectId;
    }

    for (final (i, media) in medias.indexed) {
      items.add(
        PlaylistItem.create(position: i, media: media, playlist: playlist),
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

    updateItems(await _box.putAndGetManyAsync(items));
    notifyListeners();
  }
}
