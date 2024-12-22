import 'dart:io';

import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/app_theme.dart';
import 'package:tubesync/app/more/preferences/components/choice_dialog.dart';
import 'package:tubesync/app/player/mini_player_sheet.dart';
import 'package:tubesync/model/preferences.dart';

class PreferenceScreen extends StatelessWidget {
  const PreferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preferences")),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          _title(context, "Appearance"),
          if (!Platform.isIOS)
            ValueListenableBuilder(
              valueListenable: AppTheme.dynamicColors,
              builder: (_, value, __) => SwitchListTile(
                value: value != false,
                onChanged: (value) {
                  AppTheme.dynamicColors.value = value;
                  preferences(context).set(Preference.materialYou, value);
                },
                secondary: const Icon(Icons.palette_rounded),
                title: const Text("Material You"),
                subtitle: const Text("Use dynamic colors when available"),
              ),
            ),
          _title(context, "Notification"),
          StreamBuilder(
            stream: preferences(context).watch(
              Preference.notifShowShuffle,
            ),
            builder: (c, value) => SwitchListTile(
              value: value.data?.value(Preference.notifShowShuffle) != false,
              onChanged: (value) => preferences(c).set(
                Preference.notifShowShuffle,
                value,
              ),
              secondary: const Icon(Icons.shuffle_rounded),
              title: const Text("Show shuffle button"),
              subtitle: const Text("May not work on all devices/platforms"),
            ),
          ),
          StreamBuilder(
            stream: preferences(context).watch(
              Preference.notifShowRepeat,
            ),
            builder: (c, value) => SwitchListTile(
              value: value.data?.value(Preference.notifShowRepeat) != false,
              onChanged: (value) => preferences(c).set(
                Preference.notifShowRepeat,
                value,
              ),
              secondary: const Icon(Icons.repeat_rounded),
              title: const Text("Show repeat button"),
              subtitle: const Text("May not work on all devices/platforms"),
            ),
          ),
          _title(context, "Player"),
          StreamBuilder(
            stream: preferences(context).watch(
              Preference.miniPlayerSecondaryAction,
            ),
            builder: (context, value) {
              int? i = value.data?.value(Preference.miniPlayerSecondaryAction);
              i ??= Preference.miniPlayerSecondaryAction.defaultValue;
              final selected = MiniPlayerSecondaryActions.values[i];
              return ListTile(
                leading: const Icon(Icons.smart_button_rounded),
                title: const Text("Mini player secondary action"),
                subtitle: Text(selected.name),
                onTap: () => showDialog<MiniPlayerSecondaryActions?>(
                  context: context,
                  builder: (_) => ChoiceDialog<MiniPlayerSecondaryActions>(
                    title: "Mini player secondary action",
                    icon: const Icon(Icons.smart_button_rounded, size: 38),
                    selected: selected,
                    options: {
                      for (final i in MiniPlayerSecondaryActions.values) ...{
                        i.name: i
                      }
                    },
                  ),
                ).then((v) {
                  if (!context.mounted || v == null) return;
                  preferences(context).set(
                    Preference.miniPlayerSecondaryAction,
                    v.index,
                  );
                }),
              );
            },
          ),
          _title(context, "Downloader"),
          StreamBuilder<Query<Preferences>>(
            stream: preferences(context).watch(
              Preference.maxParallelDownload,
            ),
            builder: (context, value) => ListTile(
              leading: const Icon(Icons.multiple_stop_rounded),
              title: const Text("Maximum parallel downloads"),
              subtitle: Text("${value.data?.value(
                Preference.maxParallelDownload,
              )} at a time"),
              onTap: () => showDialog<int?>(
                context: context,
                builder: (_) => ChoiceDialog<int>(
                  title: "Maximum parallel downloads",
                  subtitle: "Restart app to take effect",
                  icon: const Icon(Icons.multiple_stop_rounded, size: 38),
                  selected: value.data?.value(Preference.maxParallelDownload),
                  options: {
                    for (final i in [1, 2, 3, 4, 5, 6, 7, 8]) ...{"$i": i}
                  },
                ),
              ).then((v) {
                if (!context.mounted || v == null) return;
                preferences(context).set(
                  Preference.maxParallelDownload,
                  v,
                );
              }),
            ),
          ),
          _title(context, "Others"),
          StreamBuilder(
            stream: preferences(context).watch(
              Preference.inAppUpdate,
            ),
            builder: (c, value) => SwitchListTile(
              value: value.data?.value(Preference.inAppUpdate) != false,
              onChanged: (value) => preferences(c).set(
                Preference.inAppUpdate,
                value,
              ),
              secondary: const Icon(Icons.shuffle_rounded),
              title: const Text("Check app updates"),
              subtitle: const Text("Notify when new version is available"),
            ),
          ),
        ],
      ),
    );
  }

  Box<Preferences> preferences(BuildContext c) =>
      c.read<Store>().box<Preferences>();

  Widget _title(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        text,
        maxLines: 1,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
