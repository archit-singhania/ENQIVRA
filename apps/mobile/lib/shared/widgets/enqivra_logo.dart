import 'package:flutter/material.dart';
import 'package:enqivra_mobile/core/theme.dart';

/// The real ENQIVRA brand mark, rendered with a soft glow so it reads
/// consistently across the splash, auth, and about screens. Purely
/// presentational — a thin wrapper around the bundled PNG asset. The glow
/// color follows the active light/dark palette.
class EnqivraLogo extends StatelessWidget {
  const EnqivraLogo({
    super.key,
    this.size = 84,
    this.glow = true,
  });

  final double size;
  final bool glow;

  static const _asset = 'assets/branding/enquivra_logo.png';

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: glow
            ? [
                BoxShadow(
                    color: palette.primary.withValues(alpha: 0.55),
                    blurRadius: size * 0.7,
                    spreadRadius: size * 0.02),
                BoxShadow(
                    color: palette.violet.withValues(alpha: 0.18),
                    blurRadius: size * 0.9,
                    offset: Offset(0, size * 0.12)),
              ]
            : null,
      ),
      child: Image.asset(_asset, fit: BoxFit.contain),
    );
  }
}
