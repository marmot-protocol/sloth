import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart' show Key, Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/theme/semantic_colors.dart';
import 'package:whitenoise/widgets/wn_icon.dart';
import 'package:whitenoise/widgets/wn_menu_item.dart';

import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnMenuItem tests', () {
    group('basic functionality', () {
      testWidgets('displays text label', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Settings',
          onTap: () {},
        );
        await mountWidget(widget, tester);
        expect(find.text('Settings'), findsOneWidget);
      });

      testWidgets('calls onTap when tapped', (WidgetTester tester) async {
        var onTapCalled = false;
        final widget = WnMenuItem(
          label: 'Settings',
          onTap: () {
            onTapCalled = true;
          },
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnMenuItem));
        expect(onTapCalled, isTrue);
      });
    });

    group('menu item types', () {
      testWidgets('renders primary type by default', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Primary',
          onTap: () {},
        );
        await mountWidget(widget, tester);
        expect(find.text('Primary'), findsOneWidget);
      });

      testWidgets('renders secondary type', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Secondary',
          onTap: () {},
          type: WnMenuItemType.secondary,
        );
        await mountWidget(widget, tester);
        expect(find.text('Secondary'), findsOneWidget);
      });

      testWidgets('renders destructive type', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Delete',
          onTap: () {},
          type: WnMenuItemType.destructive,
        );
        await mountWidget(widget, tester);
        expect(find.text('Delete'), findsOneWidget);
      });
    });

    group('icon', () {
      testWidgets('renders icon when provided', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Settings',
          onTap: () {},
          icon: WnIcons.settings,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('menu_item_icon')), findsOneWidget);
      });

      testWidgets('does not render icon when not provided', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Settings',
          onTap: () {},
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('menu_item_icon')), findsNothing);
      });
    });

    group('null onTap', () {
      testWidgets('renders correctly with null onTap', (WidgetTester tester) async {
        const widget = WnMenuItem(
          label: 'Disabled Item',
          onTap: null,
        );
        await mountWidget(widget, tester);
        expect(find.text('Disabled Item'), findsOneWidget);
      });

      testWidgets('does not crash when tapped with null onTap', (WidgetTester tester) async {
        const widget = WnMenuItem(
          label: 'Disabled Item',
          onTap: null,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnMenuItem));
        expect(find.text('Disabled Item'), findsOneWidget);
      });
    });

    group('icon with different types', () {
      testWidgets('renders icon with primary type', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Primary',
          onTap: () {},
          icon: WnIcons.settings,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('menu_item_icon')), findsOneWidget);
      });

      testWidgets('renders icon with secondary type', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Secondary',
          onTap: () {},
          icon: WnIcons.settings,
          type: WnMenuItemType.secondary,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('menu_item_icon')), findsOneWidget);
      });

      testWidgets('renders icon with destructive type', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Delete',
          onTap: () {},
          icon: WnIcons.trashCan,
          type: WnMenuItemType.destructive,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('menu_item_icon')), findsOneWidget);
      });
    });

    group('hover behavior', () {
      testWidgets('primary type changes color on hover', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Primary',
          onTap: () {},
        );
        await mountWidget(widget, tester);

        final textFinder = find.text('Primary');
        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.style?.color, SemanticColors.light.backgroundContentPrimary);

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: tester.getCenter(find.byType(WnMenuItem)));
        await tester.pump();

        final hoveredTextWidget = tester.widget<Text>(textFinder);
        expect(hoveredTextWidget.style?.color, SemanticColors.light.backgroundContentSecondary);

        await gesture.removePointer();
      });

      testWidgets('secondary type changes color on hover', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Secondary',
          onTap: () {},
          type: WnMenuItemType.secondary,
        );
        await mountWidget(widget, tester);

        final textFinder = find.text('Secondary');
        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.style?.color, SemanticColors.light.backgroundContentSecondary);

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: tester.getCenter(find.byType(WnMenuItem)));
        await tester.pump();

        final hoveredTextWidget = tester.widget<Text>(textFinder);
        expect(hoveredTextWidget.style?.color, SemanticColors.light.backgroundContentTertiary);

        await gesture.removePointer();
      });

      testWidgets('destructive type changes color on hover', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Delete',
          onTap: () {},
          type: WnMenuItemType.destructive,
        );
        await mountWidget(widget, tester);

        final textFinder = find.text('Delete');
        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.style?.color, SemanticColors.light.backgroundContentDestructive);

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: tester.getCenter(find.byType(WnMenuItem)));
        await tester.pump();

        final hoveredTextWidget = tester.widget<Text>(textFinder);
        expect(
          hoveredTextWidget.style?.color,
          SemanticColors.light.backgroundContentDestructiveSecondary,
        );

        await gesture.removePointer();
      });

      testWidgets('reverts to default color when hover ends', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Primary',
          onTap: () {},
        );
        await mountWidget(widget, tester);

        final textFinder = find.text('Primary');

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: tester.getCenter(find.byType(WnMenuItem)));
        await tester.pump();

        final hoveredTextWidget = tester.widget<Text>(textFinder);
        expect(hoveredTextWidget.style?.color, SemanticColors.light.backgroundContentSecondary);

        await gesture.removePointer();
        await tester.pump();

        final unhoveredTextWidget = tester.widget<Text>(textFinder);
        expect(unhoveredTextWidget.style?.color, SemanticColors.light.backgroundContentPrimary);
      });
    });

    group('pressed behavior (touch)', () {
      testWidgets('primary type changes color when pressed', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Primary',
          onTap: () {},
        );
        await mountWidget(widget, tester);

        final textFinder = find.text('Primary');
        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.style?.color, SemanticColors.light.backgroundContentPrimary);

        final gesture = await tester.startGesture(tester.getCenter(find.byType(WnMenuItem)));
        await tester.pump();

        final pressedTextWidget = tester.widget<Text>(textFinder);
        expect(pressedTextWidget.style?.color, SemanticColors.light.backgroundContentSecondary);

        await gesture.up();
      });

      testWidgets('secondary type changes color when pressed', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Secondary',
          onTap: () {},
          type: WnMenuItemType.secondary,
        );
        await mountWidget(widget, tester);

        final textFinder = find.text('Secondary');
        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.style?.color, SemanticColors.light.backgroundContentSecondary);

        final gesture = await tester.startGesture(tester.getCenter(find.byType(WnMenuItem)));
        await tester.pump();

        final pressedTextWidget = tester.widget<Text>(textFinder);
        expect(pressedTextWidget.style?.color, SemanticColors.light.backgroundContentTertiary);

        await gesture.up();
      });

      testWidgets('destructive type changes color when pressed', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Delete',
          onTap: () {},
          type: WnMenuItemType.destructive,
        );
        await mountWidget(widget, tester);

        final textFinder = find.text('Delete');
        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.style?.color, SemanticColors.light.backgroundContentDestructive);

        final gesture = await tester.startGesture(tester.getCenter(find.byType(WnMenuItem)));
        await tester.pump();

        final pressedTextWidget = tester.widget<Text>(textFinder);
        expect(
          pressedTextWidget.style?.color,
          SemanticColors.light.backgroundContentDestructiveSecondary,
        );

        await gesture.up();
      });

      testWidgets('reverts to default color when press ends', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Primary',
          onTap: () {},
        );
        await mountWidget(widget, tester);

        final textFinder = find.text('Primary');

        final gesture = await tester.startGesture(tester.getCenter(find.byType(WnMenuItem)));
        await tester.pump();

        final pressedTextWidget = tester.widget<Text>(textFinder);
        expect(pressedTextWidget.style?.color, SemanticColors.light.backgroundContentSecondary);

        await gesture.up();
        await tester.pump();

        final unpressedTextWidget = tester.widget<Text>(textFinder);
        expect(unpressedTextWidget.style?.color, SemanticColors.light.backgroundContentPrimary);
      });

      testWidgets('reverts to default color when press is cancelled', (WidgetTester tester) async {
        final widget = WnMenuItem(
          label: 'Primary',
          onTap: () {},
        );
        await mountWidget(widget, tester);

        final textFinder = find.text('Primary');

        final gesture = await tester.startGesture(tester.getCenter(find.byType(WnMenuItem)));
        await tester.pump();

        final pressedTextWidget = tester.widget<Text>(textFinder);
        expect(pressedTextWidget.style?.color, SemanticColors.light.backgroundContentSecondary);

        await gesture.cancel();
        await tester.pump();

        final unpressedTextWidget = tester.widget<Text>(textFinder);
        expect(unpressedTextWidget.style?.color, SemanticColors.light.backgroundContentPrimary);
      });
    });
  });
}
