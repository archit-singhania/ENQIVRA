import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Spacer(), Text('ENQIVRA', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 4, color: Theme.of(context).colorScheme.primary)), const SizedBox(height: 20), Text('Understand what the physical world is telling you.', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: 20), Text('The mobile foundation is ready. Equipment capture and diagnostic investigations arrive in Phase 1 and beyond.', style: Theme.of(context).textTheme.bodyLarge), const Spacer()]))) ;
}
