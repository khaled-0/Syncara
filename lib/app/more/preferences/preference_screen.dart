import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/app_theme.dart';
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
                value: value == true,
                onChanged: (value) {
                  AppTheme.dynamicColors.value = value;
                  preferences(context).setValue(Preference.materialYou, value);
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
              value: value.data?.get<bool>() != false,
              onChanged: (value) => preferences(c).setValue(
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
              value: value.data?.get<bool>() != false,
              onChanged: (value) => preferences(c).setValue(
                Preference.notifShowRepeat,
                value,
              ),
              secondary: const Icon(Icons.repeat_rounded),
              title: const Text("Show repeat button"),
              subtitle: const Text("May not work on all devices/platforms"),
            ),
          ),
        ],
      ),
    );
  }

  IsarCollection<String, Preferences> preferences(BuildContext c) =>
      c.read<Isar>().preferences;

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
