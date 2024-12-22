import 'package:flutter/material.dart';
import 'package:myusync/app/app_theme.dart';
import 'package:myusync/app/home/avatar.dart';
import 'package:window_manager/window_manager.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadius.circular(38),
            child: ColoredBox(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              child: Image.asset(
                "assets/icons/tubesync_mono.webp",
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
        ),
        titleSpacing: 0,
        title: const Text("MyuSync"),
        actions: [
          if (!AppTheme.isDesktop) ...{
            const Avatar(),
            const SizedBox(width: 12),
          } else ...{
            IconButton(
              tooltip: "Minimize",
              onPressed: WindowManager.instance.minimize,
              icon: const Icon(Icons.horizontal_rule_rounded),
            ),
            IconButton(
              tooltip: "Close",
              onPressed: WindowManager.instance.close,
              icon: const Icon(Icons.close_rounded),
            ),
            const SizedBox(width: 12),
          }
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
