import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:enqivra_mobile/core/theme.dart';
import 'package:enqivra_mobile/shared/widgets/aurora_background.dart';

/// Same public API as before (title / child / actions) — every screen
/// that used the old scaffold keeps working unchanged. Internally this
/// now renders the aurora backdrop, a large iOS-style title, and a
/// floating frosted-glass bottom dock instead of a flat NavigationBar.
class EnqivraScaffold extends StatelessWidget {
  const EnqivraScaffold(
      {required this.title,
      required this.child,
      super.key,
      this.actions = const []});
  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: AuroraBackground(
          child: SafeArea(
              bottom: false,
              child: Column(children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 12, 6),
                    child: Row(children: [
                      Expanded(
                          child: Text(title,
                              style: Theme.of(context).textTheme.headlineMedium)),
                      ...actions,
                    ])),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 116),
                        child: child)),
              ]))),
      bottomNavigationBar: _GlassDock(index: _index(context)));

  int _index(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/assets')) return 1;
    if (path.startsWith('/cases')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0;
  }
}

class _GlassDock extends StatelessWidget {
  const _GlassDock({required this.index});
  final int index;

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Home', '/'),
    (Icons.precision_manufacturing, Icons.precision_manufacturing_outlined,
        'Equipment', '/assets'),
    (Icons.history_rounded, Icons.history, 'Cases', '/cases'),
    (Icons.person_rounded, Icons.person_outline, 'Profile', '/profile'),
  ];

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                  height: 74,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.glassBorder),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 30,
                            offset: const Offset(0, 14))
                      ]),
                  child: Row(children: [
                    for (var i = 0; i < _items.length; i++)
                      Expanded(
                          child: _DockItem(
                              selected: i == index,
                              filled: _items[i].$1,
                              outline: _items[i].$2,
                              label: _items[i].$3,
                              onTap: () => context.go(_items[i].$4)))
                  ])))));
}

class _DockItem extends StatelessWidget {
  const _DockItem(
      {required this.selected,
      required this.filled,
      required this.outline,
      required this.label,
      required this.onTap});
  final bool selected;
  final IconData filled;
  final IconData outline;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withOpacity(0.16)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (widgetChild, animation) =>
                    ScaleTransition(scale: animation, child: widgetChild),
                child: Icon(selected ? filled : outline,
                    key: ValueKey(selected),
                    color:
                        selected ? AppColors.primaryBright : AppColors.textSecondary,
                    size: 23)),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.primaryBright : AppColors.textMuted),
                child: Text(label))
          ])));
}
