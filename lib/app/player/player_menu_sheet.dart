import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncara/app/more/preferences/components/choice_dialog.dart';
import 'package:syncara/provider/player_provider.dart';

class PlayerMenuSheet extends StatelessWidget {
  const PlayerMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //Drag Handle
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 4,
              width: kMinInteractiveDimension,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          ListTile(
            onTap: () {
              setSleepTimerPopup(context).then((ok) {
                if (ok && context.mounted) Navigator.pop(context);
              });
            },
            leading: const Icon(Icons.bedtime_rounded),
            title: const Text("Sleep Timer"),
          ),
        ],
      ),
    );
  }

  static Future<bool> setSleepTimerPopup(BuildContext context) async {
    final result = await showDialog<Duration?>(
      context: context,
      builder: (context) => ChoiceDialog<Duration>(
        title: "Stop playing after",
        icon: const Icon(Icons.bedtime_rounded),
        options: {
          "Never": Duration.zero,
          for (final i in [10, 20, 30, 40, 50]) ...{
            "$i Minutes": Duration(minutes: i),
          },
          for (final i in [1, 2]) ...{
            "$i Hours": Duration(hours: i),
          },
          "End of media": const Duration(seconds: -1),
        },
      ),
    );

    if (!context.mounted || result == null) return false;

    switch (result) {
      case Duration.zero: // Never / Cancel Sleep
        context.read<PlayerProvider>().setSleepTimer();
        return true;

      case const (Duration(seconds: -1)): // End of Song
        context.read<PlayerProvider>().setSleepTimer(afterSong: true);
        return true;

      default:
        context.read<PlayerProvider>().setSleepTimer(duration: result);
        return true;
    }
  }
}
