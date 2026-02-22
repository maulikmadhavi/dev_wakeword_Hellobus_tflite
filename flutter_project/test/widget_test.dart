import 'package:flutter_test/flutter_test.dart';
import 'package:hellobus_wakeword/main.dart';

void main() {
  testWidgets('App renders wakeword screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HellobusApp());
    expect(find.text('Hellobus Wakeword'), findsOneWidget);
    expect(find.text('Tap to start'), findsOneWidget);
  });
}
