import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:enqivra_mobile/core/theme.dart';

/// A frosted, backdrop-blurred surface in the spirit of Apple's vibrancy
/// materials — used for primary content panels that should feel elevated
/// and translucent against the [AuroraBackground]. Theme-aware: in dark
/// mode the frost is white-tinted (classic vibrancy-dark), in light mode
/// it's black-tinted (vibrancy-light), matching how iOS actually does it.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 26,
    this.blur = 24,
    this.opacity = 0.06,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final dark = palette.brightness == Brightness.dark;
    final tint = dark ? Colors.white : Colors.black;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(alpha: opacity + 0.04),
                  tint.withValues(alpha: opacity * 0.4),
                ]),
            border: Border.all(color: palette.glassBorder, width: 1),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.35 : 0.10),
                  blurRadius: 30,
                  offset: const Offset(0, 18)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
