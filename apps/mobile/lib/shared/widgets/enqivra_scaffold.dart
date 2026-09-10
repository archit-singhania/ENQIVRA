import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
          child: Padding(padding: const EdgeInsets.all(20), child: child)),
      bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.precision_manufacturing_outlined),
                label: 'Equipment'),
            NavigationDestination(icon: Icon(Icons.history), label: 'Cases'),
            NavigationDestination(
                icon: Icon(Icons.person_outline), label: 'Profile')
          ],
          selectedIndex: _index(context),
          onDestinationSelected: (index) =>
              context.go(['/', '/assets', '/cases', '/profile'][index])));
  int _index(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/assets')) return 1;
    if (path.startsWith('/cases')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0;
  }
}
