import 'package:flutter/material.dart';

class EmptyLibraryView extends StatelessWidget {
  const EmptyLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(
            Icons.queue_music_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          Text(
            "No entries found.\n"
            "Hit  + Import  below to get started",
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
