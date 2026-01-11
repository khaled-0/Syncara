part of 'playlist_provider.dart';

mixin _YtPlaylistMixin {
  Store get store;

  Playlist get playlist;

  late final _box = store.box<PlaylistItem>();

  void notifyListeners();

  @visibleForOverriding
  Future<void> updateMediaEntries(List<Media> medias);

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

    await updateMediaEntries(medias);
    return notifyListeners();
  }
}
