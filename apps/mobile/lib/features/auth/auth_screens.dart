import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:enqivra_mobile/core/session/app_session.dart';
import 'package:enqivra_mobile/core/theme.dart';
import 'package:enqivra_mobile/shared/widgets/aurora_background.dart';
import 'package:enqivra_mobile/shared/widgets/glass_panel.dart';
import 'package:enqivra_mobile/shared/widgets/enqivra_logo.dart';

/// Small frosted-glass "back to home" affordance used on both auth
/// screens so a visitor can always retreat to the welcome/landing screen.
class _BackHomeButton extends StatelessWidget {
  const _BackHomeButton();
  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.centerLeft,
      child: Material(
          color: AppColors.glassFill,
          shape: const CircleBorder(
              side: BorderSide(color: AppColors.glassBorder)),
          child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () =>
                  context.canPop() ? context.pop() : context.go('/welcome'),
              child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.arrow_back_rounded,
                      color: AppColors.textPrimary, size: 20)))));
}

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
      backgroundColor: AppColors.background,
      body: AuroraBackground(
          child: SafeArea(
              child: Center(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                          const _BackHomeButton()
                          .animate()
                      .fadeIn(duration: 400.ms),
                      const SizedBox(height: 20),
                      Center(
                      child: const EnqivraLogo(size: 76))
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(
                      begin: const Offset(0.7, 0.7),
                      curve: Curves.easeOutBack),
                                const SizedBox(height: 20),
                                Center(
                                        child: Text('ENQIVRA',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                    letterSpacing: 6,
                                                    color: AppColors.primaryBright)))
                                    .animate()
                                    .fadeIn(delay: 150.ms, duration: 400.ms),
                                const SizedBox(height: 36),
                                GlassPanel(
                                    padding: const EdgeInsets.all(28),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text('Welcome back',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge),
                                          const SizedBox(height: 6),
                                          Text(
                                              'Sign in to continue your investigations.',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                          const SizedBox(height: 28),
                                          TextField(
                                              controller: email,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              decoration: const InputDecoration(
                                                  labelText: 'Email',
                                                  prefixIcon: Icon(
                                                      Icons.alternate_email_rounded))),
                                          const SizedBox(height: 16),
                                          TextField(
                                              controller: password,
                                              obscureText: true,
                                              decoration: const InputDecoration(
                                                  labelText: 'Password',
                                                  prefixIcon: Icon(
                                                      Icons.lock_outline_rounded))),
                                          if (error != null)
                                            Padding(
                                                padding:
                                                    const EdgeInsets.only(top: 14),
                                                child: Text(error!,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .error))),
                                          const SizedBox(height: 22),
                                          SizedBox(
                                              height: 54,
                                              child: FilledButton(
                                                  onPressed: busy ? null : submit,
                                                  child: busy
                                                      ? const SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child: CircularProgressIndicator(
                                                              strokeWidth: 2.4,
                                                              color:
                                                                  AppColors.onPrimary))
                                                      : const Text('Sign in'))),
                                          Center(
                                              child: TextButton(
                                                  onPressed: () =>
                                                      context.go('/register'),
                                                  child: const Text(
                                                      'Create an account')))
                                        ]))
                                    .animate()
                                    .fadeIn(delay: 120.ms, duration: 500.ms)
                                    .slideY(
                                        begin: 0.06,
                                        end: 0,
                                        curve: Curves.easeOutCubic)
                              ])))))));
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/welcome'))),
      body: AuroraBackground(
          child: SafeArea(
              child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
            Center(child: const EnqivraLogo(size: 64))
                .animate()
                .fadeIn(duration: 450.ms)
                .scale(
                    begin: const Offset(0.75, 0.75),
                    curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Text('Create your workspace',
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text('A few details and your organization is ready.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            GlassPanel(
                padding: const EdgeInsets.all(24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                          controller: name,
                          decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(Icons.person_outline_rounded))),
                      const SizedBox(height: 16),
                      TextField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.alternate_email_rounded))),
                      const SizedBox(height: 16),
                      TextField(
                          controller: organization,
                          decoration: const InputDecoration(
                              labelText: 'Organization',
                              prefixIcon: Icon(Icons.business_outlined))),
                      const SizedBox(height: 16),
                      TextField(
                          controller: password,
                          obscureText: true,
                          decoration: const InputDecoration(
                              labelText: 'Password (10+ characters)',
                              prefixIcon: Icon(Icons.lock_outline_rounded))),
                      if (error != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Text(error!,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error))),
                      const SizedBox(height: 22),
                      SizedBox(
                          height: 54,
                          child: FilledButton(
                              onPressed: busy ? null : submit,
                              child: Text(busy ? 'Creating…' : 'Create account')))
                    ]))
                .animate()
                .fadeIn(duration: 450.ms)
                .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic)
                  ]))));
}
