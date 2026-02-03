import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_icon.dart';
import 'package:whitenoise/widgets/wn_menu.dart';
import 'package:whitenoise/widgets/wn_menu_item.dart';

import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnMenu tests', () {
    group('basic functionality', () {
      testWidgets('renders all menu items', (WidgetTester tester) async {
        final widget = WnMenu(
          children: [
            WnMenuItem(label: 'Item 1', onTap: () {}),
            WnMenuItem(label: 'Item 2', onTap: () {}),
            WnMenuItem(label: 'Item 3', onTap: () {}),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);
        expect(find.text('Item 3'), findsOneWidget);
      });

      testWidgets('renders with single menu item', (WidgetTester tester) async {
        final widget = WnMenu(
          children: [
            WnMenuItem(label: 'Single Item', onTap: () {}),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.text('Single Item'), findsOneWidget);
      });

      testWidgets('renders empty menu', (WidgetTester tester) async {
        const widget = WnMenu(children: []);
        await mountWidget(widget, tester);
        expect(find.byType(WnMenu), findsOneWidget);
      });
    });

    group('menu item interaction', () {
      testWidgets('menu items are tappable', (WidgetTester tester) async {
        var item1Tapped = false;
        var item2Tapped = false;
        final widget = WnMenu(
          children: [
            WnMenuItem(
              label: 'Item 1',
              onTap: () {
                item1Tapped = true;
              },
            ),
            WnMenuItem(
              label: 'Item 2',
              onTap: () {
                item2Tapped = true;
              },
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

    group('mixed menu item types', () {
      testWidgets('renders menu items with different types', (WidgetTester tester) async {
        final widget = WnMenu(
          children: [
            WnMenuItem(label: 'Primary', onTap: () {}),
            WnMenuItem(
              label: 'Secondary',
              onTap: () {},
              type: WnMenuItemType.secondary,
            ),
            WnMenuItem(
              label: 'Delete',
              onTap: () {},
              type: WnMenuItemType.destructive,
            ),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.text('Primary'), findsOneWidget);
        expect(find.text('Secondary'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('renders menu items with icons', (WidgetTester tester) async {
        final widget = WnMenu(
          children: [
            WnMenuItem(
              label: 'Settings',
              onTap: () {},
              icon: WnIcons.settings,
            ),
            WnMenuItem(
              label: 'Notifications',
              onTap: () {},
              icon: WnIcons.notification,
            ),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.byType(WnMenuItem), findsNWidgets(2));
      });
    });
  });
}
