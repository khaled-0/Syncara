part of 'playlist_provider.dart';

mixin _YtPlaylistMixin {
  Store get store;

  Playlist get playlist;

  late final _box = store.box<PlaylistItem>();

  void notifyListeners();

  @visibleForOverriding
  void updateItems(List<PlaylistItem> items);

  final _ytClient = GetIt.I<yt.YoutubeExplode>().playlists;

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
    for (final (i, media) in medias.indexed) {
      items.add(
        PlaylistItem.create(position: i, media: media, playlist: playlist),
      );
    }

    updateItems(await _box.putAndGetManyAsync(items));
    notifyListeners();
  }
}
