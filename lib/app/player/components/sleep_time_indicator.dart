import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/player/components/player_menu_sheet.dart';
import 'package:tubesync/extensions.dart';
import 'package:tubesync/provider/player_provider.dart';

class SleepTimeIndicator extends StatelessWidget {
  const SleepTimeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
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
}
