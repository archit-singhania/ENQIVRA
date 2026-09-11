import 'package:enqivra_mobile/shared/widgets/enqivra_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:enqivra_mobile/core/session/app_session.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => EnqivraScaffold(
      title: 'Profile',
      child: Column(children: [
        const CircleAvatar(radius: 38, child: Icon(Icons.person, size: 38)),
        const SizedBox(height: 16),
        Text(AppSession.instance.userName ?? 'ENQIVRA user'),
        ListTile(
            leading: Icon(Icons.business_outlined),
            title: Text('Organization'),
            subtitle: Text('Manage members and roles'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/members')),
        ListTile(
            leading: Icon(Icons.swap_horiz),
            title: Text('Workspaces'),
            subtitle: Text('Switch organizations or accept an invitation'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/workspaces')),
        const ListTile(
            leading: Icon(Icons.security_outlined),
            title: Text('Security'),
            subtitle: Text('JWT access and rotating refresh tokens')),
        ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About the author'),
            subtitle: const Text('Who built ENQIVRA'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/about-author')),
        const Spacer(),
        OutlinedButton.icon(
            onPressed: () async {
              await AppSession.instance.logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'))
      ]));
}

class OrganizationMembersScreen extends StatefulWidget {
  const OrganizationMembersScreen({super.key});
  @override
  State<OrganizationMembersScreen> createState() =>
      _OrganizationMembersScreenState();
}

class _OrganizationMembersScreenState extends State<OrganizationMembersScreen> {
  final email = TextEditingController();
  String role = 'TECHNICIAN';
  String? message;
  late Future<List<dynamic>> memberFuture = load();
  late Future<List<dynamic>> invitationFuture = loadInvitations();
  Future<List<dynamic>> load() async => await AppSession.instance.api
          .get('/organizations/${AppSession.instance.organizationId}/members')
      as List<dynamic>;
  Future<List<dynamic>> loadInvitations() async =>
      await AppSession.instance.api.get(
              '/organizations/${AppSession.instance.organizationId}/invitations')
          as List<dynamic>;
  void reload() => setState(() {
        memberFuture = load();
        invitationFuture = loadInvitations();
      });
  Future<void> invite() async {
    try {
      final result = await AppSession.instance.api.post(
          '/organizations/${AppSession.instance.organizationId}/invitations',
          body: {'email': email.text.trim(), 'role': role});
      email.clear();
      final token = (result as Map<String, dynamic>)['token'] as String;
      setState(() => message = 'Invitation created. Share this code:\n$token');
      reload();
    } catch (e) {
      setState(() => message = e.toString());
    }
  }

  Future<void> changeRole(Map<String, dynamic> member, String role) async {
    try {
      await AppSession.instance.api.patch(
          '/organizations/${AppSession.instance.organizationId}/members/${member['userId']}',
          body: {'role': role});
      reload();
    } catch (e) {
      setState(() => message = e.toString());
    }
  }

  Future<void> remove(Map<String, dynamic> member) async {
    try {
      await AppSession.instance.api.delete(
          '/organizations/${AppSession.instance.organizationId}/members/${member['userId']}');
      reload();
    } catch (e) {
      setState(() => message = e.toString());
    }
  }

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Organization members')),
      body: FutureBuilder<List<dynamic>>(
          future: memberFuture,
          builder: (context, snapshot) {
            final members = snapshot.data ?? [];
            final canAdmin = ['OWNER', 'ADMIN']
                .contains(AppSession.instance.organizationRole);
            return ListView(padding: const EdgeInsets.all(20), children: [
              for (final member in members)
                ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(member['displayName'] as String),
                    subtitle: Text('${member['email']} • ${member['role']}'),
                    trailing: canAdmin
                        ? PopupMenuButton<String>(
                            onSelected: (action) {
                              if (action == 'REMOVE') {
                                remove(member as Map<String, dynamic>);
                              } else {
                                changeRole(
                                    member as Map<String, dynamic>, action);
                              }
                            },
                            itemBuilder: (context) => [
                                  for (final value in [
                                    'OWNER',
                                    'ADMIN',
                                    'TECHNICIAN',
                                    'VIEWER'
                                  ])
                                    PopupMenuItem(
                                        value: value,
                                        child: Text('Make $value')),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                      value: 'REMOVE',
                                      child: Text('Remove member'))
                                ])
                        : null),
              if (canAdmin) ...[
                const Divider(),
                Text('Invite member',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(
                        labelText: 'Role', border: OutlineInputBorder()),
                    items: ['ADMIN', 'TECHNICIAN', 'VIEWER']
                        .map((value) =>
                            DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (value) => role = value ?? role),
                const SizedBox(height: 12),
                FilledButton(
                    onPressed: invite, child: const Text('Create invitation')),
                if (message != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SelectableText(message!)),
                const SizedBox(height: 24),
                Text('Invitations',
                    style: Theme.of(context).textTheme.titleMedium),
                FutureBuilder<List<dynamic>>(
                    future: invitationFuture,
                    builder: (context, invitationSnapshot) => Column(children: [
                          for (final item in invitationSnapshot.data ?? [])
                            ListTile(
                                leading: const Icon(Icons.mail_outline),
                                title: Text(item['email'] as String),
                                subtitle:
                                    Text('${item['role']} • ${item['status']}'),
                                trailing: item['status'] == 'PENDING'
                                    ? IconButton(
                                        tooltip: 'Revoke invitation',
                                        icon: const Icon(Icons.close),
                                        onPressed: () async {
                                          await AppSession.instance.api.delete(
                                              '/organizations/${AppSession.instance.organizationId}/invitations/${item['id']}');
                                          reload();
                                        })
                                    : null)
                        ])),
              ] else
                const Card(
                    child: ListTile(
                        leading: Icon(Icons.visibility_outlined),
                        title: Text('Read-only membership access'),
                        subtitle: Text(
                            'Only owners and admins can invite, change, or remove members.')))
            ]);
          }));
}

class WorkspacesScreen extends StatefulWidget {
  const WorkspacesScreen({super.key});
  @override
  State<WorkspacesScreen> createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends State<WorkspacesScreen> {
  final code = TextEditingController();
  String? message;
  late Future<List<dynamic>> organizations = load();

  Future<List<dynamic>> load() async =>
      await AppSession.instance.api.get('/organizations') as List<dynamic>;

  Future<void> accept() async {
    try {
      await AppSession.instance.api
          .post('/invitations/accept', body: {'token': code.text.trim()});
      code.clear();
      setState(() {
        message = 'Invitation accepted';
        organizations = load();
      });
    } catch (e) {
      setState(() => message = e.toString());
    }
  }

  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Workspaces')),
      body: FutureBuilder<List<dynamic>>(
          future: organizations,
          builder: (context, snapshot) =>
              ListView(padding: const EdgeInsets.all(20), children: [
                Text('Your organizations',
                    style: Theme.of(context).textTheme.titleLarge),
                for (final item in snapshot.data ?? [])
                  ListTile(
                      selected:
                          item['id'] == AppSession.instance.organizationId,
                      leading: Icon(
                          item['id'] == AppSession.instance.organizationId
                              ? Icons.check_circle
                              : Icons.circle_outlined),
                      title: Text(item['name'] as String),
                      subtitle: Text(item['role'] as String),
                      onTap: () async {
                        await AppSession.instance
                            .switchOrganization(item['id'] as String);
                        if (mounted) setState(() {});
                      }),
                const Divider(height: 32),
                Text('Accept invitation',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                    controller: code,
                    decoration: const InputDecoration(
                        labelText: 'Invitation code',
                        border: OutlineInputBorder())),
                const SizedBox(height: 12),
                FilledButton(
                    onPressed: accept, child: const Text('Join organization')),
                if (message != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(message!))
              ])));
}
