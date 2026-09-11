import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:enqivra_mobile/core/theme.dart';

/// The animated "3D glass" backdrop behind every primary screen.
///
/// Flutter on mobile has no WebGL/GL-shader canvas the way a browser
/// does, so this builds the same illusion natively: several depth planes
/// of blurred color drifting at different speeds (parallax), a rotating
/// specular sheen sweeping the same diagonal as the theme-toggle reveal,
/// and a faint grain layer for a physical, lit-glass feel — all pure
/// Flutter animations, so it can't break the build.
///
/// Purely decorative: takes a [child] and never intercepts input or state.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, required this.child});
  final Widget child;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with TickerProviderStateMixin {
  late final AnimationController _drift =
      AnimationController(vsync: this, duration: const Duration(seconds: 26))
        ..repeat();
  late final AnimationController _sheen =
      AnimationController(vsync: this, duration: const Duration(seconds: 10))
        ..repeat();

  @override
  void dispose() {
    _drift.dispose();
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final dark = palette.brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(color: palette.background)),

        // Far depth plane — large, heavily blurred, slowest drift, with a
        // hair of rotation so the whole scene feels like it has a camera
        // behind it rather than being flat.
        AnimatedBuilder(
          animation: _drift,
          builder: (context, _) {
            final t = _drift.value * 2 * pi;
            return Transform.rotate(
              angle: 0.014 * sin(t * 0.5),
              child: Stack(children: [
                _Orb(
                  alignment:
                      Alignment(-0.9 + 0.16 * sin(t), -1.15 + 0.1 * cos(t)),
                  size: 420,
                  blur: dark ? 72 : 92,
                  colors: [
                    palette.primary.withOpacity(dark ? 0.32 : 0.16),
                    Colors.transparent,
                  ],
                ),
                _Orb(
                  alignment: Alignment(
                      1.05 + 0.10 * cos(t * 0.8), -0.55 + 0.16 * sin(t * 0.8)),
                  size: 360,
                  blur: dark ? 72 : 92,
                  colors: [
                    palette.violet.withOpacity(dark ? 0.22 : 0.14),
                    Colors.transparent,
                  ],
                ),
              ]),
            );
          },
        ),

        // Near depth plane — faster drift, gentle breathing scale, so it
        // reads as "closer" to the glass than the far plane above it.
        AnimatedBuilder(
          animation: _drift,
          builder: (context, _) {
            final t = _drift.value * 2 * pi;
            final breathe = 1.0 + 0.06 * sin(t * 1.4);
            return Transform.scale(
              scale: breathe,
              child: _Orb(
                alignment: Alignment(
                    0.62 + 0.12 * sin(t * 0.9), 1.22 + 0.10 * cos(t * 0.9)),
                size: 460,
                blur: dark ? 58 : 78,
                colors: [
                  palette.primaryBright.withOpacity(dark ? 0.15 : 0.10),
                  Colors.transparent,
                ],
              ),
            );
          },
        ),

        // Rotating specular sheen — the "light catching the glass" sweep,
        // travelling the same top-right <-> bottom-left axis as the
        // theme-switch reveal, tying the two motions together.
        AnimatedBuilder(
          animation: _sheen,
          builder: (context, _) => IgnorePointer(
            child: Opacity(
              opacity: dark ? 0.10 : 0.18,
              child: Transform.rotate(
                angle: pi / 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      transform: GradientRotation(_sheen.value * 2 * pi),
                      colors: const [
                        Colors.transparent,
                        Colors.white,
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.07, 0.16, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Fine static grain so the "glass" has a subtle, physical texture
        // instead of looking like a flat digital gradient.
        const IgnorePointer(child: _Grain()),

        // Vignette so foreground content always stays legible against
        // whichever colors are drifting behind it.
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 1.4,
                colors: [
                  Colors.transparent,
                  palette.background.withOpacity(0.55),
                  palette.background,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),

        widget.child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.alignment,
    required this.size,
    required this.colors,
    this.blur = 0,
  });
  final Alignment alignment;
  final double size;
  final List<Color> colors;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final orb = Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration:
            BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: colors)),
      ),
    );
    if (blur <= 0) return orb;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: orb,
    );
  }
}

/// A sparse, cheap dot-grain overlay. Painted once (it never repaints),
/// so it costs nothing during the drift/sheen animations above it.
class _Grain extends StatelessWidget {
  const _Grain();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GrainPainter(), size: Size.infinite);
}

class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(7);
    final paint = Paint()..color = Colors.white.withOpacity(0.025);
    const step = 6.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        if (random.nextDouble() > 0.965) {
          canvas.drawCircle(Offset(x, y), 0.6, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => false;
}
