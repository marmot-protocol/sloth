import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sloth/widgets/wn_screen_header.dart' show WnScreenHeader;
import '../test_helpers.dart';

void main() {
  group('WnScreenHeader', () {
    testWidgets('displays title', (tester) async {
      await mountWidget(const WnScreenHeader(title: 'Settings'), tester);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('displays close icon', (tester) async {
      await mountWidget(const WnScreenHeader(title: 'Settings'), tester);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    group('navigation', () {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const Text('Home')),
          GoRoute(
            path: '/header',
            builder: (_, _) => const WnScreenHeader(title: 'Test'),
          ),
        ],
      );

      testWidgets('close button navigates back', (tester) async {
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: testDesignSize,
            builder: (_, _) => MaterialApp.router(routerConfig: router),
          ),
        );
        router.push('/header');
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('close_button')));
        await tester.pumpAndSettle();
        expect(find.text('Home'), findsOneWidget);
      });
    });
  });
}
