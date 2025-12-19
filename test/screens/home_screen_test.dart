import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/screens/login_screen.dart';
import 'package:sloth/screens/signup_screen.dart';

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
  });
}
