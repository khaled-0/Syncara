import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncara/app/player/player_menu_sheet.dart';
import 'package:syncara/extensions.dart';
import 'package:syncara/provider/player_provider.dart';

// https://github.com/material-components/material-components-android/blob/master/docs/components/Button.md#connected-button-group
// TODO There's no flutter component. Push this upstream someday
class PlayerStateIndicator extends StatelessWidget {
  const PlayerStateIndicator({super.key}) : _static = false;

  final bool _static;

  const PlayerStateIndicator.static({super.key}) : _static = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        if (_static) ...{
          Flexible(child: _sleepTimerStatic(context)),
        } else ...{
          Flexible(child: _sleepTimerIndicator(context)),
          Flexible(child: _speedIndicator(context)),
        }
      ],
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

  Widget _speedIndicator(BuildContext context) {
    return AnimatedSize(
      duration: Durations.short3,
      child: StreamBuilder(
        stream: context.read<PlayerProvider>().player.speedStream,
        initialData: context.read<PlayerProvider>().player.speed,
        builder: (context, snapshot) {
          if (snapshot.data == 1.0) return const SizedBox();
          return FilledButton.tonalIcon(
            onPressed: () => PlayerMenuSheet.setSpeedPopup(context),
            icon: const Icon(Icons.speed_rounded),
            label: Text("${snapshot.data}x"),
          );
        },
      ),
    );
  }

  /// This shows a static indicator
  Widget _sleepTimerStatic(BuildContext context) {
    return StreamBuilder(
      stream: context.read<PlayerProvider>().sleepTimerCountdown,
      initialData: context.read<PlayerProvider>().sleepTimer,
      builder: (context, snapshot) {
        final sleepTimer = snapshot.data;
        if (sleepTimer == null) return const SizedBox();
        return const CircleAvatar(
          radius: 20,
          child: Icon(Icons.bedtime_rounded, size: 20),
        );
      },
    );
  }
}
