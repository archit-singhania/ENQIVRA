import 'package:enqivra_mobile/core/session/app_session.dart';
import 'package:enqivra_mobile/shared/widgets/enqivra_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  final search = TextEditingController();
  String? domain;
  late Future<List<dynamic>> nodes = load();

  Future<List<dynamic>> load() async {
    final parameters = <String>[];
    if (domain != null) parameters.add('domain=$domain');
    if (search.text.trim().isNotEmpty) {
      parameters.add('q=${Uri.encodeQueryComponent(search.text.trim())}');
    }
    final suffix = parameters.isEmpty ? '' : '?${parameters.join('&')}';
    return await AppSession.instance.api.get('/ontology/nodes$suffix')
        as List<dynamic>;
  }

  void refresh() => setState(() => nodes = load());

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => EnqivraScaffold(
      title: 'Knowledge library',
      child: Column(children: [
        TextField(
            controller: search,
            onSubmitted: (_) => refresh(),
            decoration: InputDecoration(
                labelText: 'Search physical-system knowledge',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                    onPressed: refresh, icon: const Icon(Icons.arrow_forward)),
                border: const OutlineInputBorder())),
        const SizedBox(height: 12),
        SizedBox(
            height: 42,
            child: ListView(
                scrollDirection: Axis.horizontal,
                children: [null, 'COMMON', 'HVAC', 'AUTOMOTIVE', 'APPLIANCES']
                    .map((value) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                            label: Text(value ?? 'All'),
                            selected: domain == value,
                            onSelected: (_) {
                              domain = value;
                              refresh();
                            })))
                    .toList())),
        const SizedBox(height: 12),
        Expanded(
            child: FutureBuilder<List<dynamic>>(
                future: nodes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Center(
                        child: Text('No matching knowledge found.'));
                  }
                  return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index] as Map<String, dynamic>;
                        return Card(
                            child: ListTile(
                                leading:
                                    _SafetyBadge(item['safetyLevel'] as String),
                                title: Text(item['name'] as String),
                                subtitle: Text(
                                    '${_label(item['kind'] as String)} • ${item['domain']}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context
                                    .push('/knowledge/${item['code']}')));
                      });
                }))
      ]));
}

class KnowledgeDetailScreen extends StatelessWidget {
  const KnowledgeDetailScreen({required this.code, super.key});
  final String code;

  Future<Map<String, dynamic>> load() async =>
      await AppSession.instance.api.get('/ontology/nodes/$code')
          as Map<String, dynamic>;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Knowledge detail')),
      body: FutureBuilder<Map<String, dynamic>>(
          future: load(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            final data = snapshot.data!;
            final node = data['node'] as Map<String, dynamic>;
            final outgoing = data['outgoing'] as List<dynamic>;
            final incoming = data['incoming'] as List<dynamic>;
            return ListView(padding: const EdgeInsets.all(20), children: [
              Row(children: [
                _SafetyBadge(node['safetyLevel'] as String),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(node['name'] as String,
                        style: Theme.of(context).textTheme.headlineSmall))
              ]),
              const SizedBox(height: 8),
              Text('${_label(node['kind'] as String)} • ${node['domain']}'),
              const SizedBox(height: 20),
              Text(node['description'] as String),
              if (outgoing.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('What this connects to',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...outgoing.map((relation) => _RelationTile(relation: relation))
              ],
              if (incoming.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Referenced by',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...incoming.map((relation) => _RelationTile(relation: relation))
              ]
            ]);
          }));
}

class _RelationTile extends StatelessWidget {
  const _RelationTile({required this.relation});
  final dynamic relation;
  @override
  Widget build(BuildContext context) {
    final value = relation as Map<String, dynamic>;
    final node = value['node'] as Map<String, dynamic>;
    return Card(
        child: ListTile(
            title: Text(node['name'] as String),
            subtitle: Text(_label(value['relationship'] as String)),
            onTap: () => context.push('/knowledge/${node['code']}')));
  }
}

class _SafetyBadge extends StatelessWidget {
  const _SafetyBadge(this.level);
  final String level;
  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      'RED' => Colors.red,
      'ORANGE' => Colors.orange,
      'YELLOW' => Colors.amber.shade700,
      _ => Colors.green
    };
    return Semantics(
        label: '$level safety level',
        child: Container(
            width: 12,
            height: 42,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(8))));
  }
}

String _label(String value) => value
    .toLowerCase()
    .split('_')
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');
