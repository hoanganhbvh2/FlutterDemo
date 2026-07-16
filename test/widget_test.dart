import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_demo/main.dart';

void main() {
  testWidgets('shows demo account selector before login', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Demo accounts'), findsOneWidget);
    expect(find.text('Enter app'), findsWidgets);
  });
}
