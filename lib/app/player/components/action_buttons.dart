import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/player/components/player_menu_sheet.dart';
import 'package:tubesync/extensions.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/provider/player_provider.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<PlayerProvider>().player.playerStateStream,
      initialData: context.read<PlayerProvider>().player.playerState,
      builder: (context, playerState) => Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 12,
            child: _sleepTimerIndicator(context),
          ),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 18,
              children: [
                _previousButton(context),
                _playPauseButton(context, playerState),
                _nextButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previousButton(BuildContext context) {
    bool hasPre = context.read<PlayerProvider>().hasPrevious;
    return Selector<PlayerProvider, List<Media>>(
      selector: (_, provider) => provider.playlist,
      child: const Icon(Icons.skip_previous_rounded),
      builder: (_, __, icon) => IconButton(
        onPressed: hasPre ? context.read<PlayerProvider>().previousTrack : null,
        icon: icon!,
      ),
    );
  }

  Widget _nextButton(BuildContext context) {
    bool hasNext = context.read<PlayerProvider>().hasNext;
    return Selector<PlayerProvider, List<Media>>(
      selector: (_, provider) => provider.playlist,
      child: const Icon(Icons.skip_next_rounded),
      builder: (_, __, icon) => IconButton(
        onPressed: hasNext ? context.read<PlayerProvider>().nextTrack : null,
        icon: icon!,
      ),
    );
  }

  Widget _playPauseButton(
      BuildContext context, AsyncSnapshot<PlayerState> playerState) {
    return Selector<PlayerProvider, bool>(
      selector: (_, provider) => provider.buffering,
      builder: (_, loading, child) => FloatingActionButton(
        heroTag: "PlayButtonLarge",
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
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _sleepTimerIndicator(BuildContext context) {
    return AnimatedSize(
      duration: Durations.short3,
      child: StreamBuilder(
        stream: context.read<PlayerProvider>().sleepTimerCountdown,
        initialData: context.read<PlayerProvider>().sleepTimer,
        builder: (context, snapshot) {
          final sleepTimer = snapshot.data;
          if (sleepTimer == null) return const SizedBox();
          return FilledButton.tonalIcon(
            onPressed: () => PlayerMenuSheet.setSleepTimerPopup(context),
            icon: const Icon(Icons.bedtime_rounded),
            label: Text(sleepTimer.formatHHMM()),
          );
        },
      ),
    );
  }
}
