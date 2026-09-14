import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:enqivra_mobile/core/theme.dart';
import 'package:enqivra_mobile/shared/widgets/aurora_background.dart';
import 'package:enqivra_mobile/shared/widgets/glass_panel.dart';
import 'package:enqivra_mobile/shared/widgets/enqivra_logo.dart';
import 'package:enqivra_mobile/shared/widgets/theme_toggle_button.dart';

/// A premium "about the author / maker" screen. Pure UI, no state or
/// network calls — edit the placeholder strings below with your real
/// name, role, and bio.
class AboutAuthorScreen extends StatelessWidget {
  const AboutAuthorScreen({super.key});

  // TODO: replace with your real details.
  static const _authorName = 'Your Name';
  static const _authorRole = 'Founder & Developer, ENQIVRA';
  static const _authorBio =
      'ENQIVRA was built to help technicians and field teams understand '
      'what the physical world is telling them — turning scattered '
      'equipment history, cases, and know-how into one focused workspace. '
      'Designed and engineered end-to-end, from the backend services to '
      'this app.';

  static const _skills = [
    'Flutter & Mobile',
    'System Design',
    'Cloud Infrastructure',
    'Product Design',
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/welcome'),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ThemeToggleButton(),
          ),
        ],
      ),
      body: AuroraBackground(
          child: SafeArea(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                  child: Column(children: [
                    const EnqivraLogo(size: 72, glow: true)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(
                            begin: const Offset(0.75, 0.75),
                            curve: Curves.easeOutBack),
                    const SizedBox(height: 24),
                    GlassPanel(
                            padding: const EdgeInsets.all(26),
                            child: Column(children: [
                              Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: palette.accentButton,
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                palette.violet.withOpacity(0.45),
                                            blurRadius: 36,
                                            spreadRadius: 2)
                                      ]),
                                  child: Icon(Icons.person_rounded,
                                      color: palette.onPrimary, size: 44)),
                              const SizedBox(height: 18),
                              Text(_authorName,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium),
                              const SizedBox(height: 4),
                              Text(_authorRole,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: palette.primaryBright)),
                              const SizedBox(height: 20),
                              Text(_authorBio,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge),
                              const SizedBox(height: 22),
                              Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    for (final skill in _skills)
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          decoration: BoxDecoration(
                                              color: palette.glassFill,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                  color: palette.glassBorder)),
                                          child: Text(skill,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      color: palette
                                                          .textPrimary)))
                                  ])
                            ]))
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 550.ms)
                        .slideY(
                            begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 28),
                    SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: OutlinedButton.icon(
                                onPressed: () => context.canPop()
                                    ? context.pop()
                                    : context.go('/welcome'),
                                icon: const Icon(Icons.home_outlined),
                                label: const Text('Back to home')))
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 500.ms),
                  ]))),
      ),
    );
  }
}
