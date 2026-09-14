import 'package:enqivra_mobile/core/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the ENQIVRA startup flow', (tester) async {
    await tester.pumpWidget(const EnqivraApp());
    expect(find.text('ENQIVRA'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
