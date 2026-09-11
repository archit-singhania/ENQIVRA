import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:enqivra_mobile/core/session/app_session.dart';
import 'package:enqivra_mobile/core/theme.dart';
import 'package:enqivra_mobile/shared/widgets/aurora_background.dart';
import 'package:enqivra_mobile/shared/widgets/glass_panel.dart';
import 'package:enqivra_mobile/shared/widgets/enqivra_logo.dart';

/// The app's first-impression marketing / welcome screen. Pure UI: the only
/// side effect is the same silent "is there already a session" check the
/// login screen performs, so a returning user is never shown a splash they
/// don't need.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tilt = AnimationController(
      vsync: this, duration: const Duration(seconds: 7))
    ..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    AppSession.instance.restore().then((ready) {
      if (ready && mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _tilt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: AppColors.background,
      body: AuroraBackground(
          child: SafeArea(
              child: LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxHeight < 720;
        return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 52),
                child: Column(children: [
                  SizedBox(height: compact ? 8 : 28),
                  _TiltingMark(controller: _tilt)
                      .animate()
                      .fadeIn(duration: 650.ms)
                      .scale(
                          begin: const Offset(0.68, 0.68),
                          curve: Curves.easeOutBack,
                          duration: 750.ms),
                  SizedBox(height: compact ? 22 : 34),
                  Text('ENQIVRA',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: compact ? 38 : 46))
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 500.ms)
                      .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 12),
                  Text('Understand what the physical world is telling you.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AppColors.textSecondary))
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 500.ms)
                      .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
                  SizedBox(height: compact ? 26 : 40),
                  const _FeatureRow()
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 500.ms),
                  SizedBox(height: compact ? 26 : 40),
                  GlassPanel(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                    height: 56,
                                    child: FilledButton(
                                        onPressed: () =>
                                            context.push('/register'),
                                        child: const Text('Get started'))),
                                const SizedBox(height: 12),
                                SizedBox(
                                    height: 56,
                                    child: OutlinedButton(
                                        onPressed: () =>
                                            context.push('/login'),
                                        child: const Text(
                                            'I already have an account'))),
                              ]))
                      .animate()
                      .fadeIn(delay: 450.ms, duration: 550.ms)
                      .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
                  SizedBox(height: compact ? 30 : 52),
                  TextButton(
                          onPressed: () => context.push('/about-author'),
                          child: const Text('About the author'))
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 500.ms),
                ])));
      }))));
}

/// Gives the logo a slow, gentle 3D rock — Matrix4 perspective driven by
/// the animation controller — instead of a flat, static image.
class _TiltingMark extends StatelessWidget {
  const _TiltingMark({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final angle = (controller.value - 0.5) * 0.16;
        return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0018)
              ..rotateY(angle)
              ..rotateX(-angle * 0.5),
            child: child);
      },
      child: const EnqivraLogo(size: 136));
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  static const _items = [
    (Icons.travel_explore_rounded, 'Diagnose'),
    (Icons.hub_rounded, 'Track'),
    (Icons.verified_rounded, 'Resolve'),
  ];

  @override
  Widget build(BuildContext context) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final item in _items)
          Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.glassFill,
                    border: Border.all(color: AppColors.glassBorder),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.18),
                          blurRadius: 18)
                    ]),
                child:
                    Icon(item.$1, color: AppColors.primaryBright, size: 22)),
            const SizedBox(height: 8),
            Text(item.$2,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ])
      ]);
}
