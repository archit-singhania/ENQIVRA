import 'package:circular_theme_reveal/circular_theme_reveal.dart';
import 'package:flutter/material.dart';
import 'package:enqivra_mobile/core/theme.dart';
import 'package:enqivra_mobile/core/theme_controller.dart';

/// The single light/dark switch for the app. Tapping it starts a
/// Telegram/iOS-style circular "iris" reveal that expands outward from
/// wherever this button is placed. Put it in the top-right corner (as
/// [EnqivraScaffold] does) and the reveal sweeps diagonally across the
/// whole screen, finishing in the opposite, bottom-left corner.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return Material(
          color: palette.glassFill,
          shape: CircleBorder(side: BorderSide(color: palette.glassBorder)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _handleToggle(context),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, animation) => RotationTransition(
                    turns: animation,
                    child: ScaleTransition(scale: animation, child: child)),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  key: ValueKey(isDark),
                  size: 20,
                  color: isDark ? palette.textPrimary : palette.amber,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleToggle(BuildContext context) async {
    final controller = ThemeController.instance;
    final wasDark = controller.isDark;
    final center = CircularThemeRevealOverlay.getCenterFromContext(context);
    final overlay = CircularThemeRevealOverlay.of(context);
    if (overlay != null) {
      await overlay.startTransition(
        center: center,
        // Going dark -> light contracts back toward this button; light ->
        // dark expands outward from it across the whole screen.
        reverse: wasDark,
        onThemeChange: controller.toggle,
      );
    } else {
      await controller.toggle();
    }
  }
}
