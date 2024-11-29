import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/library/library_menu_sheet.dart';
import 'package:tubesync/clients/media_client.dart';
import 'package:tubesync/model/playlist.dart';
import 'package:tubesync/provider/library_provider.dart';

class LibraryEntryBuilder extends StatelessWidget {
  final Playlist playlist;
  final void Function()? onTap;

  const LibraryEntryBuilder(this.playlist, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: ListTile(
        onTap: onTap,
        visualDensity: VisualDensity.comfortable,
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        leading: Hero(
          tag: playlist.id,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image(
              width: 80,
              height: double.maxFinite,
              errorBuilder: (_, __, ___) => SizedBox(
                width: 80,
                height: double.maxFinite,
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
              ),
              frameBuilder: (context, child, frame, synchronous) {
                if (synchronous) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: Durations.long4,
                  child: child,
                );
              },
              image: NetworkToFileImage(
                url: playlist.thumbnail.medium,
                file: MediaClient().thumbnailFile(playlist.thumbnail.medium),
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          playlist.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
        subtitle: Text(
          "${playlist.author} \u2022 ${playlist.videoCount} videos",
        ),
        trailing: IconButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            useSafeArea: true,
            useRootNavigator: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<LibraryProvider>(),
              child: LibraryMenuSheet(context.read<Isar>(), playlist),
            ),
          ),
          icon: const Icon(Icons.more_vert_rounded, size: 18),
        ),
      ),
    );
  }
}
