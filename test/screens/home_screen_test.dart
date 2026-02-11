import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/screens/login_screen.dart';
import 'package:whitenoise/screens/signup_screen.dart';

import '../test_helpers.dart';

void main() {
  Future<void> mountHomeScreen(WidgetTester tester) async {
    await mountTestApp(tester);
  }

  group('HomeScreen', () {
    testWidgets('tapping Login navigates to LoginScreen', (tester) async {
      await mountHomeScreen(tester);
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('tapping Sign Up navigates to SignupScreen', (tester) async {
      await mountHomeScreen(tester);
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(find.byType(SignupScreen), findsOneWidget);
    });

    group('slogan', () {
      testWidgets('displays first slogan initially', (tester) async {
        await mountHomeScreen(tester);

        expect(find.text('Decentralized'), findsOneWidget);
        expect(find.text('Uncensorable'), findsNothing);
        expect(find.text('Secure Messaging'), findsNothing);
      });

      testWidgets('rotates to next slogan after interval', (tester) async {
        await mountHomeScreen(tester);

        expect(find.text('Decentralized'), findsOneWidget);

        await tester.pump(const Duration(seconds: 3));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Uncensorable'), findsOneWidget);
      });

      testWidgets('cycles back to first slogan after all shown', (tester) async {
        await mountHomeScreen(tester);

        expect(find.text('Decentralized'), findsOneWidget);

        await tester.pump(const Duration(seconds: 3));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Uncensorable'), findsOneWidget);

        await tester.pump(const Duration(seconds: 3));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Secure Messaging'), findsOneWidget);

        await tester.pump(const Duration(seconds: 3));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Decentralized'), findsOneWidget);
      });

      testWidgets('timer is canceled on dispose without errors', (tester) async {
        await mountHomeScreen(tester);

        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);

        await tester.pump(const Duration(seconds: 5));
      });
    });
  });
}
