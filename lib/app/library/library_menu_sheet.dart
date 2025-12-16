import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncara/app/more/preferences/components/drag_handle.dart';
import 'package:syncara/model/objectbox.g.dart';
import 'package:syncara/data/models/playlist.dart';
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
            onTap: () => showRenamePlaylist(context),
            leading: const Icon(Icons.drive_file_rename_outline_rounded),
            title: const Text("Rename"),
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

  void showRenamePlaylist(BuildContext context) async {
    final name = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        String name = playlist.customTitle ?? "";
        return AlertDialog(
          title: Text("Rename ${playlist.title}"),
          icon: const Icon(Icons.drive_file_rename_outline_rounded),
          content: TextFormField(
            maxLines: 1,
            initialValue: name,
            decoration: const InputDecoration(
              helperText: "Define a custom title for the playlist here",
              helperMaxLines: 2,
            ),
            onChanged: (value) => name = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Clear"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, playlist.customTitle),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, name),
              child: const Text("Save"),
            )
          ],
        );
      },
    );
    if (!context.mounted) return;
    context.read<LibraryProvider>().renamePlaylist(playlist, name: name);
    Navigator.pop(context);
  }
}
