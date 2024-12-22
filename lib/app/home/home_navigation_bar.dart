import 'package:flutter/material.dart';
import 'package:myusync/app/app_theme.dart';
import 'package:myusync/app/home/avatar.dart';

class HomeNavigationBar extends StatefulWidget {
  const HomeNavigationBar({super.key}) : _rail = false;

  const HomeNavigationBar.rail({super.key}) : _rail = true;

  static const int length = 2;
  final bool _rail;

  @override
  State<HomeNavigationBar> createState() => _HomeNavigationBarState();
}

class _HomeNavigationBarState extends State<HomeNavigationBar> {
  @override
  Widget build(BuildContext context) {
    if (widget._rail) return _sideRailBar();
    if (AppTheme.isDesktop) return const SizedBox();
    return _bottomNavBar();
  }

  Widget _sideRailBar() {
    return NavigationRail(
      selectedIndex: DefaultTabController.of(context).index,
      onDestinationSelected: (value) {
        setState(() => DefaultTabController.of(context).animateTo(value));
      },
      labelType: NavigationRailLabelType.selected,
      destinations: const [
        NavigationRailDestination(
          padding: EdgeInsets.symmetric(vertical: 4),
          icon: Icon(Icons.my_library_music_outlined),
          selectedIcon: Icon(Icons.my_library_music_rounded),
          label: Text('Library'),
        ),
        NavigationRailDestination(
          padding: EdgeInsets.symmetric(vertical: 4),
          icon: Icon(Icons.more_horiz_rounded),
          selectedIcon: Icon(Icons.more_vert_rounded),
          label: Text('More'),
        )
      ],
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: IconButton(
              padding: const EdgeInsets.all(16),
              onPressed: () {},
              icon: const Avatar(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNavBar() {
    return NavigationBar(
      selectedIndex: DefaultTabController.of(context).index,
      onDestinationSelected: (value) {
        setState(() => DefaultTabController.of(context).animateTo(value));
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.my_library_music_outlined),
          selectedIcon: Icon(Icons.my_library_music_rounded),
          label: 'Library',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz_rounded),
          selectedIcon: Icon(Icons.more_vert_rounded),
          label: 'More',
        )
      ],
    );
  }
}
