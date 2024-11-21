import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/player/components/artwork.dart';
import 'package:tubesync/app/player/components/seekbar.dart';
import 'package:tubesync/app/player/player_queue_sheet.dart';
import 'package:tubesync/extensions.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/provider/player_provider.dart';
import 'package:window_manager/window_manager.dart';

class LargePlayerSheet extends StatefulWidget {
  const LargePlayerSheet({super.key});

  @override
  State<LargePlayerSheet> createState() => _LargePlayerSheetState();
}

class _LargePlayerSheetState extends State<LargePlayerSheet>
    with TickerProviderStateMixin {
  late final tabController = TabController(length: 3, vsync: this)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const RotatedBox(
            quarterTurns: -1, // Negative 90 Deg
            child: Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        title: DragToMoveArea(
          child: Image.asset(
            "assets/tubesync.png",
            height: 30,
            fit: BoxFit.contain,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                label: Text('Music'),
                icon: Icon(Icons.art_track_rounded),
              ),
              ButtonSegment(
                value: 1,
                label: Text('Lyrics'),
                icon: Icon(Icons.lyrics_rounded),
              ),
              ButtonSegment(
                value: 2,
                label: Text('Video'),
                icon: Icon(Icons.play_circle_fill_rounded),
              ),
            ],
            showSelectedIcon: false,
            selected: {tabController.index},
            onSelectionChanged: (value) => setState(
              () => tabController.animateTo(value.first),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                const Artwork(),
                const Center(child: Text("Soon")),
                const Center(child: Text("Soon")),
              ],
            ),
          ),
          seekBarView(context),
          const SizedBox(height: 12),
          actionsView(context),
          const SizedBox(height: 36),
          queueView(context),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget queueView(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.read<PlayerProvider>().nowPlaying,
      builder: (context, media, _) {
        return Card.outlined(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: ListTile(
            onTap: showPlayerQueue,
            title: Text(
              media.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  media.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Selector<PlayerProvider, List<Media>>(
                  selector: (_, provider) => provider.playlist,
                  builder: (context, playlist, _) => Text(
                    "${playlist.indexOf(media) + 1}/${playlist.length}"
                    " \u2022 ${playlistInfo(context)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
            leading: const Icon(Icons.playlist_play_rounded),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          ),
        );
      },
    );
  }

  Widget seekBarView(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.read<PlayerProvider>().nowPlaying,
      builder: (context, media, _) => StreamBuilder<Duration>(
        stream: context.read<PlayerProvider>().player.positionStream,
        builder: (context, currentPosition) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            children: [
              SizedBox(
                width: currentPosition.data?.inHours == 0 ? 48 : 72,
                child: Text(currentPosition.data.formatHHMM()),
              ),
              Expanded(
                child: Selector<PlayerProvider, bool>(
                  selector: (_, provider) => provider.buffering,
                  builder: (context, buffering, child) {
                    if (media.duration == null) return const SizedBox();
                    final player = context.read<PlayerProvider>().player;
                    return SeekBar(
                      buffering: buffering,
                      duration: media.duration!,
                      position: currentPosition.data ?? Duration.zero,
                      bufferedPosition: player.bufferedPosition,
                      onChangeEnd: (v) => player.seek(v),
                    );
                  },
                ),
              ),
              SizedBox(
                width: media.duration?.inHours == 0 ? 48 : 72,
                child: Text(media.duration.formatHHMM()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget actionsView(BuildContext context) {
    return StreamBuilder(
      stream: context.read<PlayerProvider>().player.playerStateStream,
      initialData: context.read<PlayerProvider>().player.playerState,
      builder: (context, playerState) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Selector<PlayerProvider, List<Media>>(
            selector: (_, provider) => provider.playlist,
            child: const Icon(Icons.skip_previous_rounded),
            builder: (_, __, icon) => IconButton(
              onPressed: context.read<PlayerProvider>().hasPrevious
                  ? context.read<PlayerProvider>().previousTrack
                  : null,
              icon: icon!,
            ),
          ),
          const SizedBox(width: 30),
          Selector<PlayerProvider, bool>(
            selector: (_, provider) => provider.buffering,
            builder: (_, loading, child) => FloatingActionButton(
              elevation: 0,
              highlightElevation: 1,
              hoverElevation: 1,
              focusElevation: 1,
              onPressed: loading
                  ? null
                  : switch (playerState.requireData.playing) {
                      true => context.read<PlayerProvider>().player.pause,
                      false => context.read<PlayerProvider>().player.play,
                    },
              child: loading
                  ? child
                  : switch (playerState.requireData.playing) {
                      true => const Icon(Icons.pause_rounded),
                      false => const Icon(Icons.play_arrow_rounded),
                    },
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          const SizedBox(width: 30),
          Selector<PlayerProvider, List<Media>>(
            selector: (_, provider) => provider.playlist,
            child: const Icon(Icons.skip_next_rounded),
            builder: (context, _, icon) => IconButton(
              onPressed: context.read<PlayerProvider>().hasNext
                  ? context.read<PlayerProvider>().nextTrack
                  : null,
              icon: icon!,
            ),
          ),
        ],
      ),
    );
  }

  void showPlayerQueue() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PlayerProvider>(),
        child: const PlayerQueueSheet(),
      ),
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
    );
  }

  String playlistInfo(BuildContext context) {
    final playlist = context.read<PlayerProvider>().playlistInfo;
    if (playlist.length == 1) {
      return "${playlist[0].title} by ${playlist[0].author}";
    }

    return "${playlist[0].title} and ${playlist.length - 1} more";
  }
}
