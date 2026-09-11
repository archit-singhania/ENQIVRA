import 'package:circular_theme_reveal/circular_theme_reveal.dart';
import 'package:enqivra_mobile/core/router.dart';
import 'package:enqivra_mobile/core/theme.dart';
import 'package:enqivra_mobile/core/theme_controller.dart';
import 'package:flutter/material.dart';

class EnqivraApp extends StatelessWidget {
  const EnqivraApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.instance,
        builder: (context, mode, _) => MaterialApp.router(
          title: 'ENQIVRA',
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: mode,
          // The circular reveal overlay owns the visible color swap, so
          // Flutter's own theme cross-fade is turned off to avoid a
          // double-animation.
          themeAnimationDuration: Duration.zero,
          routerConfig: router,
          builder: (context, child) => CircularThemeRevealOverlay(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      );
}
