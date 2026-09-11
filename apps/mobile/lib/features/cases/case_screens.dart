import 'package:enqivra_mobile/shared/widgets/enqivra_scaffold.dart';
import 'package:enqivra_mobile/core/session/app_session.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CaseHistoryScreen extends StatefulWidget {
  const CaseHistoryScreen({super.key});
  @override
  State<CaseHistoryScreen> createState() => _CaseHistoryScreenState();
}

class _CaseHistoryScreenState extends State<CaseHistoryScreen> {
  Future<List<dynamic>> load() async {
    final org = AppSession.instance.organizationId;
    return await AppSession.instance.api.get('/cases?organizationId=$org')
        as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) => EnqivraScaffold(
        title: 'Diagnostic cases',
        actions: [
          IconButton(
              onPressed: () async {
                await context.push('/cases/new');
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
            final cases = snapshot.data ?? [];
            if (cases.isEmpty) {
              return const Center(
                  child: Text(
                      'No diagnostic cases yet.\nDescribe a problem to open your first investigation.',
                      textAlign: TextAlign.center));
            }
            return ListView(children: [
              for (final item in cases)
                Card(
                    child: ListTile(
                        title: Text(item['title'] as String),
                        subtitle: Text(
                            '${item['status']} • Safety ${item['safetyLevel']}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/cases/${item['id']}',
                            extra: item as Map<String, dynamic>))),
            ]);
          },
        ),
      );
}

class NewCaseScreen extends StatefulWidget {
  const NewCaseScreen({super.key});
  @override
  State<NewCaseScreen> createState() => _NewCaseScreenState();
}

class _NewCaseScreenState extends State<NewCaseScreen> {
  final title = TextEditingController();
  final complaint = TextEditingController();
  String? assetId;
  bool busy = false;
  String? error;
  Future<List<dynamic>> assets() async => await AppSession.instance.api
          .get('/assets?organizationId=${AppSession.instance.organizationId}')
      as List<dynamic>;
  Future<void> save() async {
    if (assetId == null ||
        title.text.trim().isEmpty ||
        complaint.text.trim().isEmpty) {
      setState(() => error = 'Equipment, title, and description are required');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final created = await AppSession.instance.api.post(
          '/cases?organizationId=${AppSession.instance.organizationId}',
          body: {
            'assetId': assetId,
            'title': title.text.trim(),
            'complaint': complaint.text.trim()
          });
      if (mounted) {
        final caseData = created as Map<String, dynamic>;
        context.go('/cases/${caseData['id']}', extra: caseData);
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('New diagnostic case')),
      body: FutureBuilder<List<dynamic>>(
          future: assets(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data!;
            return ListView(padding: const EdgeInsets.all(20), children: [
              DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: 'Equipment', border: OutlineInputBorder()),
                  items: items
                      .map((item) => DropdownMenuItem<String>(
                          value: item['id'] as String,
                          child: Text(item['name'] as String)))
                      .toList(),
                  onChanged: (value) => assetId = value),
              const SizedBox(height: 16),
              TextField(
                  controller: title,
                  decoration: const InputDecoration(
                      labelText: 'Short title', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(
                  controller: complaint,
                  maxLines: 6,
                  decoration: const InputDecoration(
                      labelText: 'What is happening?',
                      hintText:
                          'Describe symptoms, timing, sounds, warnings, and recent changes.',
                      border: OutlineInputBorder())),
              if (error != null)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))),
              const SizedBox(height: 20),
              FilledButton(
                  onPressed: busy ? null : save,
                  child: Text(busy ? 'Creating…' : 'Create case'))
            ]);
          }));
}

class CaseDetailScreen extends StatefulWidget {
  const CaseDetailScreen({required this.caseData, super.key});
  final Map<String, dynamic> caseData;
  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  String get caseId => widget.caseData['id'] as String;
  bool uploading = false;
  String? message;
  final answer = TextEditingController();
  Map<String, dynamic>? investigation;
  bool investigationBusy = false;
  Future<List<dynamic>> load() async =>
      await AppSession.instance.api.get('/cases/$caseId/evidence')
          as List<dynamic>;

  @override
  void initState() {
    super.initState();
    loadInvestigation();
  }

  Future<void> loadInvestigation() async {
    try {
      final value = await AppSession.instance.intelligence
          .get('/investigations/by-case/$caseId');
      if (mounted && value != null) {
        setState(() => investigation = value as Map<String, dynamic>);
      }
    } catch (_) {}
  }

  Future<void> startInvestigation() async {
    setState(() => investigationBusy = true);
    try {
      final value = await AppSession.instance.intelligence
          .post('/investigations', body: {
        'case_id': caseId,
        'complaint': widget.caseData['complaint'] as String
      });
      if (mounted) {
        setState(() => investigation = value as Map<String, dynamic>);
      }
    } catch (e) {
      if (mounted) setState(() => message = e.toString());
    } finally {
      if (mounted) setState(() => investigationBusy = false);
    }
  }

  Future<void> submitObservation() async {
    if (answer.text.trim().isEmpty || investigation == null) return;
    setState(() => investigationBusy = true);
    try {
      final value = await AppSession.instance.intelligence.post(
          '/investigations/${investigation!['id']}/observations',
          body: {'answer': answer.text.trim()});
      answer.clear();
      if (mounted) {
        setState(() => investigation = value as Map<String, dynamic>);
      }
    } catch (e) {
      if (mounted) setState(() => message = e.toString());
    } finally {
      if (mounted) setState(() => investigationBusy = false);
    }
  }

  Future<void> upload() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null) return;
    final file = result.files.single;
    if (file.bytes == null) {
      setState(() => message = 'Could not read selected file');
      return;
    }
    setState(() {
      uploading = true;
      message = null;
    });
    try {
      await AppSession.instance.api.upload('/cases/$caseId/evidence',
          file.bytes!, file.name, _type(file.extension));
      setState(() => message = 'Evidence uploaded');
    } catch (e) {
      setState(() => message = e.toString());
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  String _type(String? extension) {
    final value = extension?.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'webp'].contains(value)) return 'IMAGE';
    if (['mp3', 'wav', 'm4a'].contains(value)) return 'AUDIO';
    if (['mp4', 'mov', 'webm'].contains(value)) return 'VIDEO';
    return 'DOCUMENT';
  }

  @override
  void dispose() {
    answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Case evidence')),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: uploading ? null : upload,
          icon: const Icon(Icons.attach_file),
          label: Text(uploading ? 'Uploading…' : 'Add evidence')),
      body: FutureBuilder<List<dynamic>>(
          future: load(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            return ListView(padding: const EdgeInsets.all(20), children: [
              Text(widget.caseData['title'] as String,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(widget.caseData['complaint'] as String),
              const SizedBox(height: 20),
              _InvestigationCard(
                  state: investigation,
                  busy: investigationBusy,
                  answer: answer,
                  onStart: startInvestigation,
                  onAnswer: submitObservation),
              const Divider(height: 36),
              Text('Evidence', style: Theme.of(context).textTheme.titleLarge),
              if (message != null)
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(message!))),
              if (snapshot.connectionState != ConnectionState.done)
                const Center(child: CircularProgressIndicator())
              else if (items.isEmpty)
                const Text('No evidence uploaded yet.')
              else
                for (final item in items)
                  ListTile(
                      leading: const Icon(Icons.attachment),
                      title: Text(item['originalFilename'] as String),
                      subtitle: Text(
                          '${item['evidenceType']} • ${item['sizeBytes']} bytes'))
            ]);
          }));
}

class _InvestigationCard extends StatelessWidget {
  const _InvestigationCard(
      {required this.state,
      required this.busy,
      required this.answer,
      required this.onStart,
      required this.onAnswer});
  final Map<String, dynamic>? state;
  final bool busy;
  final TextEditingController answer;
  final VoidCallback onStart;
  final VoidCallback onAnswer;

  @override
  Widget build(BuildContext context) {
    if (state == null) {
      return Card(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Guided investigation',
                        style: Theme.of(context).textTheme.titleLarge),
                    const Text(
                        'Start safety triage, grounded retrieval, and dynamic evidence questions.'),
                    const SizedBox(height: 12),
                    FilledButton(
                        onPressed: busy ? null : onStart,
                        child: Text(busy ? 'Starting…' : 'Start investigation'))
                  ])));
    }
    final level = state!['safety_level'] as String;
    final status = state!['status'] as String;
    final observations = state!['observations'] as List<dynamic>;
    final citations = state!['citations'] as List<dynamic>;
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Icon(level == 'RED'
                        ? Icons.dangerous
                        : Icons.health_and_safety_outlined),
                    const SizedBox(width: 8),
                    Text('Safety $level • ${status.replaceAll('_', ' ')}')
                  ]),
                  if (state!['safety_message'] != null) ...[
                    const SizedBox(height: 8),
                    Text(state!['safety_message'] as String,
                        style: TextStyle(
                            color: level == 'RED'
                                ? Colors.red
                                : Colors.orange.shade800))
                  ],
                  for (final item in observations) ...[
                    const Divider(),
                    Text(item['question'] as String,
                        style: Theme.of(context).textTheme.labelLarge),
                    Text(item['answer'] as String)
                  ],
                  if (state!['current_question'] != null) ...[
                    const Divider(),
                    Text(state!['current_question'] as String,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                        controller: answer,
                        maxLines: 3,
                        decoration: const InputDecoration(
                            labelText: 'Your observation',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    FilledButton(
                        onPressed: busy ? null : onAnswer,
                        child: Text(busy ? 'Saving…' : 'Submit observation'))
                  ],
                  if ((state!['evidence_summary'] as String).isNotEmpty) ...[
                    const Divider(),
                    Text('Grounded evidence',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(state!['evidence_summary'] as String)
                  ],
                  if (citations.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                        '${citations.length} local citation${citations.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.labelLarge),
                    for (final citation in citations)
                      Text(
                          '• ${citation['title']} • chunk ${citation['chunk']}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis)
                  ]
                ])));
  }
}
