import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_auth_buttons_container.dart';
import 'package:sloth/widgets/wn_filled_button.dart';
import 'package:sloth/widgets/wn_outlined_button.dart';
import '../test_helpers.dart';

void main() {
  group('WnAuthButtonsContainer', () {
    testWidgets('displays Login button', (tester) async {
      const widget = WnAuthButtonsContainer();
      await mountWidget(widget, tester);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('displays Sign Up button', (tester) async {
      const widget = WnAuthButtonsContainer();
      await mountWidget(widget, tester);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('displays Login as outlined button', (tester) async {
      const widget = WnAuthButtonsContainer();
      await mountWidget(widget, tester);
      expect(find.byType(WnOutlinedButton), findsOneWidget);
      expect(
        find.descendant(of: find.byType(WnOutlinedButton), matching: find.text('Login')),
        findsOneWidget,
      );
    });

    testWidgets('displays Sign Up as filled button', (tester) async {
      const widget = WnAuthButtonsContainer();
      await mountWidget(widget, tester);
      expect(find.byType(WnFilledButton), findsOneWidget);
      expect(
        find.descendant(of: find.byType(WnFilledButton), matching: find.text('Sign Up')),
        findsOneWidget,
      );
    });

    testWidgets('calls onLogin when Login button is tapped', (tester) async {
      var onLoginCalled = false;
      final widget = WnAuthButtonsContainer(
        onLogin: () {
          onLoginCalled = true;
        },
      );
      await mountWidget(widget, tester);
      await tester.tap(find.text('Login'));
      expect(onLoginCalled, isTrue);
    });

    testWidgets('calls onSignup when Sign Up button is tapped', (tester) async {
      var onSignupCalled = false;
      final widget = WnAuthButtonsContainer(
        onSignup: () {
          onSignupCalled = true;
        },
      );
      await mountWidget(widget, tester);
      await tester.tap(find.text('Sign Up'));
      expect(onSignupCalled, isTrue);
    });

    testWidgets('calls both callbacks when provided', (tester) async {
      var onLoginCalled = false;
      var onSignupCalled = false;
      final widget = WnAuthButtonsContainer(
        onLogin: () {
          onLoginCalled = true;
        },
        onSignup: () {
          onSignupCalled = true;
        },
      );
      await mountWidget(widget, tester);
      await tester.tap(find.text('Login'));
      expect(onLoginCalled, isTrue);
      expect(onSignupCalled, isFalse);
      onLoginCalled = false;
      await tester.tap(find.text('Sign Up'));
      expect(onLoginCalled, isFalse);
      expect(onSignupCalled, isTrue);
    });

    testWidgets('navigates to login screen when Login tapped without callback', (tester) async {
      await mountTestApp(tester);
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your private key'), findsOneWidget);
    });

    testWidgets('navigates to signup screen when Sign Up tapped without callback', (tester) async {
      await mountTestApp(tester);
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(find.text('Choose a name'), findsOneWidget);
    });
  });
}
