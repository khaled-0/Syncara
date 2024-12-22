import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myusync/app/library/empty_library_view.dart';
import 'package:myusync/app/library/import_playlist_dialog.dart';
import 'package:myusync/app/library/library_entry_builder.dart';
import 'package:myusync/app/playlist/playlist_tab.dart';
import 'package:myusync/model/common.dart';
import 'package:myusync/model/objectbox.g.dart';
import 'package:myusync/model/preferences.dart';
import 'package:myusync/provider/library_provider.dart';
import 'package:myusync/provider/playlist_provider.dart';
import 'package:myusync/services/media_service.dart';

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      body: Consumer<LibraryProvider>(
        builder: (context, library, _) {
          if (library.entries.isEmpty) return const EmptyLibraryView();
          return RefreshIndicator(
            onRefresh: library.refresh,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: kBottomNavigationBarHeight * 2,
              ),
              itemCount: library.entries.length,
              itemBuilder: (context, index) {
                final playlist = library.entries[index];
                return LibraryEntryBuilder(
                  playlist,
                  onTap: () => Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: const Offset(0.0, 1.0),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.ease)),
                          ),
                          child: child,
                        );
                      },
                      pageBuilder: (context, _, __) {
                        return ChangeNotifierProvider<PlaylistProvider>(
                          child: const PlaylistTab(),
                          create: (_) => PlaylistProvider(
                            context.read<Store>(),
                            playlist,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: StreamBuilder<PlaybackState>(
        stream: MediaService().playbackState.stream,
        builder: (_, state) {
          if (!MediaService().isPlayerActive) {
            final hasResumeData = context
                .read<Store>()
                .box<Preferences>()
                .exists(Preference.lastPlayed);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                importFab(context, mini: hasResumeData),
                if (hasResumeData) ...{
                  const SizedBox(height: 16),
                  resumeFab(context),
                }
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.only(
              bottom: kBottomNavigationBarHeight * 1.25,
            ),
            child: importFab(context, mini: true),
          );
        },
      ),
    );
  }

  FloatingActionButton importFab(BuildContext context, {bool mini = false}) {
    void onPressed() => showDialog(
          context: context,
          useRootNavigator: true,
          barrierDismissible: false,
          builder: (_) => ChangeNotifierProvider.value(
            value: context.read<LibraryProvider>(),
            child: const ImportPlaylistDialog(),
          ),
        );

    if (mini) {
      return FloatingActionButton.small(
        heroTag: "ImportButton",
        onPressed: onPressed,
        child: const Icon(Icons.add_rounded),
      );
    }

    return FloatingActionButton.extended(
      heroTag: "ImportButton",
      onPressed: onPressed,
      label: const Text("Import"),
      icon: const Icon(Icons.add_rounded),
    );
  }

  FloatingActionButton resumeFab(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: "ResumeButton",
      onPressed: () => resumePlayback(context),
      label: const Text("Resume"),
      icon: const Icon(Icons.play_arrow_rounded),
    );
  }

  void resumePlayback(BuildContext context) {
    final prefs = context.read<Store>().box<Preferences>();
    try {
      final resumeData = prefs.value<LastPlayedMedia>(Preference.lastPlayed);

      final library = context.read<LibraryProvider>().entries;
      final playlist = PlaylistProvider(
        context.read<Store>(),
        library.firstWhere((e) => e.id == resumeData.playlistId),
      );

      final media = playlist.medias.firstWhere(
        (e) => e.id == resumeData.mediaId,
      );

      PlaylistTab.launchPlayer(
        context: context,
        initialMedia: media,
        playlist: playlist,
      );
    } catch (_) {
      prefs.delete(Preference.lastPlayed);
      MediaService().playbackState.add(
            MediaService().playbackState.value.copyWith(),
          );
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text("Unable to resume")),
      );
    }
  }
}
