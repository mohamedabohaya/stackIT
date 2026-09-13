import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stack_it/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Splash screen shows the title then navigates to the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StackItApp());

    expect(find.text('STACK IT'), findsOneWidget);
    expect(find.text('PLAY'), findsNothing);

    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets('Daily reward dialog appears on first launch and can be claimed', (WidgetTester tester) async {
    await tester.pumpWidget(const StackItApp());
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    expect(find.text('DAILY REWARDS'), findsOneWidget);
    expect(find.textContaining('CLAIM +10'), findsOneWidget);

    await tester.tap(find.textContaining('CLAIM +10'));
    await tester.pumpAndSettle();

    expect(find.text('DAILY REWARDS'), findsNothing);
    expect(find.text('🪙 10'), findsOneWidget);
  });

  testWidgets('Tapping PLAY starts the game and dropping a block scores', (WidgetTester tester) async {
    await tester.pumpWidget(const StackItApp());
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    // Dismiss the daily reward dialog that auto-shows on first launch.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);

    await tester.tapAt(const Offset(200, 400));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('1'), findsWidgets);
  });
}
