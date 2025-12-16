import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncara/app/more/downloads/active_downloads_screen.dart';
import 'package:syncara/app/more/preferences/components/drag_handle.dart';
import 'package:syncara/clients/media_client.dart';
import 'package:syncara/data/models/media.dart';
import 'package:syncara/services/downloader_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../data/providers/playlist/playlist_provider.dart';

class MediaMenuSheet extends StatelessWidget {
  final Media media;

  const MediaMenuSheet(this.media, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DragHandle(),
          if (media.downloaded != true)
            ListTile(
              onTap: () {
                DownloaderService().download(media);
                Navigator.pop(context);
                ActiveDownloadsScreen.showEnqueuedSnackbar(context);
              },
              leading: const Icon(Icons.download_rounded),
              title: const Text("Download"),
            ),
          if (media.downloaded == true)
            ListTile(
              onTap: () {
                MediaClient().delete(media);
                context.read<PlaylistProvider>().notifyListeners();

                Navigator.pop(context);
              },
              leading: const Icon(Icons.delete_rounded),
              title: const Text("Delete"),
            ),
          ListTile(
            onTap: () {
              launchUrlString(media.url);
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
