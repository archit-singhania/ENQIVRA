import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:enqivra_mobile/shared/widgets/enqivra_scaffold.dart';
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
  Widget build(BuildContext context) => EnqivraScaffold(
      title: 'ENQIVRA',
      child: ListView(children: [
        Text('Understand what the physical world is telling you.',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.w700))
            .animate()
            .fadeIn(duration: 450.ms)
            .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 28),
        _ActionTile(
                icon: Icons.search_rounded,
                label: 'Diagnose a problem',
                highlighted: true,
                onTap: () => context.push('/cases/new'))
            .animate()
            .fadeIn(delay: 80.ms, duration: 400.ms)
            .slideX(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 12),
        _ActionTile(
                icon: Icons.add_circle_outline_rounded,
                label: 'Add equipment',
                onTap: () => context.push('/assets/add'))
            .animate()
            .fadeIn(delay: 140.ms, duration: 400.ms)
            .slideX(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 12),
        _ActionTile(
                icon: Icons.account_tree_outlined,
                label: 'Explore knowledge library',
                onTap: () => context.push('/knowledge'))
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideX(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 32),
        Text('Workspace overview', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        FutureBuilder<List<int>>(
            future: counts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              final values = snapshot.data ?? [0, 0];
              final loading = snapshot.connectionState != ConnectionState.done;
              return Row(children: [
                Expanded(
                    child: _StatCard(
                        icon: Icons.precision_manufacturing_outlined,
                        label: 'Equipment',
                        value: loading ? null : values[0])),
                const SizedBox(width: 14),
                Expanded(
                    child: _StatCard(
                        icon: Icons.report_gmailerrorred_outlined,
                        label: 'Open cases',
                        value: loading ? null : values[1])),
              ]);
            }).animate().fadeIn(delay: 260.ms, duration: 400.ms)
      ]));
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.highlighted = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.transparent,
      child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                  gradient: highlighted ? AppGradients.primaryButton : null,
                  color: highlighted ? null : AppColors.glassFill,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color:
                          highlighted ? Colors.transparent : AppColors.glassBorder),
                  boxShadow: highlighted
                      ? [
                          BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 10))
                        ]
                      : null),
              child: Row(children: [
                Icon(icon,
                    color: highlighted ? AppColors.onPrimary : AppColors.primary),
                const SizedBox(width: 14),
                Expanded(
                    child: Text(label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: highlighted
                                ? AppColors.onPrimary
                                : AppColors.textPrimary))),
                Icon(Icons.arrow_forward_rounded,
                    color: highlighted ? AppColors.onPrimary : AppColors.textMuted,
                    size: 18)
              ]))));
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppColors.primaryBright),
        const SizedBox(height: 14),
        value == null
            ? const SizedBox(
                height: 26,
                width: 26,
                child: CircularProgressIndicator(strokeWidth: 2.2))
            : Text('$value', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodyMedium)
      ]));
}
