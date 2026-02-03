import 'package:flutter/material.dart' show Icon, Icons, Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_list.dart';
import 'package:sloth/widgets/wn_list_item.dart';

import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnList tests', () {
    group('basic functionality', () {
      testWidgets('renders all list items', (WidgetTester tester) async {
        final widget = const WnList(
          children: [
            WnListItem(title: 'Item 1'),
            WnListItem(title: 'Item 2'),
            WnListItem(title: 'Item 3'),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);
        expect(find.text('Item 3'), findsOneWidget);
      });

      testWidgets('renders with single list item', (WidgetTester tester) async {
        final widget = const WnList(
          children: [WnListItem(title: 'Single Item')],
        );
        await mountWidget(widget, tester);
        expect(find.text('Single Item'), findsOneWidget);
      });

      testWidgets('renders empty list', (WidgetTester tester) async {
        const widget = WnList(children: []);
        await mountWidget(widget, tester);
        expect(find.byType(WnList), findsOneWidget);
      });
    });

    group('list item interaction', () {
      testWidgets('list items are tappable', (WidgetTester tester) async {
        var item1Tapped = false;
        var item2Tapped = false;
        final widget = WnList(
          children: [
            WnListItem(
              title: 'Item 1',
              onTap: () => item1Tapped = true,
            ),
            WnListItem(
              title: 'Item 2',
              onTap: () => item2Tapped = true,
            ),
          ],
        );
        await mountWidget(widget, tester);

        await tester.tap(find.text('Item 1'));
        expect(item1Tapped, isTrue);
        expect(item2Tapped, isFalse);

        await tester.tap(find.text('Item 2'));
        expect(item2Tapped, isTrue);
      });
    });

    group('list items with icons', () {
      testWidgets('renders list items with leading icons', (WidgetTester tester) async {
        final widget = const WnList(
          children: [
            WnListItem(
              title: 'Settings',
              leading: Icon(Icons.settings, key: Key('settings_icon')),
            ),
            WnListItem(
              title: 'Notifications',
              leading: Icon(Icons.notifications, key: Key('notifications_icon')),
            ),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.byKey(const Key('settings_icon')), findsOneWidget);
        expect(find.byKey(const Key('notifications_icon')), findsOneWidget);
      });

      testWidgets('renders list items with trailing icons', (WidgetTester tester) async {
        final widget = const WnList(
          children: [
            WnListItem(
              title: 'Item 1',
              trailing: Icon(Icons.chevron_right, key: Key('chevron_1')),
            ),
            WnListItem(
              title: 'Item 2',
              trailing: Icon(Icons.chevron_right, key: Key('chevron_2')),
            ),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('chevron_1')), findsOneWidget);
        expect(find.byKey(const Key('chevron_2')), findsOneWidget);
      });

      testWidgets('renders list items with both icons', (WidgetTester tester) async {
        final widget = const WnList(
          children: [
            WnListItem(
              title: 'Full Item',
              leading: Icon(Icons.star, key: Key('star_icon')),
              trailing: Icon(Icons.more_vert, key: Key('more_icon')),
            ),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('star_icon')), findsOneWidget);
        expect(find.byKey(const Key('more_icon')), findsOneWidget);
      });
    });
  });
}
