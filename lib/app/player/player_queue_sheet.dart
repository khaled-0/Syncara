import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/playlist/media_entry_builder.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/provider/player_provider.dart';

class PlayerQueueSheet extends StatelessWidget {
  const PlayerQueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 16),
              Text(
                "Playlist (${context.read<PlayerProvider>().playlist.length})",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              const SizedBox(width: 12),
              ...actions(context),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Selector<PlayerProvider, List<Media>>(
              selector: (_, provider) => provider.playlist,
              builder: (context, playlist, __) {
                return ValueListenableBuilder(
                  valueListenable: context.read<PlayerProvider>().nowPlaying,
                  builder: (context, nowPlaying, _) {
                    return ReorderableListView.builder(
                      scrollController: scrollController,
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.only(
                        bottom: kBottomNavigationBarHeight,
                      ),
                      itemCount: playlist.length,
                      onReorder: context.read<PlayerProvider>().reorderList,
                      itemBuilder: (context, index) => MediaEntryBuilder(
                        key: ValueKey(playlist[index].hashCode),
                        playlist[index],
                        selected: playlist[index] == nowPlaying,
                        trailing: ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.drag_handle_rounded),
                          ),
                        ),
                        onTap: () {
                          context.read<PlayerProvider>().jumpTo(index);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> actions(BuildContext context) {
    return [
      IconButton(
        onPressed: context.read<PlayerProvider>().shuffle,
        icon: const Icon(Icons.shuffle_rounded),
      ),
      ValueListenableBuilder(
        valueListenable: context.read<PlayerProvider>().loopMode,
        builder: (context, loopMode, _) => IconButton(
          onPressed: context.read<PlayerProvider>().toggleLoopMode,
          icon: Icon(
            switch (loopMode) {
              LoopMode.off => Icons.repeat_rounded,
              LoopMode.one => Icons.repeat_one_rounded,
              LoopMode.all => Icons.repeat_on_rounded,
            },
          ),
        ),
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.more_vert_rounded),
      ),
    ];
  }
}
