import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_separator.dart';

import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnSeparator widget', () {
    group('horizontal orientation', () {
      testWidgets('renders with default horizontal orientation', (tester) async {
        await mountWidget(const WnSeparator(), tester);

        expect(find.byType(WnSeparator), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('has correct height for horizontal separator', (tester) async {
        await mountWidget(const WnSeparator(), tester);

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.constraints?.maxHeight, 1.0);
      });

      testWidgets('applies custom thickness for horizontal', (tester) async {
        await mountWidget(
          const WnSeparator(thickness: 2.0),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.constraints?.maxHeight, 2.0);
      });

      testWidgets('applies indent for horizontal', (tester) async {
        await mountWidget(
          const WnSeparator(indent: 16.0),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.margin, const EdgeInsets.only(left: 16.0));
      });

      testWidgets('applies endIndent for horizontal', (tester) async {
        await mountWidget(
          const WnSeparator(endIndent: 16.0),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.margin, const EdgeInsets.only(right: 16.0));
      });

      testWidgets('applies both indent and endIndent for horizontal', (tester) async {
        await mountWidget(
          const WnSeparator(indent: 8.0, endIndent: 16.0),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.margin, const EdgeInsets.only(left: 8.0, right: 16.0));
      });
    });

    group('vertical orientation', () {
      testWidgets('renders with vertical orientation', (tester) async {
        await mountWidget(
          const WnSeparator(orientation: WnSeparatorOrientation.vertical),
          tester,
        );

        expect(find.byType(WnSeparator), findsOneWidget);
      });

      testWidgets('has correct width for vertical separator', (tester) async {
        await mountWidget(
          const WnSeparator(orientation: WnSeparatorOrientation.vertical),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.constraints?.maxWidth, 1.0);
      });

      testWidgets('applies custom thickness for vertical', (tester) async {
        await mountWidget(
          const WnSeparator(
            orientation: WnSeparatorOrientation.vertical,
            thickness: 3.0,
          ),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.constraints?.maxWidth, 3.0);
      });

      testWidgets('applies indent for vertical', (tester) async {
        await mountWidget(
          const WnSeparator(
            orientation: WnSeparatorOrientation.vertical,
            indent: 12.0,
          ),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.margin, const EdgeInsets.only(top: 12.0));
      });

      testWidgets('applies endIndent for vertical', (tester) async {
        await mountWidget(
          const WnSeparator(
            orientation: WnSeparatorOrientation.vertical,
            endIndent: 12.0,
          ),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.margin, const EdgeInsets.only(bottom: 12.0));
      });

      testWidgets('applies both indent and endIndent for vertical', (tester) async {
        await mountWidget(
          const WnSeparator(
            orientation: WnSeparatorOrientation.vertical,
            indent: 4.0,
            endIndent: 8.0,
          ),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.margin, const EdgeInsets.only(top: 4.0, bottom: 8.0));
      });
    });

    group('color handling', () {
      testWidgets('uses borderTertiary color by default', (tester) async {
        await mountWidget(const WnSeparator(), tester);

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.color, SemanticColors.light.borderTertiary);
      });

      testWidgets('applies custom color', (tester) async {
        const customColor = Color(0xFFFF0000);
        await mountWidget(
          const WnSeparator(color: customColor),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.color, customColor);
      });

      testWidgets('handles transparent color', (tester) async {
        const transparentColor = Color(0x00000000);
        await mountWidget(
          const WnSeparator(color: transparentColor),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.color, transparentColor);
      });

      testWidgets('handles semi-transparent color', (tester) async {
        const semiTransparentColor = Color(0x80FF0000);
        await mountWidget(
          const WnSeparator(color: semiTransparentColor),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.color, semiTransparentColor);
      });
    });

    group('edge cases', () {
      testWidgets('handles zero thickness', (tester) async {
        await mountWidget(
          const WnSeparator(thickness: 0.0),
          tester,
        );

        expect(find.byType(WnSeparator), findsOneWidget);
      });

      testWidgets('handles fractional thickness', (tester) async {
        await mountWidget(
          const WnSeparator(thickness: 0.5),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.constraints?.maxHeight, 0.5);
      });

      testWidgets('handles large thickness', (tester) async {
        await mountWidget(
          const WnSeparator(thickness: 10.0),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.constraints?.maxHeight, 10.0);
      });

      testWidgets('handles zero indent', (tester) async {
        await mountWidget(
          const WnSeparator(),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.margin, EdgeInsets.zero);
      });

      testWidgets('handles large indent values', (tester) async {
        await mountWidget(
          const WnSeparator(indent: 100.0, endIndent: 100.0),
          tester,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WnSeparator),
            matching: find.byType(Container),
          ),
        );

        expect(container.margin, const EdgeInsets.only(left: 100.0, right: 100.0));
      });
    });

    group('widget properties', () {
      testWidgets('exposes orientation property', (tester) async {
        await mountWidget(
          const WnSeparator(orientation: WnSeparatorOrientation.vertical),
          tester,
        );

        final separator = tester.widget<WnSeparator>(find.byType(WnSeparator));
        expect(separator.orientation, WnSeparatorOrientation.vertical);
      });

      testWidgets('exposes thickness property', (tester) async {
        await mountWidget(
          const WnSeparator(thickness: 5.0),
          tester,
        );

        final separator = tester.widget<WnSeparator>(find.byType(WnSeparator));
        expect(separator.thickness, 5.0);
      });

      testWidgets('exposes indent property', (tester) async {
        await mountWidget(
          const WnSeparator(indent: 20.0),
          tester,
        );

        final separator = tester.widget<WnSeparator>(find.byType(WnSeparator));
        expect(separator.indent, 20.0);
      });

      testWidgets('exposes endIndent property', (tester) async {
        await mountWidget(
          const WnSeparator(endIndent: 30.0),
          tester,
        );

        final separator = tester.widget<WnSeparator>(find.byType(WnSeparator));
        expect(separator.endIndent, 30.0);
      });

      testWidgets('exposes color property', (tester) async {
        const customColor = Color(0xFF00FF00);
        await mountWidget(
          const WnSeparator(color: customColor),
          tester,
        );

        final separator = tester.widget<WnSeparator>(find.byType(WnSeparator));
        expect(separator.color, customColor);
      });
    });

    group('layout behavior', () {
      testWidgets('horizontal separator expands to fill width', (tester) async {
        await mountWidget(
          const SizedBox(
            width: 200,
            child: WnSeparator(),
          ),
          tester,
        );

        final separatorBox = tester.renderObject<RenderBox>(find.byType(WnSeparator));
        expect(separatorBox.size.width, 200.0);
      });

      testWidgets('vertical separator expands to fill height', (tester) async {
        await mountWidget(
          const SizedBox(
            height: 200,
            child: WnSeparator(orientation: WnSeparatorOrientation.vertical),
          ),
          tester,
        );

        final separatorBox = tester.renderObject<RenderBox>(find.byType(WnSeparator));
        expect(separatorBox.size.height, 200.0);
      });

      testWidgets('can be placed in a Row', (tester) async {
        await mountWidget(
          const Row(
            children: [
              Text('Left'),
              Expanded(child: WnSeparator()),
              Text('Right'),
            ],
          ),
          tester,
        );

        expect(find.byType(WnSeparator), findsOneWidget);
        expect(find.text('Left'), findsOneWidget);
        expect(find.text('Right'), findsOneWidget);
      });

      testWidgets('can be placed in a Column', (tester) async {
        await mountWidget(
          const Column(
            children: [
              Text('Top'),
              WnSeparator(),
              Text('Bottom'),
            ],
          ),
          tester,
        );

        expect(find.byType(WnSeparator), findsOneWidget);
        expect(find.text('Top'), findsOneWidget);
        expect(find.text('Bottom'), findsOneWidget);
      });
    });
  });

  group('WnSeparatorOrientation enum', () {
    test('has horizontal value', () {
      expect(WnSeparatorOrientation.horizontal, isNotNull);
    });

    test('has vertical value', () {
      expect(WnSeparatorOrientation.vertical, isNotNull);
    });

    test('has exactly two values', () {
      expect(WnSeparatorOrientation.values.length, 2);
    });
  });
}
