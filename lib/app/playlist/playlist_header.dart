import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/app_theme.dart';
import 'package:tubesync/app/playlist/playlist_menu_sheet.dart';
import 'package:tubesync/model/playlist.dart';
import 'package:tubesync/provider/playlist_provider.dart';
import 'package:tubesync/services/media_service.dart';

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
        child: Column(
          mainAxisSize: adaptiveMainAxisSize,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      errorBuilder: (_, __, ___) => const SizedBox(height: 120),
                      image: NetworkToFileImage(
                        url: playlist(context).thumbnail.high,
                        file: MediaService().thumbnailFile(
                          playlist(context).thumbnail.high,
                        ),
                      ),
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
            if (AppTheme.isDesktop) Row(children: actionButtons)
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
      onPressed: () => showModalBottomSheet(
        context: context,
        useSafeArea: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ChangeNotifierProvider.value(
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

  MainAxisSize get adaptiveMainAxisSize {
    return AppTheme.isDesktop ? MainAxisSize.max : MainAxisSize.min;
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
        Text(playlist(context).title, style: titleStyle, maxLines: 1),
        Text(
          "${playlist(context).videoCount} videos \u2022 by ${playlist(context).author}",
          style: bodyStyle,
          maxLines: 1,
        ),
      ],
    );
  }

  Playlist playlist(BuildContext context) =>
      context.read<PlaylistProvider>().playlist;
}
