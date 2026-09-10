import 'package:enqivra_mobile/shared/widgets/enqivra_scaffold.dart';
import 'package:enqivra_mobile/core/session/app_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});
  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  Future<List<dynamic>> load() async {
    final org = AppSession.instance.organizationId;
    if (org == null) return [];
    return await AppSession.instance.api.get('/assets?organizationId=$org')
        as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) => EnqivraScaffold(
      title: 'My equipment',
      actions: [
        IconButton(
            onPressed: () async {
              await context.push('/assets/add');
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.add))
      ],
      child: FutureBuilder<List<dynamic>>(
          future: load(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            final items = snapshot.data ?? [];
            return ListView(children: [
              if (items.isEmpty)
                const Card(
                    child: ListTile(
                        leading: Icon(Icons.precision_manufacturing_outlined),
                        title: Text('No equipment yet'),
                        subtitle: Text(
                            'Add an asset to begin building its history.')))
              else
                for (final item in items)
                  Card(
                      child: ListTile(
                          leading: const Icon(
                              Icons.precision_manufacturing_outlined),
                          title: Text(item['name'] as String),
                          subtitle: Text(
                              '${item['category']} • ${item['model'] ?? 'Model not set'}'))),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                  onPressed: () => context.push('/assets/scan'),
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: const Text('Scan equipment label'))
            ]);
          }));
}

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key});
  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final name = TextEditingController();
  final category = TextEditingController();
  final model = TextEditingController();
  final serial = TextEditingController();
  bool busy = false;
  String? error;
  String? ontologyCode;
  late final Future<List<dynamic>> equipmentTypes = AppSession.instance.api
      .get('/ontology/nodes?kind=EQUIPMENT_TYPE')
      .then((value) => value as List<dynamic>);
  Future<void> save() async {
    if (name.text.trim().isEmpty || category.text.trim().isEmpty) {
      setState(() => error = 'Name and category are required');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final org = AppSession.instance.organizationId;
      await AppSession.instance.api.post('/assets?organizationId=$org', body: {
        'name': name.text.trim(),
        'category': category.text.trim(),
        'model': model.text.trim().isEmpty ? null : model.text.trim(),
        'serialNumber': serial.text.trim().isEmpty ? null : serial.text.trim(),
        'ontologyCode': ontologyCode
      });
      if (mounted) context.pop();
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Add equipment')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        TextField(
            controller: name,
            decoration: const InputDecoration(
                labelText: 'Equipment name', border: OutlineInputBorder())),
        const SizedBox(height: 14),
        TextField(
            controller: category,
            decoration: const InputDecoration(
                labelText: 'Category', border: OutlineInputBorder())),
        const SizedBox(height: 14),
        FutureBuilder<List<dynamic>>(
            future: equipmentTypes,
            builder: (context, snapshot) => DropdownButtonFormField<String>(
                initialValue: ontologyCode,
                decoration: const InputDecoration(
                    labelText: 'Known equipment type (optional)',
                    border: OutlineInputBorder()),
                items: (snapshot.data ?? [])
                    .map((item) => DropdownMenuItem<String>(
                        value: item['code'] as String,
                        child: Text('${item['name']} • ${item['domain']}')))
                    .toList(),
                onChanged: snapshot.hasData
                    ? (value) => setState(() => ontologyCode = value)
                    : null)),
        const SizedBox(height: 14),
        TextField(
            controller: model,
            decoration: const InputDecoration(
                labelText: 'Model', border: OutlineInputBorder())),
        const SizedBox(height: 14),
        TextField(
            controller: serial,
            decoration: const InputDecoration(
                labelText: 'Serial number', border: OutlineInputBorder())),
        if (error != null)
          Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(error!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error))),
        const SizedBox(height: 20),
        FilledButton(
            onPressed: busy ? null : save,
            child: Text(busy ? 'Saving…' : 'Save equipment'))
      ]));
}

class ScanAssetScreen extends StatelessWidget {
  const ScanAssetScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Scan equipment')),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.center_focus_strong, size: 96),
                const SizedBox(height: 20),
                Text('Camera/OCR arrives in Phase 3',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                    'For now, add manufacturer and model details manually.',
                    textAlign: TextAlign.center)
              ]))));
}
