import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_media_error_placeholder.dart';

import '../test_helpers.dart';

void main() {
  group('WnMediaErrorPlaceholder', () {
    testWidgets('renders retry button', (tester) async {
      await mountWidget(WnMediaErrorPlaceholder(onRetry: () {}), tester);

      expect(find.byKey(const Key('retry_button')), findsOneWidget);
      expect(find.byKey(const Key('retry_icon')), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('calls onRetry when tapped', (tester) async {
      var retryCalled = false;
      await mountWidget(WnMediaErrorPlaceholder(onRetry: () => retryCalled = true), tester);

      await tester.tap(find.byKey(const Key('retry_button')));

      expect(retryCalled, isTrue);
    });

    testWidgets('uses provided width and height', (tester) async {
      await mountWidget(
        WnMediaErrorPlaceholder(onRetry: () {}, width: 200, height: 150),
        tester,
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, 200);
      expect(container.constraints?.maxHeight, 150);
    });

    testWidgets('uses default height when not provided', (tester) async {
      await mountWidget(WnMediaErrorPlaceholder(onRetry: () {}), tester);

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxHeight, 200);
    });
  });
}
