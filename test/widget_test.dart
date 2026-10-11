import 'package:flutter_test/flutter_test.dart';
import 'package:lautcare/main.dart';

void main() {
  testWidgets('LAUTCARE app dapat ditampilkan', (WidgetTester tester) async {
    await tester.pumpWidget(const LautCareApp());

    expect(find.byType(LautCareApp), findsOneWidget);
  });
}
