import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncara/app/more/preferences/components/drag_handle.dart';
import 'package:syncara/model/objectbox.g.dart';
import 'package:syncara/model/playlist.dart';
import 'package:syncara/provider/library_provider.dart';
import 'package:syncara/provider/playlist_provider.dart';
import 'package:syncara/services/media_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LibraryMenuSheet extends StatelessWidget {
  final Playlist playlist;
  final Store store;

  const LibraryMenuSheet(this.store, this.playlist, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DragHandle(),
          if (MediaService().isPlayerActive)
            ListTile(
              onTap: () {
                MediaService().enqueue(
                  PlaylistProvider(store, playlist, sync: false),
                );
                Navigator.pop(context);
              },
              leading: const Icon(Icons.playlist_add_rounded),
              title: const Text("Enqueue"),
            ),
          ListTile(
            onTap: () {
              context.read<LibraryProvider>().delete(playlist);
              Navigator.pop(context);
            },
            leading: const Icon(Icons.delete_rounded),
            title: const Text("Delete"),
          ),
          ListTile(
            onTap: () {
              launchUrlString(playlist.externalURL);
              Navigator.pop(context);
            },
            leading: const Icon(Icons.open_in_new_rounded),
            title: const Text("Open in External App"),
          ),
        ],
      ),
    );
  }
}
