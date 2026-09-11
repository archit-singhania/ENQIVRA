import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enqivra_mobile/core/theme.dart';

/// A slow, softly drifting field of glowing color blobs behind a vignette —
/// the "Apple-glass" depth backdrop used behind every primary screen.
/// Purely decorative: takes a [child] and never intercepts input or state.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, required this.child});
  final Widget child;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 22))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
              decoration: BoxDecoration(color: AppColors.background)),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value * 2 * pi;
              return Stack(children: [
                _Orb(
                    alignment:
                        Alignment(-0.9 + 0.16 * sin(t), -1.15 + 0.1 * cos(t)),
                    size: 380,
                    colors: [
                      AppColors.primary.withOpacity(0.30),
                      Colors.transparent
                    ]),
                _Orb(
                    alignment: Alignment(
                        1.05 + 0.10 * cos(t * 0.8), -0.55 + 0.16 * sin(t * 0.8)),
                    size: 320,
                    colors: [
                      AppColors.violet.withOpacity(0.20),
                      Colors.transparent
                    ]),
                _Orb(
                    alignment: Alignment(
                        0.65 + 0.12 * sin(t * 0.6), 1.25 + 0.10 * cos(t * 0.6)),
                    size: 440,
                    colors: [
                      AppColors.primaryBright.withOpacity(0.12),
                      Colors.transparent
                    ]),
              ]);
            },
          ),
          Positioned.fill(
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: RadialGradient(
                          center: const Alignment(0, -0.3),
                          radius: 1.4,
                          colors: [
                            Colors.transparent,
                            AppColors.background.withOpacity(0.55),
                            AppColors.background,
                          ],
                          stops: const [0.0, 0.6, 1.0])))),
          widget.child,
        ],
      );
}

class _Orb extends StatelessWidget {
  const _Orb(
      {required this.alignment, required this.size, required this.colors});
  final Alignment alignment;
  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) => Align(
        alignment: alignment,
        child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: colors))),
      );
}
