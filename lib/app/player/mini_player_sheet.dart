import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:provider/provider.dart';
import 'package:syncara/app/app_theme.dart';
import 'package:syncara/app/player/components/player_state_indicator.dart';
import 'package:syncara/app/player/large_player_sheet.dart';
import 'package:syncara/clients/media_client.dart';
import 'package:syncara/model/media.dart';
import 'package:syncara/model/objectbox.g.dart';
import 'package:syncara/model/preferences.dart';
import 'package:syncara/provider/player_provider.dart';

class MiniPlayerSheet extends StatelessWidget {
  const MiniPlayerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key("MiniPlayer"),
      confirmDismiss: (direction) async {
        switch (direction) {
          case DismissDirection.startToEnd:
            context.read<PlayerProvider>().previousTrack();
            return false;

          case DismissDirection.endToStart:
            context.read<PlayerProvider>().nextTrack();
            return false;

          default:
            return false;
        }
      },
      direction: DismissDirection.horizontal,
      background: const Row(
        children: [
          SizedBox(width: 18),
          Icon(Icons.skip_previous_rounded),
        ],
      ),
      secondaryBackground: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.skip_next_rounded),
          SizedBox(width: 18),
        ],
      ),
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.2,
        DismissDirection.endToStart: 0.2,
      },
      child: ValueListenableBuilder(
        key: const ValueKey("NowPlaying"),
        valueListenable: context.read<PlayerProvider>().nowPlaying,
        builder: (context, nowPlaying, _) {
          return Column(
            key: ValueKey(nowPlaying.hashCode),
            mainAxisSize: MainAxisSize.min,
            children: [
              mediaDetails(context, nowPlaying),
              // Progress Indicator
              Selector<PlayerProvider, bool>(
                selector: (_, provider) => provider.buffering,
                builder: (_, buffering, __) => StreamBuilder<Duration>(
                  stream: context.read<PlayerProvider>().player.positionStream,
                  builder: (context, snapshot) {
                    double? progress;
                    final duration = nowPlaying.durationMs;
                    if (!buffering && duration != null && snapshot.hasData) {
                      progress = snapshot.requireData.inMilliseconds / duration;
                    }

                    return StreamBuilder(
                      stream: context.read<PlayerProvider>().player.speedStream,
                      initialData: context.read<PlayerProvider>().player.speed,
                      builder: (_, speed) => LinearProgressIndicator(
                        minHeight: adaptiveIndicatorHeight,
                        color: speed.data == 1.0 ? null : Colors.redAccent,
                        value: progress,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double get adaptiveIndicatorHeight {
    return AppTheme.isDesktop ? 3 : 1.5;
  }

  Widget mediaDetails(BuildContext context, Media media) {
    return ListTile(
      onTap: () => openPlayerSheet(context),
      contentPadding: const EdgeInsets.only(left: 8, right: 4),
      leading: leading(context, media),
      titleTextStyle: Theme.of(context).textTheme.bodyMedium,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            media.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            media.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Selector<PlayerProvider, List<Media>>(
            selector: (_, provider) => provider.playlist,
            builder: (context, playlist, _) => Text(
              "${playlist.indexOf(media) + 1}/${playlist.length}"
              " \u2022 ${playlistInfo(context)}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
      //Player Actions
      trailing: actions(context),
    );
  }

  Widget actions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Selector<PlayerProvider, bool>(
          selector: (_, provider) => provider.buffering,
          builder: (context, buffering, _) {
            if (buffering) return const SizedBox();
            return StreamBuilder(
              stream: context.read<PlayerProvider>().player.playerStateStream,
              builder: (context, state) {
                if (state.data?.playing == true) {
                  return IconButton(
                    onPressed: context.read<PlayerProvider>().player.pause,
                    icon: const Icon(Icons.pause_rounded),
                  );
                }
                return IconButton(
                  onPressed: context.read<PlayerProvider>().player.play,
                  icon: const Icon(Icons.play_arrow_rounded),
                );
              },
            );
          },
        ),
        _secondaryAction(context),
      ],
    );
  }

  Widget leading(BuildContext context, Media media) {
    return StreamBuilder(
      stream: context.read<PlayerProvider>().sleepTimerCountdown,
      initialData: context.read<PlayerProvider>().sleepTimer,
      builder: (context, snapshot) => CircleAvatar(
        radius: 24,
        backgroundImage: NetworkToFileImage(
          url: media.thumbnailStd,
          file: MediaClient().thumbnailFile(media.thumbnailStd),
        ),
        child: const PlayerStateIndicator.static(),
      ),
    );
  }

  Widget _secondaryAction(BuildContext context) {
    final action = context
        .read<Store>()
        .box<Preferences>()
        .value<int>(Preference.miniPlayerSecondaryAction);

    switch (MiniPlayerSecondaryActions.values[action]) {
      case MiniPlayerSecondaryActions.Close:
        return IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        );
      case MiniPlayerSecondaryActions.Shuffle:
        return IconButton(
          onPressed: () => context.read<PlayerProvider>().shuffle(
                preserveCurrentIndex: false,
              ),
          icon: const Icon(Icons.shuffle_rounded),
        );
      case MiniPlayerSecondaryActions.None:
        return const SizedBox();
    }
  }

  void openPlayerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      barrierColor: adaptiveSheetBarrierColor,
      builder: (_) => MultiProvider(
        providers: [
          Provider.value(value: context.read<Store>()),
          ChangeNotifierProvider<PlayerProvider>.value(
            value: context.read<PlayerProvider>(),
          ),
        ],
        child: const LargePlayerSheet(),
      ),
    );
  }

  Color? get adaptiveSheetBarrierColor {
    if (AppTheme.isDesktop) return null;
    return Colors.transparent;
  }

  String playlistInfo(BuildContext context) {
    final playlist = context.read<PlayerProvider>().playlistInfo;
    if (playlist.length == 1) {
      return "${playlist[0].title} by ${playlist[0].author}";
    }

    return "${playlist[0].title} and ${playlist.length - 1} more";
  }
}

// ignore: constant_identifier_names
enum MiniPlayerSecondaryActions { Close, Shuffle, None }
