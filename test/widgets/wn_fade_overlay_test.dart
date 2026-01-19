import 'package:flutter/material.dart'
    show BoxDecoration, Colors, Container, IgnorePointer, Key, LinearGradient, Positioned;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_fade_overlay.dart' show WnFadeOverlay;
import '../test_helpers.dart' show mountStackedWidget;

void main() {
  group('WnFadeOverlay tests', () {
    group('WnFadeOverlay.top', () {
      testWidgets('renders with IgnorePointer that ignores input', (WidgetTester tester) async {
        await mountStackedWidget(
          const WnFadeOverlay.top(key: Key('fade_top'), color: Colors.black),
          tester,
        );

        final ignorePointer = tester.widget<IgnorePointer>(
          find.descendant(
            of: find.byKey(const Key('fade_top')),
            matching: find.byType(IgnorePointer),
          ),
        );
        expect(ignorePointer.ignoring, isTrue);
      });

      testWidgets('gradient fades from solid to transparent', (WidgetTester tester) async {
        const testColor = Colors.red;
        await mountStackedWidget(
          const WnFadeOverlay.top(key: Key('fade_top'), color: testColor),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byKey(const Key('fade_top')),
            matching: find.byType(Container),
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.colors.first, testColor);
        expect(gradient.colors.last, testColor.withValues(alpha: 0));
      });
    });

    group('WnFadeOverlay.bottom', () {
      testWidgets('renders with IgnorePointer that ignores input', (WidgetTester tester) async {
        await mountStackedWidget(
          const WnFadeOverlay.bottom(key: Key('fade_bottom'), color: Colors.black),
          tester,
        );

        final ignorePointer = tester.widget<IgnorePointer>(
          find.descendant(
            of: find.byKey(const Key('fade_bottom')),
            matching: find.byType(IgnorePointer),
          ),
        );
        expect(ignorePointer.ignoring, isTrue);
      });

      testWidgets('gradient fades from transparent to solid', (WidgetTester tester) async {
        const testColor = Colors.blue;
        await mountStackedWidget(
          const WnFadeOverlay.bottom(key: Key('fade_bottom'), color: testColor),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byKey(const Key('fade_bottom')),
            matching: find.byType(Container),
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.colors.first, testColor.withValues(alpha: 0));
        expect(gradient.colors.last, testColor);
      });
    });

    group('custom height', () {
      testWidgets('applies custom height', (WidgetTester tester) async {
        const customHeight = 50.0;
        await mountStackedWidget(
          const WnFadeOverlay.top(
            key: Key('fade_custom'),
            color: Colors.black,
            height: customHeight,
          ),
          tester,
        );

        final positioned = tester.widget<Positioned>(find.byType(Positioned).first);
        expect(positioned.height, customHeight);
      });
    });

    group('positioning', () {
      testWidgets('top variant is positioned at top', (WidgetTester tester) async {
        await mountStackedWidget(
          const WnFadeOverlay.top(key: Key('fade_top'), color: Colors.black),
          tester,
        );

        final positioned = tester.widget<Positioned>(find.byType(Positioned).first);
        expect(positioned.top, 0);
      });

      testWidgets('top variant has null bottom', (WidgetTester tester) async {
        await mountStackedWidget(
          const WnFadeOverlay.top(key: Key('fade_top'), color: Colors.black),
          tester,
        );

        final positioned = tester.widget<Positioned>(find.byType(Positioned).first);
        expect(positioned.bottom, isNull);
      });

      testWidgets('bottom variant is positioned at bottom', (WidgetTester tester) async {
        await mountStackedWidget(
          const WnFadeOverlay.bottom(key: Key('fade_bottom'), color: Colors.black),
          tester,
        );

        final positioned = tester.widget<Positioned>(find.byType(Positioned).first);
        expect(positioned.bottom, 0);
      });

      testWidgets('bottom variant has null top', (WidgetTester tester) async {
        await mountStackedWidget(
          const WnFadeOverlay.bottom(key: Key('fade_bottom'), color: Colors.black),
          tester,
        );

        final positioned = tester.widget<Positioned>(find.byType(Positioned).first);
        expect(positioned.top, isNull);
      });
    });
  });
}
