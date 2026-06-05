import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:memory_match/main.dart';
import 'package:memory_match/services/store.dart';

void main() {
  testWidgets('Home screen shows title and all game modes',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await Store.init();

    await tester.pumpWidget(const MemoryApp());
    await tester.pumpAndSettle();

    expect(find.text('MEMORY\nMATCH'), findsOneWidget);
    expect(find.text('Zen'), findsOneWidget);
    expect(find.text('Contra cronometru'), findsOneWidget);
    expect(find.text('Provocarea zilei'), findsOneWidget);
    expect(find.text('Doi jucători'), findsOneWidget);
  });
}
