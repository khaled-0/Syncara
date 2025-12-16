import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:syncara/app/app_theme.dart';
import 'package:syncara/data/models/media.dart';
import 'package:syncara/provider/player_provider.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<PlayerProvider>().player.playerStateStream,
      initialData: context.read<PlayerProvider>().player.playerState,
      builder: (context, playerState) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 18,
        children: [
          if (!AppTheme.isDesktop) rewindButton(context),
          _previousButton(context),
          _playPauseButton(context, playerState),
          _nextButton(context),
          if (!AppTheme.isDesktop) forwardButton(context),
        ],
      ),
    );
  }

  static Widget forwardButton(BuildContext context) {
    return IconButton(
      onPressed: context.read<PlayerProvider>().seekForward,
      icon: const Icon(Icons.forward_10_rounded),
    );
  }

  static Widget rewindButton(BuildContext context) {
    return IconButton(
      onPressed: context.read<PlayerProvider>().seekBackward,
      icon: const Icon(Icons.replay_10_rounded),
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
}
