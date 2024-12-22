import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myusync/model/objectbox.g.dart';
import 'package:myusync/model/playlist.dart';
import 'package:myusync/provider/library_provider.dart';
import 'package:myusync/provider/playlist_provider.dart';
import 'package:myusync/services/media_service.dart';

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
          //Drag Handle
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 4,
              width: kMinInteractiveDimension,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
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
        ],
      ),
    );
  }
}
