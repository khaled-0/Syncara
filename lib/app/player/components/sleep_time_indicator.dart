import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/player/components/player_menu_sheet.dart';
import 'package:tubesync/extensions.dart';
import 'package:tubesync/provider/player_provider.dart';

class SleepTimeIndicator extends StatelessWidget {
  const SleepTimeIndicator({super.key}) : _static = false;

  final bool _static;

  const SleepTimeIndicator.static({super.key}) : _static = true;

  @override
  Widget build(BuildContext context) {
    if (_static) return _sleepTimerStatic(context);
    return _sleepTimerIndicator(context);
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
