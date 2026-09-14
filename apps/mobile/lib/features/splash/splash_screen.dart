import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:enqivra_mobile/core/theme.dart';
import 'package:enqivra_mobile/shared/widgets/aurora_background.dart';
import 'package:enqivra_mobile/shared/widgets/logo_reveal.dart';

/// The very first thing shown when the app process starts — a brief,
/// purely presentational "mark materializing" moment before handing off
/// to the existing welcome flow. This screen performs no auth/network
/// work itself: [LandingScreen] already does the silent "is there a
/// session" check and redirects to '/' when one exists, so Splash only
/// owns the animation and a single, unconditional navigation call once
/// it finishes — zero business logic added or duplicated.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  void _proceed() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) context.go('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      body: AuroraBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EnqivraLogoReveal(size: 108, onComplete: _proceed),
              const SizedBox(height: 22),
              Text('ENQIVRA',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 7, color: palette.textSecondary))
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
