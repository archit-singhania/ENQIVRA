import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:enqivra_mobile/shared/widgets/enqivra_scaffold.dart';
import 'package:enqivra_mobile/shared/widgets/glass_panel.dart';
import 'package:go_router/go_router.dart';
import 'package:enqivra_mobile/core/session/app_session.dart';
import 'package:enqivra_mobile/core/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<int>> counts() async {
    final org = AppSession.instance.organizationId;
    final results = await Future.wait([
      AppSession.instance.api.get('/assets?organizationId=$org'),
      AppSession.instance.api.get('/cases?organizationId=$org')
    ]);
    return [
      (results[0] as List).length,
      (results[1] as List).where((item) => item['status'] == 'OPEN').length
    ];
  }

  @override
  Widget build(BuildContext context) {
    final rawName = AppSession.instance.userName;
    final firstName = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim().split(' ').first
        : 'there';
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'E';

    return EnqivraScaffold(
      title: 'ENQIVRA',
      child: ListView(children: [
        _GreetingHeader(firstName: firstName, initial: initial)
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 26),
        _HeroAction(
                icon: Icons.search_rounded,
                title: 'Diagnose a problem',
                subtitle:
                    'Start a new case and let ENQIVRA guide the investigation.',
                onTap: () => context.push('/cases/new'))
            .animate()
            .fadeIn(delay: 80.ms, duration: 400.ms)
            .scale(begin: const Offset(0.97, 0.97), curve: Curves.easeOutCubic),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: _BentoTile(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Add equipment',
                      onTap: () => context.push('/assets/add'))
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 400.ms)
                  .slideX(begin: -0.05, end: 0, curve: Curves.easeOutCubic)),
          const SizedBox(width: 14),
          Expanded(
              child: _BentoTile(
                      icon: Icons.account_tree_outlined,
                      label: 'Knowledge library',
                      onTap: () => context.push('/knowledge'))
                  .animate()
                  .fadeIn(delay: 210.ms, duration: 400.ms)
                  .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic)),
        ]),
        const SizedBox(height: 34),
        Text('Workspace overview', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        FutureBuilder<List<int>>(
            future: counts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              final values = snapshot.data ?? [0, 0];
              final loading = snapshot.connectionState != ConnectionState.done;
              return _OverviewPanel(
                equipment: loading ? null : values[0],
                openCases: loading ? null : values[1],
              );
            }).animate().fadeIn(delay: 280.ms, duration: 400.ms),
        const SizedBox(height: 8),
      ]),
    );
  }
}

/// Personalized dashboard header — tapping the avatar goes to Profile
/// (an existing route), giving the greeting a real purpose rather than
/// being purely decorative.
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.firstName, required this.initial});
  final String firstName;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(children: [
      Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => context.push('/profile'),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: palette.primaryButton,
              boxShadow: [
                BoxShadow(
                    color: palette.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Text(initial,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: palette.onPrimary, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome back', style: Theme.of(context).textTheme.bodyMedium),
          Text(firstName,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ]),
      ),
    ]);
  }
}

/// The single, large primary call-to-action — replaces the old flat list
/// of equally-weighted rows with one clear "start here" moment.
class _HeroAction extends StatelessWidget {
  const _HeroAction(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: palette.primaryButton,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                  color: palette.primary.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 14)),
            ],
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: palette.onPrimary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(17)),
              child: Icon(icon, color: palette.onPrimary, size: 25),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: palette.onPrimary)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.onPrimary.withValues(alpha: 0.85))),
              ]),
            ),
            Icon(Icons.arrow_forward_rounded, color: palette.onPrimary),
          ]),
        ),
      ),
    );
  }
}

/// A square-ish bento tile for secondary actions, sitting two-up beside
/// each other instead of stacked as identical full-width rows.
class _BentoTile extends StatelessWidget {
  const _BentoTile(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: palette.glassFill,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: palette.glassBorder),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: palette.primary, size: 20),
            ),
            const SizedBox(height: 14),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Row(children: [
              Text('Open',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: palette.textMuted)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 13, color: palette.textMuted),
            ]),
          ]),
        ),
      ),
    );
  }
}

/// One unified glass card with a vertical divider, replacing the two
/// separate floating stat cards — reads as a single "overview" rather
/// than two unrelated numbers.
class _OverviewPanel extends StatelessWidget {
  const _OverviewPanel({required this.equipment, required this.openCases});
  final int? equipment;
  final int? openCases;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 6),
      child: Row(children: [
        Expanded(
            child: _OverviewStat(
                icon: Icons.precision_manufacturing_outlined,
                label: 'Equipment',
                value: equipment)),
        Container(width: 1, height: 54, color: palette.glassBorder),
        Expanded(
            child: _OverviewStat(
                icon: Icons.report_gmailerrorred_outlined,
                label: 'Open cases',
                value: openCases)),
      ]),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(children: [
      Icon(icon, color: palette.primaryBright),
      const SizedBox(height: 10),
      value == null
          ? const SizedBox(
              height: 26,
              width: 26,
              child: CircularProgressIndicator(strokeWidth: 2.2))
          : Text('$value', style: Theme.of(context).textTheme.displaySmall),
      const SizedBox(height: 4),
      Text(label, style: Theme.of(context).textTheme.bodyMedium),
    ]);
  }
}
