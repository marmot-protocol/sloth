import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sloth/l10n/generated/app_localizations.dart';
import 'package:sloth/screens/error_screen.dart';
import 'package:sloth/screens/wip_screen.dart';

import '../test_helpers.dart' show mountWidget, setUpTestView, testDesignSize;

void main() {
  const title = 'Test Error';
  const description = 'Something went wrong';
  const errorScreen = ErrorScreen(title: title, description: description);

  group('ErrorScreen', () {
    testWidgets('displays title', (tester) async {
      await mountWidget(errorScreen, tester);
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('displays description', (tester) async {
      await mountWidget(errorScreen, tester);
      expect(find.text(description), findsOneWidget);
    });

    testWidgets('displays sloth emoji', (tester) async {
      await mountWidget(errorScreen, tester);
      expect(find.text('🦥'), findsOneWidget);
    });

    testWidgets('displays Oh no! message', (tester) async {
      await mountWidget(errorScreen, tester);
      expect(find.text('Oh no!'), findsOneWidget);
    });

    testWidgets('displays Go back button', (tester) async {
      await mountWidget(errorScreen, tester);
      expect(find.text('Go back'), findsOneWidget);
    });

    testWidgets('displays Report error button', (tester) async {
      await mountWidget(errorScreen, tester);
      expect(find.text('Report error'), findsOneWidget);
    });

    group('navigation', () {
      late GoRouter router;

      setUp(() {
        router = GoRouter(
          initialLocation: '/home',
          routes: [
            GoRoute(path: '/home', builder: (_, _) => const Text('Home')),
            GoRoute(path: '/error', builder: (_, _) => errorScreen),
            GoRoute(path: '/wip', builder: (_, _) => const WipScreen()),
          ],
        );
      });

      Future<void> pumpErrorScreen(WidgetTester tester) async {
        setUpTestView(tester);

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: testDesignSize,
            builder: (_, _) => MaterialApp.router(
              routerConfig: router,
              locale: const Locale('en'),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        );
        router.push('/error');
        await tester.pumpAndSettle();
      }

      testWidgets('close button navigates back', (tester) async {
        await pumpErrorScreen(tester);
        await tester.tap(find.byKey(const Key('close_button')));
        await tester.pumpAndSettle();
        expect(find.text('Home'), findsOneWidget);
      });

      testWidgets('Go back button navigates back', (tester) async {
        await pumpErrorScreen(tester);
        await tester.tap(find.text('Go back'));
        await tester.pumpAndSettle();
        expect(find.text('Home'), findsOneWidget);
      });

      testWidgets('Report error button navigates to WipScreen', (tester) async {
        await pumpErrorScreen(tester);
        await tester.tap(find.text('Report error'));
        await tester.pumpAndSettle();
        expect(find.byType(WipScreen), findsOneWidget);
      });
    });
  });
}
