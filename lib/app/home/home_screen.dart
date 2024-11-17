import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/app_theme.dart';
import 'package:tubesync/app/library/library_tab.dart';
import 'package:tubesync/app/more/more_tab.dart';
import 'package:tubesync/provider/library_provider.dart';

import 'home_app_bar.dart';
import 'home_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: HomeNavigationBar.length,
      child: MultiProvider(
        providers: [
          //FIXME https://github.com/fluttercommunity/plus_plugins/issues/1241
          StreamProvider<InternetStatus>(
            create: (_) => InternetConnection().onStatusChange,
            initialData: InternetStatus.connected,
          ),
          Provider<GlobalKey<ScaffoldState>>(create: (_) => GlobalKey()),
          ChangeNotifierProvider<LibraryProvider>(
            create: (_) => LibraryProvider(context.read<Isar>()),
          ),
        ],
        builder: (context, child) {
          if (AppTheme.isDesktop) {
            return Row(
              children: [
                const HomeNavigationBar.rail(),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Scaffold(
                    key: Provider.of<GlobalKey<ScaffoldState>>(context),
                    appBar: const HomeAppBar(),
                    body: child!,
                    bottomNavigationBar: const HomeNavigationBar(),
                  ),
                ),
              ],
            );
          }
          return Scaffold(
            key: Provider.of<GlobalKey<ScaffoldState>>(context),
            appBar: const HomeAppBar(),
            body: child!,
            bottomNavigationBar: const HomeNavigationBar(),
          );
        },
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [const HomeTab(), MoreTab()],
        ),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
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
            builder: (_) => const LibraryTab(),
          ),
        ),
      ),
    );
  }
}
