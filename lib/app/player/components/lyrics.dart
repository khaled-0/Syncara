import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/clients/media_client.dart';
import 'package:tubesync/model/common.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/provider/player_provider.dart';

class Lyrics extends StatefulWidget {
  const Lyrics({super.key});

  @override
  State<Lyrics> createState() => _LyricsState();
}

class _LyricsState extends State<Lyrics> with AutomaticKeepAliveClientMixin {
  PlayerProvider get playerProvider => context.read<PlayerProvider>();

  String preferredLanguage = "en";

  Future<(List<LyricMetadata>, List<String>)> fetchLyrics(Media media) async {
    final lyrics = await MediaClient().getAvailableLyrics(media);
    final lyricData = await MediaClient().getLRCLyrics(
      lyrics.firstWhere(
        (element) => element.langCode == preferredLanguage,
        orElse: () => lyrics.first,
      ),
    );
    return (lyrics, lyricData);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: ValueListenableBuilder(
        valueListenable: context.read<PlayerProvider>().nowPlaying,
        builder: (context, nowPlaying, _) => FutureBuilder(
          future: fetchLyrics(nowPlaying),
          builder: (context, result) {
            if (result.hasError) return _errorView(result.error);
            if (!result.hasData) return _loadingView();
            final lyricModel = LyricsModelBuilder.create()
                .bindLyricToMain(result.requireData.$2.join("\n"))
                .getModel();

            // FIXME Flickers
            return StreamBuilder(
              stream: context.read<PlayerProvider>().player.positionStream,
              initialData: Duration.zero,
              builder: (context, snapshot) => _lyricsView(
                lyricModel,
                snapshot.requireData.inMilliseconds,
                context.read<PlayerProvider>().player.playing,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _lyricsView(
    LyricsReaderModel lyricModel,
    int playerPosition,
    bool playing,
  ) {
    return LyricsReader(
      padding: const EdgeInsets.all(12),
      model: lyricModel,
      position: playerPosition,
      playing: playing,
      emptyBuilder: () => const Center(child: Text("............")),
      lyricUi: _LyricsUI(Theme.of(context).colorScheme.primary),
    );
  }

  Widget _errorView(Object? err) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(child: Text(err.toString())),
    );
  }

  Widget _loadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  bool get wantKeepAlive => true;
}

class _LyricsUI extends UINetease {
  final Color highlightColor;

  _LyricsUI(this.highlightColor);

  @override
  Color getLyricHightlightColor() => highlightColor;
}
