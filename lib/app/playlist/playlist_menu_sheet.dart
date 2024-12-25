import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncara/app/more/downloads/active_downloads_screen.dart';
import 'package:syncara/app/more/preferences/components/drag_handle.dart';
import 'package:syncara/provider/playlist_provider.dart';
import 'package:syncara/services/downloader_service.dart';
import 'package:syncara/services/media_service.dart';

class PlaylistMenuSheet extends StatelessWidget {
  const PlaylistMenuSheet({super.key});

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
                MediaService().enqueue(context.read<PlaylistProvider>());
                Navigator.pop(context);
              },
              leading: const Icon(Icons.playlist_add_rounded),
              title: const Text("Enqueue"),
            ),
          ListTile(
            onTap: () {
              DownloaderService().downloadAll(
                context.read<PlaylistProvider>().medias,
              );
              ActiveDownloadsScreen.showEnqueuedSnackbar(context);
              Navigator.pop(context);
            },
            leading: const Icon(Icons.download_rounded),
            title: const Text("Download All"),
          ),
        ],
      ),
    );
  }
}
