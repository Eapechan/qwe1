import 'package:flutter_test/flutter_test.dart';
import 'package:qwe1/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const Qwe1App());
    await tester.pumpAndSettle();
    expect(find.text('Servers'), findsWidgets);
  });
}
