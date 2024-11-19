import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/app_theme.dart';
import 'package:tubesync/app/player/mini_player_sheet.dart';
import 'package:tubesync/app/playlist/media_entry_builder.dart';
import 'package:tubesync/app/playlist/playlist_header.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/model/playlist.dart';
import 'package:tubesync/provider/player_provider.dart';
import 'package:tubesync/provider/playlist_provider.dart';

class PlaylistTab extends StatelessWidget {
  const PlaylistTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      body: Consumer<PlaylistProvider>(
        child: PlaylistHeader(
          playAll: () => launchPlayer(context: context),
          shufflePlay: () {
            launchPlayer(
              context: context,
              playlist: context.read<PlaylistProvider>().playlist,
              prepare: (playlist) => playlist.medias.shuffle(),
            );
          },
        ),
        builder: (context, playlist, header) {
          if (AppTheme.isDesktop) {
            return RefreshIndicator(
              onRefresh: playlist.refresh,
              child: Row(
                children: [
                  Flexible(flex: 3, child: header!),
                  Flexible(
                    flex: 5,
                    child: playlistView(context, playlist),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: playlist.refresh,
            child: playlistView(context, playlist, header: header),
          );
        },
      ),
    );
  }

  Widget playlistView(
    BuildContext context,
    PlaylistProvider playlist, {
    Widget? header,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight * 2),
      itemCount: playlist.medias.length + (header != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (header != null && index == 0) return header;
        final media = playlist.medias[index - (header != null ? 1 : 0)];
        return MediaEntryBuilder(
          media,
          onTap: () => launchPlayer(context: context, initialMedia: media),
        );
      },
    );
  }

  static void launchPlayer({
    required BuildContext context,
    Playlist? playlist,
    Media? initialMedia,

    /// Used to modify playlist beforehand, e.g shuffle
    void Function(PlaylistProvider playlist)? prepare,
  }) {
    // Create copy to avoid mutating original playlist
    final playlistCopy = PlaylistProvider(
      context.read<Isar>(),
      playlist ?? context.read<PlaylistProvider>().playlist,
      sync: false,
    );
    prepare?.call(playlistCopy);

    _scaffoldOf(context)?.showBottomSheet(
      (_) => ChangeNotifierProvider<PlayerProvider>(
        create: (_) => PlayerProvider(
          context.read<Isar>(),
          playlistCopy,
          start: initialMedia,
        ),
        child: const MiniPlayerSheet(),
      ),
      enableDrag: true,
      shape: InputBorder.none,
      elevation: 0,
    );
  }

  static ScaffoldState? _scaffoldOf(BuildContext context) =>
      context.read<GlobalKey<ScaffoldState>>().currentState;
}
