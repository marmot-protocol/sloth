import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/login_screen.dart';
import 'package:sloth/screens/signup_screen.dart';

void main() {
  Future<void> mountHomeScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, _) => Consumer(
            builder: (context, ref, _) {
              return MaterialApp.router(routerConfig: Routes.build(ref));
            },
          ),
        ),
      ),
    );
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
