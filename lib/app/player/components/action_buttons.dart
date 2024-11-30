import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/provider/player_provider.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
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
}
