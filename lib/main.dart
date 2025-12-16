import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:syncara/app/app_theme.dart';
import 'package:syncara/app/home/home_screen.dart';
import 'package:syncara/clients/media_client.dart';
import 'package:syncara/model/objectbox.g.dart';
import 'package:syncara/model/preferences.dart';
import 'package:syncara/services/downloader_service.dart';
import 'package:syncara/services/media_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import 'l10n/app_localizations.dart';

final rootNavigator = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppTheme.isDesktop) {
    await WindowManager.instance.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(480, 360));
    WindowManager.instance.setResizable(true);
    WindowManager.instance.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
  }

  // DB Initialization
  final objectDB = await openStore(
    directory: (await getApplicationSupportDirectory()).path,
    macosApplicationGroup: "syncara.app",
  );

  AppTheme.configNotifier.value = ThemeConfig(
    dynamicColors: objectDB.box<Preferences>().value(Preference.materialYou),
    pitchBlack: objectDB.box<Preferences>().value(Preference.pitchBlack),
  );

  await DownloaderService.init(objectDB);
  await MediaService.init(objectDB);
  await MediaClient.init();

  GetIt.I.registerLazySingleton<yt.YoutubeExplode>(yt.YoutubeExplode.new);

  MaterialApp app({
    required ThemeData light,
    required ThemeData dark,
    required Widget home,
  }) {
    return MaterialApp(
      navigatorKey: rootNavigator,
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      scrollBehavior: AppTheme.scrollBehavior,
      home: home,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        LogicalKeySet(LogicalKeyboardKey.keyJ): SeekBackIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyK): PlayPauseIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyL): SeekForwardIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyP): PreviousMediaIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyN): NextMediaIntent(),
      },
      actions: {
        ...WidgetsApp.defaultActions,
        PlayPauseIntent: PlaybackAction<PlayPauseIntent>(),
        PreviousMediaIntent: PlaybackAction<PreviousMediaIntent>(),
        NextMediaIntent: PlaybackAction<NextMediaIntent>(),
        SeekForwardIntent: PlaybackAction<SeekForwardIntent>(),
        SeekBackIntent: PlaybackAction<SeekBackIntent>(),
      },
    );
  }

  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: DragToResizeArea(
        child: ValueListenableBuilder(
          valueListenable: AppTheme.configNotifier,
          builder: (_, dynamicColor, home) {
            if (!Platform.isIOS && dynamicColor.dynamicColors) {
              return DynamicColorBuilder(
                builder: (light, dark) => app(
                  light: AppTheme(colorScheme: light).light,
                  dark: AppTheme(colorScheme: dark).dark,
                  home: home!,
                ),
              );
            }

            return app(
              light: AppTheme().light,
              dark: AppTheme().dark,
              home: home!,
            );
          },
          child: Provider<Store>(
            create: (context) => objectDB,
            child: const HomeScreen(),
          ),
        ),
      ),
    ),
  );

  // Ensure permissions
  Future.wait([
        Permission.notification.isDenied,
        Permission.ignoreBatteryOptimizations.isDenied,
      ])
      .then((result) async {
        if (result[0]) await Permission.notification.request();
        if (result[1]) await Permission.ignoreBatteryOptimizations.request();
      })
      .catchError((_) {});
}
