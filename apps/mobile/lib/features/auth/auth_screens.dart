import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:enqivra_mobile/core/session/app_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    AppSession.instance.restore().then((ready) {
      if (ready && mounted) context.go('/');
    });
  }

  Future<void> submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await AppSession.instance.authenticate('/auth/login',
          {'email': email.text.trim(), 'password': password.text});
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: Center(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('ENQIVRA',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                        letterSpacing: 4,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)),
                            const SizedBox(height: 32),
                            Text('Welcome back',
                                style:
                                    Theme.of(context).textTheme.headlineLarge),
                            const SizedBox(height: 24),
                            TextField(
                                controller: email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder())),
                            const SizedBox(height: 16),
                            TextField(
                                controller: password,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    labelText: 'Password',
                                    border: OutlineInputBorder())),
                            if (error != null)
                              Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(error!,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error))),
                            const SizedBox(height: 20),
                            FilledButton(
                                onPressed: busy ? null : submit,
                                child: Text(busy ? 'Signing in…' : 'Sign in')),
                            TextButton(
                                onPressed: () => context.go('/register'),
                                child: const Text('Create an account'))
                          ]))))));
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final organization = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;
  Future<void> submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await AppSession.instance.authenticate('/auth/register', {
        'email': email.text.trim(),
        'password': password.text,
        'displayName': name.text.trim(),
        'organizationName': organization.text.trim()
      });
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(),
      body: ListView(padding: const EdgeInsets.all(28), children: [
        Text('Create your workspace',
            style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 24),
        TextField(
            controller: name,
            decoration: const InputDecoration(
                labelText: 'Name', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                labelText: 'Email', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextField(
            controller: organization,
            decoration: const InputDecoration(
                labelText: 'Organization', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'Password (10+ characters)',
                border: OutlineInputBorder())),
        if (error != null)
          Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(error!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error))),
        const SizedBox(height: 24),
        FilledButton(
            onPressed: busy ? null : submit,
            child: Text(busy ? 'Creating…' : 'Create account'))
      ]));
}
