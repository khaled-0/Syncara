import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:syncara/extensions.dart';

import '../../../data/providers/player_provider.dart';

class SeekBar extends StatefulWidget {
  const SeekBar({super.key});

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;

  AudioPlayer get player => context.read<PlayerProvider>().player;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.read<PlayerProvider>().nowPlaying,
      builder: (context, media, _) {
        final duration = media.duration ?? player.duration;

        return StreamBuilder<Duration>(
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
                      if (duration == null) return const SizedBox();

                      return _sliderBuilder(
                        buffering: buffering,
                        duration: duration,
                        position: currentPosition.data ?? Duration.zero,
                        bufferedPosition: player.bufferedPosition,
                        onChangeEnd: (v) => player.seek(v),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: duration?.inHours == 0 ? 48 : 72,
                  child: Text(duration.formatHHMM()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sliderBuilder({
    required Duration duration,
    required Duration position,
    required Duration bufferedPosition,
    required ValueChanged<Duration>? onChangeEnd,
    required bool buffering,
  }) {
    return Slider(
      secondaryTrackValue: min(
        duration.inMilliseconds,
        buffering ? 0 : bufferedPosition.inMilliseconds,
      ).toDouble(),
      max: duration.inMilliseconds.toDouble(),
      value: max(
        _dragValue ??
            min(
              position.inMilliseconds,
              duration.inMilliseconds,
            ).toDouble(),
        Duration.zero.inMilliseconds.toDouble(),
      ),
      onChanged: (value) {
        if (buffering) return;
        setState(() => _dragValue = value);
      },
      onChangeEnd: (value) {
        if (buffering) return;
        onChangeEnd?.call(Duration(milliseconds: value.round()));
        _dragValue = null;
      },
    );
  }
}
