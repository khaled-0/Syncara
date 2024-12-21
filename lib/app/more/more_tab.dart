import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/more/about_screen.dart';
import 'package:tubesync/app/more/downloads/active_downloads_screen.dart';
import 'package:tubesync/app/more/preferences/preference_screen.dart';
import 'package:tubesync/model/objectbox.g.dart';

class MoreTab extends StatelessWidget {
  MoreTab({super.key});

  final homeNavigator = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: NavigatorPopHandler(
        onPopWithResult: (_) => homeNavigator.currentState?.pop(),
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
              "assets/icons/tubesync_mono.webp",
              width: 80,
              height: 80,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fit: BoxFit.fill,
            ),
          ),
        ),
        const SizedBox(height: 16),
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
            MaterialPageRoute(
              builder: (_) => Provider.value(
                value: context.read<Store>(),
                child: const PreferenceScreen(),
              ),
            ),
          ),
          leading: const Icon(Icons.settings_rounded),
          title: const Text("Preferences"),
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
