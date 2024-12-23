import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:provider/provider.dart';
import 'package:syncara/app/playlist/media_menu_sheet.dart';
import 'package:syncara/clients/media_client.dart';
import 'package:syncara/extensions.dart';
import 'package:syncara/model/media.dart';
import 'package:syncara/provider/playlist_provider.dart';

class MediaEntryBuilder extends StatelessWidget {
  final Media media;
  final void Function()? onTap;
  final Widget? trailing;
  final bool selected;

  const MediaEntryBuilder(
    this.media, {
    super.key,
    this.onTap,
    this.trailing,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      selected: selected,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      trailing: trailing ?? menuButton(context),
      leading: Stack(
        children: [
          ClipRRect(
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
                url: media.thumbnailStd,
                file: MediaClient().thumbnailFile(
                  media.thumbnailStd,
                ),
              ),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                media.duration.formatHHMM(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
      title: Text(
        media.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      titleTextStyle: Theme.of(context).textTheme.titleSmall,
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            TextSpan(
              children: [
                if (media.downloaded == true)
                  const WidgetSpan(
                    child: Padding(
                      padding: EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.download_for_offline_rounded,
                        size: 16,
                      ),
                    ),
                  ),
                TextSpan(text: media.author),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget menuButton(BuildContext context) {
    return IconButton(
      onPressed: () => showModalBottomSheet(
        context: context,
        useSafeArea: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<PlaylistProvider>(),
          child: MediaMenuSheet(media),
        ),
      ),
      icon: const Icon(Icons.more_vert_rounded, size: 18),
    );
  }
}
