import 'package:enqivra_mobile/core/router.dart';
import 'package:enqivra_mobile/core/theme.dart';
import 'package:flutter/material.dart';

class EnqivraApp extends StatelessWidget {
  const EnqivraApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
      title: 'ENQIVRA', theme: buildTheme(), routerConfig: router);
}
