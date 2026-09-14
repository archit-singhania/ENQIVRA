import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enqivra_mobile/core/theme.dart';
import 'package:enqivra_mobile/shared/widgets/enqivra_logo.dart';

/// A one-shot "materialize" entrance for the ENQIVRA mark — the closest
/// native analogue to an SVG stroke-draw intro available without a real
/// vector asset: a bright ring sweeps a full circle around the mark while
/// it fades and scales up from a pinpoint, in sync with the sweep's
/// progress, then the ring dissolves leaving just the mark. Plays once on
/// mount. Purely decorative — wraps the existing [EnqivraLogo] and adds no
/// state or logic beyond the animation itself.
class EnqivraLogoReveal extends StatefulWidget {
  const EnqivraLogoReveal({
    super.key,
    this.size = 120,
    this.onComplete,
  });

  final double size;
  final VoidCallback? onComplete;

  @override
  State<EnqivraLogoReveal> createState() => _EnqivraLogoRevealState();
}

class _EnqivraLogoRevealState extends State<EnqivraLogoReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onComplete?.call();
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ringBox = widget.size * 1.55;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Ring draws itself over the first 70% of the timeline, then
        // fades out over the remainder while the mark stays put.
        final drawT =
            Curves.easeInOutCubic.transform((t / 0.7).clamp(0.0, 1.0));
        final ringFade = t < 0.65
            ? 1.0
            : 1.0 - Curves.easeIn.transform(((t - 0.65) / 0.35).clamp(0.0, 1.0));
        // The mark fades/scales in slightly behind the ring's progress so
        // the ring reads as "drawing" it into existence rather than the
        // two elements animating independently.
        final markT =
            Curves.easeOutBack.transform(((t - 0.2) / 0.8).clamp(0.0, 1.0));
        return SizedBox(
          width: ringBox,
          height: ringBox,
          child: Stack(alignment: Alignment.center, children: [
            CustomPaint(
              size: Size.square(ringBox),
              painter: _RingPainter(
                progress: drawT,
                opacity: ringFade,
                color: palette.primaryBright,
                secondary: palette.violet,
              ),
            ),
            Opacity(
              opacity: markT.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.72 + 0.28 * markT,
                child: EnqivraLogo(size: widget.size),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.opacity,
    required this.color,
    required this.secondary,
  });
  final double progress;
  final double opacity;
  final Color color;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || progress <= 0) return;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2 - 4;

    // Whole-layer opacity: saveLayer with an alpha-only paint is the
    // standard way to fade a shader-painted stroke uniformly, since a
    // shader on the drawing Paint ignores that Paint's own color/alpha.
    canvas.saveLayer(rect, Paint()..color = Colors.black.withOpacity(opacity));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + 2 * pi,
        colors: [color, secondary, color.withOpacity(0)],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.opacity != opacity;
}
