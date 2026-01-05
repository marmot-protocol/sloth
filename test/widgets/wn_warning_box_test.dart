import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_warning_box.dart' show WnWarningBox;
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnWarningBox', () {
    testWidgets('displays title', (tester) async {
      const widget = WnWarningBox(
        title: 'Warning Title',
        description: 'Warning description',
      );
      await mountWidget(widget, tester);
      expect(find.text('Warning Title'), findsOneWidget);
    });

    testWidgets('displays description', (tester) async {
      const widget = WnWarningBox(
        title: 'Warning Title',
        description: 'Warning description',
      );
      await mountWidget(widget, tester);
      expect(find.text('Warning description'), findsOneWidget);
    });

    testWidgets('displays default warning icon', (tester) async {
      const widget = WnWarningBox(
        title: 'Warning Title',
        description: 'Warning description',
      );
      await mountWidget(widget, tester);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('displays custom icon when provided', (tester) async {
      const widget = WnWarningBox(
        title: 'Warning Title',
        description: 'Warning description',
        icon: Icons.info_outline,
      );
      await mountWidget(widget, tester);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });

    testWidgets('applies custom backgroundColor when provided', (tester) async {
      const customColor = Color(0xFF123456);
      const widget = WnWarningBox(
        title: 'Warning Title',
        description: 'Warning description',
        backgroundColor: customColor,
      );
      await mountWidget(widget, tester);
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Warning Title'),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, customColor);
    });

    testWidgets('applies custom borderColor when provided', (tester) async {
      const customColor = Color(0xFF654321);
      const widget = WnWarningBox(
        title: 'Warning Title',
        description: 'Warning description',
        borderColor: customColor,
      );
      await mountWidget(widget, tester);
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Warning Title'),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      final border = decoration.border as Border;
      expect(border.top.color, customColor);
    });

    testWidgets('applies custom iconColor when provided', (tester) async {
      const customColor = Color(0xFFABCDEF);
      const widget = WnWarningBox(
        title: 'Warning Title',
        description: 'Warning description',
        iconColor: customColor,
      );
      await mountWidget(widget, tester);
      final icon = tester.widget<Icon>(find.byIcon(Icons.warning_amber_rounded));
      expect(icon.color, customColor);
    });

    testWidgets('applies custom titleColor when provided', (tester) async {
      const customColor = Color(0xFFFEDCBA);
      const widget = WnWarningBox(
        title: 'Warning Title',
        description: 'Warning description',
        titleColor: customColor,
      );
      await mountWidget(widget, tester);
      final text = tester.widget<Text>(find.text('Warning Title'));
      final textStyle = text.style;
      expect(textStyle?.color, customColor);
    });

    testWidgets('applies custom descriptionColor when provided', (tester) async {
      const customColor = Color(0xFF112233);
      const widget = WnWarningBox(
        title: 'Warning Title',
        description: 'Warning description',
        descriptionColor: customColor,
      );
      await mountWidget(widget, tester);
      final text = tester.widget<Text>(find.text('Warning description'));
      final textStyle = text.style;
      expect(textStyle?.color, customColor);
    });

    testWidgets('has rounded corners', (tester) async {
      const widget = WnWarningBox(
        title: 'Warning Title',
        description: 'Warning description',
      );
      await mountWidget(widget, tester);
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Warning Title'),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
    });
  });
}
