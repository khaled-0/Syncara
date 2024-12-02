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
                  context.read<Isar>().preferences.setValue(
                        Preference.materialYou,
                        value,
                      );
                },
                secondary: const Icon(Icons.palette_rounded),
                title: const Text("Material You"),
                subtitle: const Text("Use dynamic colors when available"),
              ),
            ),
          
        ],
      ),
    );
  }

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
