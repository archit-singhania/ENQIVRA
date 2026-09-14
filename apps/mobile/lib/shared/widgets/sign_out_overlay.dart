import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:enqivra_mobile/core/session/app_session.dart';
import 'package:enqivra_mobile/core/theme.dart';
import 'package:enqivra_mobile/shared/widgets/aurora_background.dart';
import 'package:enqivra_mobile/shared/widgets/enqivra_logo.dart';

/// Runs the existing [AppSession.logout] behind a short, full-screen glass
/// transition instead of an instant, jarring redirect — the mark settles
/// and fades while "Signing out" shows, then the app hands off to Login.
/// This changes nothing about what [AppSession.logout] actually does; it
/// only wraps the same call with a presentational moment around it.
Future<void> performSignOut(BuildContext context) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(navigator.push(PageRouteBuilder<void>(
    opaque: true,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => const _SignOutOverlay(),
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  )));

  await AppSession.instance.logout();
  // A small guaranteed-minimum dwell so the transition reads as an
  // intentional moment even when logout() resolves instantly (it's local
  // storage only — no network call).
  await Future.delayed(const Duration(milliseconds: 650));

  if (context.mounted) {
    context.go('/login');
    navigator.pop();
  }
}

class _SignOutOverlay extends StatefulWidget {
  const _SignOutOverlay();
  @override
  State<_SignOutOverlay> createState() => _SignOutOverlayState();
}

class _SignOutOverlayState extends State<_SignOutOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      body: AuroraBackground(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = Curves.easeInCubic.transform(_controller.value);
              return Opacity(
                opacity: 1 - (t * 0.5),
                child: Transform.scale(
                  scale: 1 - (t * 0.18),
                  child: child,
                ),
              );
            },
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const EnqivraLogo(size: 88),
              const SizedBox(height: 22),
              SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.4, color: palette.primaryBright)),
              const SizedBox(height: 16),
              Text('Signing out…',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: palette.textSecondary)),
            ]),
          ),
        ),
      ),
    );
  }
}
