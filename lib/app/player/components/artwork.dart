import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:provider/provider.dart';
import 'package:syncara/clients/media_client.dart';
import 'package:syncara/extensions.dart';
import 'package:syncara/data/models/media.dart';
import 'package:syncara/provider/player_provider.dart';

class Artwork extends StatefulWidget {
  final Media? placeholderMedia;

  const Artwork({super.key, this.placeholderMedia});

  @override
  State<Artwork> createState() => _ArtworkState();
}

class _ArtworkState extends State<Artwork> {
  MemoryImage? image;

  @override
  void initState() {
    super.initState();

    final playing = context.read<PlayerProvider>().nowPlaying.value;
    if (playing.thumbnailLocal != null) {
      image = MemoryImage(playing.thumbnailLocal!.bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.placeholderMedia != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: _avatar(widget.placeholderMedia!),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: ValueListenableBuilder(
        valueListenable: context.read<PlayerProvider>().nowPlaying,
        builder:
            (context, now, child) => StreamBuilder(
              stream: context.read<PlayerProvider>().player.positionStream,
              initialData: context.read<PlayerProvider>().player.position,
              builder: (context, position) {
                // Modulo by 360 degree / 6.28 rad so the angle doesn't get too large
                final angle =
                    (position.requireData.inMilliseconds / 42000) % 6.28;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Transform.rotate(
                        angle: angle.toPrecision(5),
                        child: _avatar(now),
                      ),
                    ),
                    Icon(
                      Icons.circle,
                      size: 48,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }

  Widget _avatar(Media media) {
    if (image != null) return CircleAvatar(foregroundImage: image);

    return CircleAvatar(
      foregroundImage: NetworkToFileImage(
        url: media.thumbnailHiRes,
        file: MediaClient().thumbnailFile(
          media.thumbnailHiRes,
        ),
      ),
      backgroundImage: NetworkToFileImage(
        url: media.thumbnailStd,
        file: MediaClient().thumbnailFile(
          media.thumbnailStd,
        ),
      ),
    );
  }
}
