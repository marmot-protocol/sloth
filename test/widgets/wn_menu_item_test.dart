import 'package:flutter/material.dart' show Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_menu_item.dart';

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
  });
}
