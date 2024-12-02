import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/app_theme.dart';
import 'package:tubesync/app/more/about_screen.dart';
import 'package:tubesync/app/more/downloads/active_downloads_screen.dart';
import 'package:tubesync/model/preferences.dart';

class MoreTab extends StatelessWidget {
  MoreTab({super.key});

  final homeNavigator = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: NavigatorPopHandler(
        onPop: () => homeNavigator.currentState?.pop(),
        child: Navigator(
          key: homeNavigator,
          onGenerateRoute: (settings) => MaterialPageRoute(
            settings: settings,
            builder: (_) => moreTabContent(context),
          ),
        ),
      ),
    );
  }

  Widget moreTabContent(BuildContext context) {
    return ListView(
      children: [
        // BigAss Branding
        const SizedBox(height: 8),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(80),
            child: Image.asset(
              "assets/tubesync_mono.png",
              width: 80,
              height: 80,
              color: Theme.of(context).colorScheme.primary,
              fit: BoxFit.fill,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
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
        const Divider(),
        ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ActiveDownloadsScreen()),
          ),
          leading: const Icon(Icons.download_rounded),
          title: const Text("Download Queue"),
          subtitle: const Text("Manage running downloads"),
        ),
        const Divider(),
        ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutScreen()),
          ),
          leading: const Icon(Icons.info_rounded),
          title: const Text("About"),
        ),
      ],
    );
  }
}
