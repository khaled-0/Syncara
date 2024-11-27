import 'dart:io';
import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tubesync/app/player/components/seekbar.dart';

class AppTheme {
  static ValueNotifier<bool> dynamicColors = ValueNotifier(false);

  final Color _color = const Color(0xffF04C4E);
  final ColorScheme? colorScheme;

  AppTheme({this.colorScheme});

  ThemeData get light => _themeBuilder(Brightness.light);

  ThemeData get dark => _themeBuilder(Brightness.dark);

  ThemeData _themeBuilder(Brightness brightness) {
    final theme = colorScheme != null
        ? _properDynamicColors(colorScheme!, brightness)
        : ColorScheme.fromSeed(seedColor: _color, brightness: brightness);

    return ThemeData(
      colorScheme: theme,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      cardTheme: const CardTheme(
        margin: EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
      ),
      sliderTheme: const SliderThemeData(
        thumbShape: LineThumbShape(),
        trackHeight: 8,
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: systemOverlayStyle(theme),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const CupertinoPageTransitionsBuilder(),
        },
      ),
      fontFamily: 'WantedSansStd',
      useMaterial3: true,
    );
  }

  SystemUiOverlayStyle systemOverlayStyle(ColorScheme theme) {
    final systemIconBrightness = switch (theme.brightness) {
      Brightness.dark => Brightness.light,
      Brightness.light => Brightness.dark,
    };

    return SystemUiOverlayStyle(
      statusBarIconBrightness: systemIconBrightness,
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: systemIconBrightness,
      systemNavigationBarColor: theme.surfaceContainer,
      systemNavigationBarDividerColor: theme.surfaceContainer,
    );
  }

  static ScrollBehavior get scrollBehavior {
    return const MaterialScrollBehavior().copyWith(
      physics: const BouncingScrollPhysics(),
      dragDevices: PointerDeviceKind.values.toSet(),
    );
  }

  static bool get isDesktop {
    return Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  }

  // https://github.com/material-foundation/flutter-packages/issues/582#issuecomment-2081174158
  ColorScheme _properDynamicColors(
    ColorScheme scheme,
    Brightness brightness,
  ) {
    final base = ColorScheme.fromSeed(
      seedColor: scheme.primary,
      brightness: brightness,
    );

    final lightAdditionalColours = _extractAdditionalColours(base);
    final fixedScheme = _insertAdditionalColours(base, lightAdditionalColours);
    return fixedScheme.harmonized();
  }

  List<Color> _extractAdditionalColours(ColorScheme scheme) => [
        scheme.surface,
        scheme.surfaceDim,
        scheme.surfaceBright,
        scheme.surfaceContainerLowest,
        scheme.surfaceContainerLow,
        scheme.surfaceContainer,
        scheme.surfaceContainerHigh,
        scheme.surfaceContainerHighest,
      ];

  ColorScheme _insertAdditionalColours(
    ColorScheme scheme,
    List<Color> additionalColours,
  ) =>
      scheme.copyWith(
        surface: additionalColours[0],
        surfaceDim: additionalColours[1],
        surfaceBright: additionalColours[2],
        surfaceContainerLowest: additionalColours[3],
        surfaceContainerLow: additionalColours[4],
        surfaceContainer: additionalColours[5],
        surfaceContainerHigh: additionalColours[6],
        surfaceContainerHighest: additionalColours[7],
      );
}
