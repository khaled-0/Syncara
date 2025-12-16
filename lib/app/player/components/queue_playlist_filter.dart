import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncara/data/models/playlist.dart';

import '../../../data/providers/player_provider.dart';


class QueuePlaylistFilter extends StatelessWidget {
  const QueuePlaylistFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<PlayerProvider, List<Playlist>>(
      selector: (_, provider) => provider.playlistInfo,
      builder: (context, playlists, _) {
        if (playlists.length == 1) return const SizedBox();
        return SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  selected: true,
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                  label: Text(playlists[index].displayTitle),
                  onSelected: (value) {
                    // TODO Filter
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
