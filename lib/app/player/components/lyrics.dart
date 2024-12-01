import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/app_theme.dart';
import 'package:tubesync/app/player/components/action_buttons.dart';
import 'package:tubesync/clients/media_client.dart';
import 'package:tubesync/model/common.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/provider/player_provider.dart';
import 'package:window_manager/window_manager.dart';

typedef LyricFutureResult = (List<LyricMetadata>, LyricMetadata, List<String>);

class Lyrics extends StatefulWidget {
  const Lyrics({super.key, this.fullscreen = false, this.initialData});

  final bool fullscreen;
  final LyricFutureResult? initialData;

  @override
  State<Lyrics> createState() => _LyricsState();
}

class _LyricsState extends State<Lyrics> with AutomaticKeepAliveClientMixin {
  PlayerProvider get playerProvider => context.read<PlayerProvider>();
  late LyricFutureResult? cachedResult = widget.initialData;
  bool paused = false;

  String preferredLanguage = "en";

  Future<LyricFutureResult> fetchLyrics(Media media) async {
    if (paused) throw "Fullscreen mode active";
    if (cachedResult != null) {
      final result = cachedResult;
      cachedResult = null;
      return result!;
    }

    final lyrics = await MediaClient().getAvailableLyrics(media);
    if (lyrics.isEmpty) throw "No lyrics available";
    final lyric = lyrics.firstWhere(
        (element) => element.langCode == preferredLanguage,
        orElse: () => lyrics.first);
    final lyricData = await MediaClient().getLRCLyrics(lyric);
    return (lyrics, lyric, lyricData);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card.filled(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: ValueListenableBuilder(
        valueListenable: context.read<PlayerProvider>().nowPlaying,
        builder: (context, nowPlaying, _) => FutureBuilder(
          future: fetchLyrics(nowPlaying),
          key: ValueKey(nowPlaying.hashCode),
          builder: (context, result) => Stack(
            children: [
              Positioned.fill(child: _lyricsView(result)),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: Durations.medium2,
                  opacity: result.hasError ? 0 : 1,
                  child: _lyricSelector(result),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lyricsView(AsyncSnapshot<LyricFutureResult> result) {
    if (result.hasError) return _errorView(result.error);
    if (!result.hasData) return _loadingView();

    final lyricModel = LyricsModelBuilder.create()
        .bindLyricToMain(result.requireData.$3.join("\n"))
        .getModel();

    // FIXME Flickers
    return StreamBuilder(
      stream: context.read<PlayerProvider>().player.positionStream,
      initialData: Duration.zero,
      builder: (context, snapshot) => LyricsReader(
        padding: const EdgeInsets.all(12),
        model: lyricModel,
        position: snapshot.requireData.inMilliseconds,
        playing: playerProvider.player.playing,
        emptyBuilder: () => const Center(child: Text("............")),
        lyricUi: _LyricsUI(context),
      ),
    );
  }

  Widget _lyricSelector(AsyncSnapshot<LyricFutureResult> result) {
    int availableLyrics = result.data?.$1.length ?? 0;
    String current = result.data?.$2.lang ?? "Fetching lyrics";

    return Card(
      elevation: 0,
      child: ListTile(
        dense: true,
        onTap: changePreferedLanguageDialog,
        //isFullScreenNot
        leading: const Icon(Icons.language_rounded),
        title: Text(current),
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (availableLyrics > 1)
              IconButton(
                onPressed: changePreferedLanguageDialog,
                icon: const Icon(Icons.change_circle_rounded),
              ),
            const VerticalDivider(),
            IconButton(
              onPressed: () => toggleFullScreen(result.data),
              icon: widget.fullscreen
                  ? const Icon(Icons.fullscreen_exit_rounded)
                  : const Icon(Icons.fullscreen_rounded),
            ),
          ],
        ),
      ),
    );
  }

  void changePreferedLanguageDialog() {}

  Future<void> toggleFullScreen(LyricFutureResult? result) async {
    if (widget.fullscreen) return Navigator.pop(context, result);
    paused = true;
    cachedResult = await Navigator.of(context).push(
      PageRouteBuilder(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return HorizontalScaleTransition(
            scale: animation.drive(Tween(begin: 0.55, end: 1)),
            child: child,
          );
        },
        transitionDuration: Durations.short3,
        reverseTransitionDuration: Durations.short2,
        pageBuilder: (_, __, ___) => ChangeNotifierProvider.value(
          value: playerProvider,
          child: _ExpandedLyrics(result),
        ),
      ),
    );
    setState(() => paused = false);
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
  final BuildContext context;

  _LyricsUI(this.context);

  @override
  Color getLyricHightlightColor() => Theme.of(context).colorScheme.primary;

  @override
  bool get highlight => false;

  @override
  TextStyle getPlayingMainTextStyle() =>
      Theme.of(context).textTheme.titleLarge!;

  @override
  TextStyle getOtherMainTextStyle() => Theme.of(context).textTheme.bodyMedium!;
}

class _ExpandedLyrics extends StatelessWidget {
  const _ExpandedLyrics(this.initialData);

  final LyricFutureResult? initialData;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Column(
          children: [
            DragToMoveArea(
              child: ValueListenableBuilder(
                valueListenable: context.read<PlayerProvider>().nowPlaying,
                builder: (_, value, __) => Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    value.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Lyrics(
                fullscreen: true,
                initialData: initialData,
              ),
            ),
            const ActionButtons(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
