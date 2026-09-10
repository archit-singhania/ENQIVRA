import 'package:enqivra_mobile/core/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() { testWidgets('renders the ENQIVRA home shell', (tester) async { await tester.pumpWidget(const EnqivraApp()); expect(find.text('ENQIVRA'), findsOneWidget); }); }
