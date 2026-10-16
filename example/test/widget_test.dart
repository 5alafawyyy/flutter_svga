import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('SVGA Flutter Samples home screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('SVGA Flutter Samples'), findsOneWidget);
    expect(find.text('Cache Example & Configuration'), findsOneWidget);
  });
}
