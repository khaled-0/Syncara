import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:provider/provider.dart';
import 'package:syncara/app/app_theme.dart';
import 'package:syncara/app/playlist/playlist_menu_sheet.dart';
import 'package:syncara/clients/media_client.dart';
import 'package:syncara/data/models/playlist.dart';
import 'package:syncara/provider/playlist_provider.dart';

class PlaylistHeader extends StatelessWidget {
  const PlaylistHeader({
    super.key,
    required this.playAll,
    required this.shufflePlay,
  });

  final void Function() playAll;
  final void Function() shufflePlay;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(adaptivePadding),
        child: ListView(
          shrinkWrap: !AppTheme.isDesktop,
          physics: adaptivePhysics,
          children: [
            Hero(
              tag: playlist(context).id,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image(
                      height: AppTheme.isDesktop ? 240 : 120,
                      width: double.maxFinite,
                      errorBuilder: (_, _, _) => const SizedBox(height: 120),
                      image: thumb(context),
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (!AppTheme.isDesktop) ...{
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black38,
                              Colors.black54,
                              Colors.black87,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomLeft,
                            stops: [0, 0.3, 0.6, 0.7, 1],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: playlistInfo(context),
                    ),
                    if (playlist(context).description != null)
                      Positioned(
                        right: 8,
                        bottom: 16,
                        child: IconButton.filledTonal(
                          onPressed: () => showDescription(context),
                          icon: const Icon(Icons.menu_open_rounded),
                        ),
                      ),
                  },
                ],
              ),
            ),
            SizedBox(height: adaptivePadding),
            if (AppTheme.isDesktop) ...{
              Row(
                children: [
                  backButton(context),
                  SizedBox(width: adaptivePadding),
                  Expanded(child: playlistInfo(context)),
                  SizedBox(width: adaptivePadding),
                  menuButton(context),
                ],
              ),
              SizedBox(height: adaptivePadding),
            },
            // Action Buttons Mobile
            if (!AppTheme.isDesktop)
              Row(
                children: [
                  backButton(context),
                  SizedBox(width: adaptivePadding),
                  ...actionButtons,
                  SizedBox(width: adaptivePadding),
                  menuButton(context),
                ],
              ),
            SizedBox(height: adaptivePadding),
            if (AppTheme.isDesktop) ...{
              Row(children: actionButtons),
              SizedBox(height: adaptivePadding),
              Text(playlist(context).description ?? ""),
            },
          ],
        ),
      ),
    );
  }

  Widget backButton(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: () => Navigator.maybePop(context),
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
    );
  }

  Widget menuButton(BuildContext context) {
    return IconButton.filledTonal(
      onPressed:
          () => showModalBottomSheet(
            context: context,
            useSafeArea: true,
            useRootNavigator: true,
            backgroundColor: Colors.transparent,
            builder:
                (_) => ChangeNotifierProvider.value(
                  value: context.read<PlaylistProvider>(),
                  child: const PlaylistMenuSheet(),
                ),
          ),
      icon: const Icon(Icons.more_horiz_rounded),
    );
  }

  List<Widget> get actionButtons {
    return [
      Expanded(
        child: FilledButton.tonalIcon(
          onPressed: playAll,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text(
            "Play",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: shufflePlay,
          icon: const Icon(Icons.shuffle_rounded),
          label: const Text(
            "Shuffle",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ];
  }

  ScrollPhysics? get adaptivePhysics {
    return AppTheme.isDesktop ? null : const NeverScrollableScrollPhysics();
  }

  double get adaptivePadding {
    return AppTheme.isDesktop ? 12 : 8;
  }

  Widget playlistInfo(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: AppTheme.isDesktop ? null : Colors.white,
    );

    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AppTheme.isDesktop ? null : Colors.white,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(playlist(context).displayTitle, style: titleStyle, maxLines: 1),
        Text(
          "${playlist(context).itemCount} videos \u2022 by ${playlist(context).author}",
          style: bodyStyle,
          maxLines: 1,
        ),
      ],
    );
  }

  void showDescription(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (c) => AlertDialog(
            title: Text(playlist(context).displayTitle),
            content: SingleChildScrollView(
              child: Text(playlist(context).description!),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text("Dismiss"),
              ),
            ],
          ),
    );
  }

  Playlist playlist(BuildContext context) =>
      context.read<PlaylistProvider>().playlist;

  ImageProvider thumb(BuildContext context) {
    if (playlist(context).isLocal) {
      return FileImage(playlist(context).localThumb);
    }

    return NetworkToFileImage(
      url: playlist(context).thumbnailHiRes,
      file: MediaClient().thumbnailFile(
        playlist(context).thumbnailHiRes.split("?")[0],
      ),
    );
  }
}
