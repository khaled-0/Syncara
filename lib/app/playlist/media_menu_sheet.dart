import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncara/app/more/downloads/active_downloads_screen.dart';
import 'package:syncara/clients/media_client.dart';
import 'package:syncara/model/media.dart';
import 'package:syncara/provider/playlist_provider.dart';
import 'package:syncara/services/downloader_service.dart';

class MediaMenuSheet extends StatelessWidget {
  final Media media;

  const MediaMenuSheet(this.media, {super.key});

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
                context.read<PlaylistProvider>()
                  ..updateDownloadStatus(media: media)
                  ..notifyListeners();

                Navigator.pop(context);
              },
              leading: const Icon(Icons.delete_rounded),
              title: const Text("Delete"),
            )
        ],
      ),
    );
  }
}
