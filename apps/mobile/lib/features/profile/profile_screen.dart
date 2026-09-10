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
        const ListTile(
            leading: Icon(Icons.security_outlined),
            title: Text('Security'),
            subtitle: Text('JWT access and rotating refresh tokens')),
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
  Future<List<dynamic>> load() async => await AppSession.instance.api
          .get('/organizations/${AppSession.instance.organizationId}/members')
      as List<dynamic>;
  Future<void> add() async {
    try {
      await AppSession.instance.api.post(
          '/organizations/${AppSession.instance.organizationId}/members',
          body: {'email': email.text.trim(), 'role': role});
      email.clear();
      setState(() => message = 'Member added');
    } catch (e) {
      setState(() => message = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Organization members')),
      body: FutureBuilder<List<dynamic>>(
          future: load(),
          builder: (context, snapshot) {
            final members = snapshot.data ?? [];
            return ListView(padding: const EdgeInsets.all(20), children: [
              for (final member in members)
                ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(member['displayName'] as String),
                    subtitle: Text('${member['email']} • ${member['role']}')),
              const Divider(),
              Text('Add registered user',
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
              FilledButton(onPressed: add, child: const Text('Add member')),
              if (message != null)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(message!))
            ]);
          }));
}
