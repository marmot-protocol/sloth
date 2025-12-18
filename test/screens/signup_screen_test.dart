import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/home_screen.dart';

void main() {
  Future<void> pumpSignupScreen(WidgetTester tester) async {
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
    Routes.pushToSignup(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('SignupScreen', () {
    testWidgets('displays Setup profile title', (tester) async {
      await pumpSignupScreen(tester);
      expect(find.text('Setup profile'), findsOneWidget);
    });

    testWidgets('displays name input field', (tester) async {
      await pumpSignupScreen(tester);
      expect(find.text('Choose a name'), findsOneWidget);
    });

    testWidgets('displays bio input field', (tester) async {
      await pumpSignupScreen(tester);
      expect(find.text('Introduce yourself'), findsOneWidget);
    });

    testWidgets('displays Cancel button', (tester) async {
      await pumpSignupScreen(tester);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays Sign Up button', (tester) async {
      await pumpSignupScreen(tester);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    group('navigation', () {
      testWidgets('tapping back button returns to home screen', (tester) async {
        await pumpSignupScreen(tester);
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('tapping Cancel returns to home screen', (tester) async {
        await pumpSignupScreen(tester);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('tapping outside slate returns to home screen', (tester) async {
        await pumpSignupScreen(tester);
        await tester.tapAt(const Offset(195, 50));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });
  });
}
