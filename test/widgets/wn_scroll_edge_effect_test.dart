import 'package:flutter/material.dart'
    show BoxDecoration, Colors, Container, IgnorePointer, Key, LinearGradient, Positioned;
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_scroll_edge_effect.dart'
    show ScrollEdgeEffectType, ScrollEdgePosition, WnScrollEdgeEffect;
import '../test_helpers.dart' show mountStackedWidget;

void main() {
  group('WnScrollEdgeEffect tests', () {
    group('Canvas type', () {
      group('canvasTop', () {
        testWidgets('renders with IgnorePointer that ignores input', (WidgetTester tester) async {
          await mountStackedWidget(
            const WnScrollEdgeEffect.canvasTop(key: Key('canvas_top'), color: Colors.black),
            tester,
          );

          final ignorePointer = tester.widget<IgnorePointer>(
            find.descendant(
              of: find.byKey(const Key('canvas_top')),
              matching: find.byType(IgnorePointer),
            ),
          );
          expect(ignorePointer.ignoring, isTrue);
        });

        testWidgets('gradient fades from solid to transparent', (WidgetTester tester) async {
          const testColor = Colors.red;
          await mountStackedWidget(
            const WnScrollEdgeEffect.canvasTop(key: Key('canvas_top'), color: testColor),
            tester,
          );

          final container = tester.widget<Container>(
            find.descendant(
              of: find.byKey(const Key('canvas_top')),
              matching: find.byType(Container),
            ),
          );
          final decoration = container.decoration as BoxDecoration;
          final gradient = decoration.gradient as LinearGradient;

          expect(gradient.colors.first, testColor);
          expect(gradient.colors.last, testColor.withValues(alpha: 0));
        });

        testWidgets('is positioned at top', (WidgetTester tester) async {
          await mountStackedWidget(
            const WnScrollEdgeEffect.canvasTop(key: Key('canvas_top'), color: Colors.black),
            tester,
          );

          final positioned = tester.widget<Positioned>(find.byType(Positioned).first);
          expect(positioned.top, 0);
          expect(positioned.bottom, isNull);
        });
      });

      group('canvasBottom', () {
        testWidgets('renders with IgnorePointer that ignores input', (WidgetTester tester) async {
          await mountStackedWidget(
            const WnScrollEdgeEffect.canvasBottom(key: Key('canvas_bottom'), color: Colors.black),
            tester,
          );

          final ignorePointer = tester.widget<IgnorePointer>(
            find.descendant(
              of: find.byKey(const Key('canvas_bottom')),
              matching: find.byType(IgnorePointer),
            ),
          );
          expect(ignorePointer.ignoring, isTrue);
        });

        testWidgets('gradient fades from transparent to solid', (WidgetTester tester) async {
          const testColor = Colors.blue;
          await mountStackedWidget(
            const WnScrollEdgeEffect.canvasBottom(key: Key('canvas_bottom'), color: testColor),
            tester,
          );

          final container = tester.widget<Container>(
            find.descendant(
              of: find.byKey(const Key('canvas_bottom')),
              matching: find.byType(Container),
            ),
          );
          final decoration = container.decoration as BoxDecoration;
          final gradient = decoration.gradient as LinearGradient;

          expect(gradient.colors.first, testColor.withValues(alpha: 0));
          expect(gradient.colors.last, testColor);
        });

        testWidgets('is positioned at bottom', (WidgetTester tester) async {
          await mountStackedWidget(
            const WnScrollEdgeEffect.canvasBottom(key: Key('canvas_bottom'), color: Colors.black),
            tester,
          );

          final positioned = tester.widget<Positioned>(find.byType(Positioned).first);
          expect(positioned.bottom, 0);
          expect(positioned.top, isNull);
        });
      });
    });

    group('Slate type', () {
      group('slateTop', () {
        testWidgets('renders with IgnorePointer that ignores input', (WidgetTester tester) async {
          await mountStackedWidget(
            const WnScrollEdgeEffect.slateTop(key: Key('slate_top'), color: Colors.black),
            tester,
          );

          final ignorePointer = tester.widget<IgnorePointer>(
            find.descendant(
              of: find.byKey(const Key('slate_top')),
              matching: find.byType(IgnorePointer),
            ),
          );
          expect(ignorePointer.ignoring, isTrue);
        });

        testWidgets('gradient fades from solid to transparent', (WidgetTester tester) async {
          const testColor = Colors.green;
          await mountStackedWidget(
            const WnScrollEdgeEffect.slateTop(key: Key('slate_top'), color: testColor),
            tester,
          );

          final container = tester.widget<Container>(
            find.descendant(
              of: find.byKey(const Key('slate_top')),
              matching: find.byType(Container),
            ),
          );
          final decoration = container.decoration as BoxDecoration;
          final gradient = decoration.gradient as LinearGradient;

          expect(gradient.colors.first, testColor);
          expect(gradient.colors.last, testColor.withValues(alpha: 0));
        });

        testWidgets('is positioned at top', (WidgetTester tester) async {
          await mountStackedWidget(
            const WnScrollEdgeEffect.slateTop(key: Key('slate_top'), color: Colors.black),
            tester,
          );

          final positioned = tester.widget<Positioned>(find.byType(Positioned).first);
          expect(positioned.top, 0);
          expect(positioned.bottom, isNull);
        });
      });

      group('slateBottom', () {
        testWidgets('renders with IgnorePointer that ignores input', (WidgetTester tester) async {
          await mountStackedWidget(
            const WnScrollEdgeEffect.slateBottom(key: Key('slate_bottom'), color: Colors.black),
            tester,
          );

          final ignorePointer = tester.widget<IgnorePointer>(
            find.descendant(
              of: find.byKey(const Key('slate_bottom')),
              matching: find.byType(IgnorePointer),
            ),
          );
          expect(ignorePointer.ignoring, isTrue);
        });

        testWidgets('gradient fades from transparent to solid', (WidgetTester tester) async {
          const testColor = Colors.purple;
          await mountStackedWidget(
            const WnScrollEdgeEffect.slateBottom(key: Key('slate_bottom'), color: testColor),
            tester,
          );

          final container = tester.widget<Container>(
            find.descendant(
              of: find.byKey(const Key('slate_bottom')),
              matching: find.byType(Container),
            ),
          );
          final decoration = container.decoration as BoxDecoration;
          final gradient = decoration.gradient as LinearGradient;

          expect(gradient.colors.first, testColor.withValues(alpha: 0));
          expect(gradient.colors.last, testColor);
        });

        testWidgets('is positioned at bottom', (WidgetTester tester) async {
          await mountStackedWidget(
            const WnScrollEdgeEffect.slateBottom(key: Key('slate_bottom'), color: Colors.black),
            tester,
          );

          final positioned = tester.widget<Positioned>(find.byType(Positioned).first);
          expect(positioned.bottom, 0);
          expect(positioned.top, isNull);
        });
      });
    });

    group('Dropdown type', () {
      group('dropdownTop', () {
        testWidgets('renders with IgnorePointer that ignores input', (WidgetTester tester) async {
          await mountStackedWidget(
            const WnScrollEdgeEffect.dropdownTop(key: Key('dropdown_top'), color: Colors.black),
            tester,
          );

          final ignorePointer = tester.widget<IgnorePointer>(
            find.descendant(
              of: find.byKey(const Key('dropdown_top')),
              matching: find.byType(IgnorePointer),
            ),
          );
          expect(ignorePointer.ignoring, isTrue);
        });

        testWidgets('gradient fades from solid to transparent', (WidgetTester tester) async {
          const testColor = Colors.orange;
          await mountStackedWidget(
            const WnScrollEdgeEffect.dropdownTop(key: Key('dropdown_top'), color: testColor),
            tester,
          );

          final container = tester.widget<Container>(
            find.descendant(
              of: find.byKey(const Key('dropdown_top')),
              matching: find.byType(Container),
            ),
          );
          final decoration = container.decoration as BoxDecoration;
          final gradient = decoration.gradient as LinearGradient;

          expect(gradient.colors.first, testColor);
          expect(gradient.colors.last, testColor.withValues(alpha: 0));
        });

        testWidgets('is positioned at top', (WidgetTester tester) async {
          await mountStackedWidget(
            const WnScrollEdgeEffect.dropdownTop(key: Key('dropdown_top'), color: Colors.black),
            tester,
          );

          final positioned = tester.widget<Positioned>(find.byType(Positioned).first);
          expect(positioned.top, 0);
          expect(positioned.bottom, isNull);
        });
      });

      group('dropdownBottom', () {
        testWidgets('renders with IgnorePointer that ignores input', (WidgetTester tester) async {
          await mountStackedWidget(
            const WnScrollEdgeEffect.dropdownBottom(
              key: Key('dropdown_bottom'),
              color: Colors.black,
            ),
            tester,
          );

          final ignorePointer = tester.widget<IgnorePointer>(
            find.descendant(
              of: find.byKey(const Key('dropdown_bottom')),
              matching: find.byType(IgnorePointer),
            ),
          );
          expect(ignorePointer.ignoring, isTrue);
        });

        testWidgets('gradient fades from transparent to solid', (WidgetTester tester) async {
          const testColor = Colors.teal;
          await mountStackedWidget(
            const WnScrollEdgeEffect.dropdownBottom(
              key: Key('dropdown_bottom'),
              color: testColor,
            ),
            tester,
          );

          final container = tester.widget<Container>(
            find.descendant(
              of: find.byKey(const Key('dropdown_bottom')),
              matching: find.byType(Container),
            ),
          );
          final decoration = container.decoration as BoxDecoration;
          final gradient = decoration.gradient as LinearGradient;

          expect(gradient.colors.first, testColor.withValues(alpha: 0));
          expect(gradient.colors.last, testColor);
        });

        testWidgets('is positioned at bottom', (WidgetTester tester) async {
          await mountStackedWidget(
            const WnScrollEdgeEffect.dropdownBottom(
              key: Key('dropdown_bottom'),
              color: Colors.black,
            ),
            tester,
          );

          final positioned = tester.widget<Positioned>(find.byType(Positioned).first);
          expect(positioned.bottom, 0);
          expect(positioned.top, isNull);
        });
      });
    });

    group('custom height', () {
      testWidgets('applies custom height to canvas', (WidgetTester tester) async {
        const customHeight = 100.0;
        await mountStackedWidget(
          const WnScrollEdgeEffect.canvasTop(
            key: Key('canvas_custom'),
            color: Colors.black,
            height: customHeight,
          ),
          tester,
        );

        final positioned = tester.widget<Positioned>(find.byType(Positioned).first);
        expect(positioned.height, customHeight);
      });

      testWidgets('applies custom height to slate', (WidgetTester tester) async {
        const customHeight = 120.0;
        await mountStackedWidget(
          const WnScrollEdgeEffect.slateTop(
            key: Key('slate_custom'),
            color: Colors.black,
            height: customHeight,
          ),
          tester,
        );

        final positioned = tester.widget<Positioned>(find.byType(Positioned).first);
        expect(positioned.height, customHeight);
      });

      testWidgets('applies custom height to dropdown', (WidgetTester tester) async {
        const customHeight = 60.0;
        await mountStackedWidget(
          const WnScrollEdgeEffect.dropdownTop(
            key: Key('dropdown_custom'),
            color: Colors.black,
            height: customHeight,
          ),
          tester,
        );

        final positioned = tester.widget<Positioned>(find.byType(Positioned).first);
        expect(positioned.height, customHeight);
      });
    });

    group('enum values', () {
      test('ScrollEdgeEffectType has all expected values', () {
        expect(ScrollEdgeEffectType.values, contains(ScrollEdgeEffectType.canvas));
        expect(ScrollEdgeEffectType.values, contains(ScrollEdgeEffectType.slate));
        expect(ScrollEdgeEffectType.values, contains(ScrollEdgeEffectType.dropdown));
        expect(ScrollEdgeEffectType.values.length, 3);
      });

      test('ScrollEdgePosition has all expected values', () {
        expect(ScrollEdgePosition.values, contains(ScrollEdgePosition.top));
        expect(ScrollEdgePosition.values, contains(ScrollEdgePosition.bottom));
        expect(ScrollEdgePosition.values.length, 2);
      });
    });
  });
}
