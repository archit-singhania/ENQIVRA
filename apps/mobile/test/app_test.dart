import 'package:enqivra_mobile/core/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the ENQIVRA login', (tester) async {
    await tester.pumpWidget(const EnqivraApp());
    expect(find.text('ENQIVRA'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
