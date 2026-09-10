import 'package:flutter/material.dart';
import 'package:enqivra_mobile/shared/widgets/enqivra_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:enqivra_mobile/core/session/app_session.dart';

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
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 28),
        FilledButton.icon(
            onPressed: () => context.push('/cases/new'),
            icon: const Icon(Icons.search),
            label: const Text('Diagnose a problem')),
        const SizedBox(height: 12),
        OutlinedButton.icon(
            onPressed: () => context.push('/assets/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add equipment')),
        const SizedBox(height: 28),
        Text('Workspace overview',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        FutureBuilder<List<int>>(
            future: counts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              final values = snapshot.data ?? [0, 0];
              return Column(children: [
                Card(
                    child: ListTile(
                        title: const Text('Equipment'),
                        trailing: Text('${values[0]}'))),
                Card(
                    child: ListTile(
                        title: const Text('Open cases'),
                        trailing: Text('${values[1]}')))
              ]);
            })
      ]));
}
