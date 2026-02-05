import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/hooks/use_route_refresh.dart';

int _callCount = 0;

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      navigatorObservers: [routeObserver],
      home: HookBuilder(
        builder: (context) {
          useRouteRefresh(context, () => _callCount++);
          return ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const _SecondPage()),
            ),
            child: const Text('push'),
          );
        },
      ),
    ),
  );
}

class _SecondPage extends StatelessWidget {
  const _SecondPage();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('pop'),
    );
  }
}

void main() {
  setUp(() => _callCount = 0);

  group('useRouteRefresh', () {
    testWidgets('does not call callback on initial build', (tester) async {
      await _pump(tester);

      expect(_callCount, 0);
    });

    testWidgets('calls callback when route is popped back', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('push'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('pop'));
      await tester.pumpAndSettle();

      expect(_callCount, 1);
    });

    testWidgets('calls callback each time route is popped back', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('push'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('pop'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('push'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('pop'));
      await tester.pumpAndSettle();

      expect(_callCount, 2);
    });
  });
}
