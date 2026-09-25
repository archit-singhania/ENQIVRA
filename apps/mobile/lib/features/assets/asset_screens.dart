import 'package:enqivra_mobile/shared/widgets/enqivra_scaffold.dart';
import 'package:enqivra_mobile/core/session/app_session.dart';
import 'package:enqivra_mobile/core/config/environment.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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
                              '${item['category']} • ${item['model'] ?? 'Model not set'}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/assets/${item['id']}',
                              extra: item))),
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

class ScanAssetScreen extends StatefulWidget {
  const ScanAssetScreen({super.key});
  @override
  State<ScanAssetScreen> createState() => _ScanAssetScreenState();
}

class _ScanAssetScreenState extends State<ScanAssetScreen> {
  final picker = ImagePicker();
  Map<String, dynamic>? result;
  String? error;
  bool busy = false;

  Future<void> scan(ImageSource source) async {
    final image = await picker.pickImage(source: source, imageQuality: 92);
    if (image == null) return;
    setState(() {
      busy = true;
      error = null;
      result = null;
    });
    try {
      final value = await AppSession.instance.api.analyzeEvidence(
          Environment.intelligenceApiUrl,
          await image.readAsBytes(),
          image.name,
          'IMAGE');
      if (mounted) setState(() => result = value);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Scan equipment')),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const Icon(Icons.center_focus_strong, size: 88),
        Text('Equipment label recognition',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Fill the frame with the manufacturer and model label.',
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        FilledButton.icon(
            onPressed: busy ? null : () => scan(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(busy ? 'Analyzing…' : 'Take label photo')),
        OutlinedButton.icon(
            onPressed: busy ? null : () => scan(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Choose existing photo')),
        if (error != null)
          Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                  padding: const EdgeInsets.all(16), child: Text(error!))),
        if (result != null) ...[
          const SizedBox(height: 20),
          Text('Local analysis', style: Theme.of(context).textTheme.titleLarge),
          ListTile(
              title: const Text('Status'),
              subtitle: Text(result!['status'] as String)),
          if (result!['extracted_text'] != null)
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child:
                        SelectableText(result!['extracted_text'] as String))),
          for (final candidate
              in result!['equipment_candidates'] as List<dynamic>)
            ListTile(
                leading: const Icon(Icons.verified_outlined),
                title: Text(candidate as String)),
          for (final observation in result!['observations'] as List<dynamic>)
            ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(observation as String)),
          for (final limitation in result!['limitations'] as List<dynamic>)
            ListTile(
                leading: const Icon(Icons.warning_amber),
                title: Text(limitation as String))
        ]
      ]));
}

class AssetDetailScreen extends StatefulWidget {
  const AssetDetailScreen({required this.asset, super.key});
  final Map<String, dynamic> asset;
  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  Future<List<dynamic>> load() async => await AppSession.instance.api
      .get('/assets/${widget.asset['id']}/components') as List<dynamic>;
  Future<Map<String, dynamic>> loadTwin() async =>
      await AppSession.instance.intelligence.get('/twins/${widget.asset['id']}')
          as Map<String, dynamic>;

  Future<void> recordReading() async {
    final metric = TextEditingController();
    final value = TextEditingController();
    final unit = TextEditingController();
    final warning = TextEditingController();
    final critical = TextEditingController();
    final submit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Record condition reading'),
                content: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: metric,
                      decoration: const InputDecoration(
                          labelText: 'Metric, e.g. temperature')),
                  TextField(
                      controller: value,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Value')),
                  TextField(
                      controller: unit,
                      decoration: const InputDecoration(labelText: 'Unit')),
                  TextField(
                      controller: warning,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Warning threshold (optional)')),
                  TextField(
                      controller: critical,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Critical threshold (optional)'))
                ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Record'))
                ]));
    if (submit != true ||
        metric.text.trim().isEmpty ||
        double.tryParse(value.text) == null ||
        unit.text.trim().isEmpty) {
      return;
    }
    await AppSession.instance.intelligence
        .post('/twins/${widget.asset['id']}/snapshots', body: {
      'metric': metric.text.trim(),
      'value': double.parse(value.text),
      'unit': unit.text.trim(),
      'warning_threshold': double.tryParse(warning.text),
      'critical_threshold': double.tryParse(critical.text)
    });
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(widget.asset['name'] as String), actions: [
        IconButton(
            tooltip: 'Add component',
            onPressed: () async {
              await context
                  .push('/assets/${widget.asset['id']}/components/add');
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.add))
      ]),
      body: FutureBuilder<List<dynamic>>(
          future: load(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            final components = snapshot.data ?? [];
            return ListView(padding: const EdgeInsets.all(20), children: [
              Text(widget.asset['category'] as String,
                  style: Theme.of(context).textTheme.titleLarge),
              Text(widget.asset['model']?.toString() ?? 'Model not set'),
              const SizedBox(height: 20),
              FutureBuilder<Map<String, dynamic>>(
                  future: loadTwin(),
                  builder: (context, twinSnapshot) {
                    final twin = twinSnapshot.data;
                    return Card(
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text('Digital twin',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                  if (twinSnapshot.hasError)
                                    Text(twinSnapshot.error.toString())
                                  else if (twin == null)
                                    const LinearProgressIndicator()
                                  else ...[
                                    Text(
                                        '${twin['health_state']} • health ${twin['health_index']}/100'),
                                    for (final prediction
                                        in twin['predictions'] as List<dynamic>)
                                      ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                              '${prediction['metric']} • ${prediction['state']}'),
                                          subtitle: Text(
                                              '${prediction['message']} Confidence ${((prediction['confidence'] as num) * 100).round()}%'))
                                  ],
                                  OutlinedButton.icon(
                                      onPressed: recordReading,
                                      icon: const Icon(
                                          Icons.monitor_heart_outlined),
                                      label: const Text(
                                          'Record condition reading'))
                                ])));
                  }),
              const SizedBox(height: 24),
              Text('Components', style: Theme.of(context).textTheme.titleLarge),
              if (components.isEmpty)
                const Card(
                    child: ListTile(
                        title: Text('No components recorded'),
                        subtitle: Text(
                            'Add components to build this asset’s physical structure.')))
              else
                for (final component in components)
                  Card(
                      child: ListTile(
                          leading: const Icon(Icons.settings_outlined),
                          title: Text(component['name'] as String),
                          subtitle: Text(component['componentType'] as String)))
            ]);
          }));
}

class AddComponentScreen extends StatefulWidget {
  const AddComponentScreen({required this.assetId, super.key});
  final String assetId;
  @override
  State<AddComponentScreen> createState() => _AddComponentScreenState();
}

class _AddComponentScreenState extends State<AddComponentScreen> {
  final name = TextEditingController();
  final type = TextEditingController();
  String? ontologyCode;
  String? error;
  bool busy = false;
  late final Future<List<dynamic>> types = AppSession.instance.api
      .get('/ontology/nodes?kind=COMPONENT_TYPE')
      .then((value) => value as List<dynamic>);

  Future<void> save() async {
    if (name.text.trim().isEmpty || type.text.trim().isEmpty) {
      setState(() => error = 'Name and component type are required');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await AppSession.instance.api
          .post('/assets/${widget.assetId}/components', body: {
        'name': name.text.trim(),
        'componentType': type.text.trim(),
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
  void dispose() {
    name.dispose();
    type.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Add component')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        TextField(
            controller: name,
            decoration: const InputDecoration(
                labelText: 'Component name', border: OutlineInputBorder())),
        const SizedBox(height: 14),
        TextField(
            controller: type,
            decoration: const InputDecoration(
                labelText: 'Component type', border: OutlineInputBorder())),
        const SizedBox(height: 14),
        FutureBuilder<List<dynamic>>(
            future: types,
            builder: (context, snapshot) => DropdownButtonFormField<String>(
                initialValue: ontologyCode,
                decoration: const InputDecoration(
                    labelText: 'Known component type (optional)',
                    border: OutlineInputBorder()),
                items: (snapshot.data ?? [])
                    .map((item) => DropdownMenuItem<String>(
                        value: item['code'] as String,
                        child: Text('${item['name']} • ${item['domain']}')))
                    .toList(),
                onChanged: snapshot.hasData
                    ? (value) => setState(() {
                          ontologyCode = value;
                          final match = snapshot.data!
                              .firstWhere((item) => item['code'] == value);
                          type.text = match['name'] as String;
                        })
                    : null)),
        if (error != null)
          Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(error!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error))),
        const SizedBox(height: 20),
        FilledButton(
            onPressed: busy ? null : save,
            child: Text(busy ? 'Saving…' : 'Save component'))
      ]));
}
