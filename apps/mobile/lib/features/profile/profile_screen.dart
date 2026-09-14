import 'package:enqivra_mobile/shared/widgets/enqivra_scaffold.dart';
import 'package:enqivra_mobile/shared/widgets/glass_panel.dart';
import 'package:enqivra_mobile/shared/widgets/sign_out_overlay.dart';
import 'package:enqivra_mobile/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:enqivra_mobile/core/session/app_session.dart';
import 'package:go_router/go_router.dart';

/// Rearranged (not just re-themed) from the original flat list: a hero
/// identity panel up top, sectioned glass groups ('Workspace', 'About')
/// instead of one undifferentiated list, and sign-out routed through the
/// animated [performSignOut] transition. `AppSession` reads/writes and all
/// navigation destinations are unchanged.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final rawName = AppSession.instance.userName;
    final name =
        (rawName != null && rawName.trim().isNotEmpty) ? rawName.trim() : 'ENQIVRA user';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'E';
    final role = AppSession.instance.organizationRole;

    return EnqivraScaffold(
      title: 'Profile',
      child: ListView(children: [
        _ProfileHero(name: name, initial: initial, role: role)
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 28),
        Text('Workspace', style: Theme.of(context).textTheme.titleSmall)
            .animate()
            .fadeIn(delay: 100.ms, duration: 350.ms),
        const SizedBox(height: 10),
        GlassPanel(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(children: [
                  _ProfileRow(
                      icon: Icons.business_outlined,
                      title: 'Organization',
                      subtitle: 'Manage members and roles',
                      onTap: () => context.push('/profile/members')),
                  _RowDivider(palette: palette),
                  _ProfileRow(
                      icon: Icons.swap_horiz_rounded,
                      title: 'Workspaces',
                      subtitle: 'Switch organizations or accept an invitation',
                      onTap: () => context.push('/profile/workspaces')),
                ]))
            .animate()
            .fadeIn(delay: 150.ms, duration: 400.ms)
            .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 24),
        Text('About', style: Theme.of(context).textTheme.titleSmall)
            .animate()
            .fadeIn(delay: 200.ms, duration: 350.ms),
        const SizedBox(height: 10),
        GlassPanel(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(children: [
                  const _ProfileRow(
                      icon: Icons.security_outlined,
                      title: 'Security',
                      subtitle: 'JWT access and rotating refresh tokens'),
                  _RowDivider(palette: palette),
                  _ProfileRow(
                      icon: Icons.info_outline_rounded,
                      title: 'About the author',
                      subtitle: 'Who built ENQIVRA',
                      onTap: () => context.push('/about-author')),
                ]))
            .animate()
            .fadeIn(delay: 250.ms, duration: 400.ms)
            .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 30),
        SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                    onPressed: () => performSignOut(context),
                    icon: Icon(Icons.logout_rounded, color: palette.danger),
                    label: Text('Sign out', style: TextStyle(color: palette.danger))))
            .animate()
            .fadeIn(delay: 320.ms, duration: 400.ms),
        const SizedBox(height: 12),
      ]),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider({required this.palette});
  final AppPalette palette;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Divider(height: 1, color: palette.glassBorder));
}

/// Identity panel replacing the old bare CircleAvatar + Text pair — a
/// gradient avatar (matching Home's greeting header) plus a role chip.
class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.name, required this.initial, this.role});
  final String name;
  final String initial;
  final String? role;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Row(children: [
        Container(
          width: 68,
          height: 68,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: palette.primaryButton,
            boxShadow: [
              BoxShadow(
                  color: palette.primary.withOpacity(0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: Text(initial,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: palette.onPrimary, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            if (role != null) ...[
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: palette.primary.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(999)),
                child: Text(role!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.primaryBright,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}

/// A single sectioned row (icon chip + title/subtitle + chevron),
/// replacing the plain default `ListTile`s so the whole screen reads as
/// one coherent glass surface instead of a bare Material list.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: palette.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, color: palette.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: palette.textMuted)),
              ]),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: palette.textMuted),
          ]),
        ),
      ),
    );
  }
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
