import 'package:flutter/material.dart' show Column, CrossAxisAlignment, Key;
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

    group('list items with type icons', () {
      testWidgets('renders list items with type icons', (WidgetTester tester) async {
        final widget = const WnList(
          children: [
            WnListItem(
              title: 'Success',
              type: WnListItemType.success,
            ),
            WnListItem(
              title: 'Warning',
              type: WnListItemType.warning,
            ),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.text('Success'), findsOneWidget);
        expect(find.text('Warning'), findsOneWidget);
        expect(find.byKey(const Key('list_item_type_icon')), findsNWidgets(2));
      });
    });

    group('configurable spacing', () {
      testWidgets('uses default spacing when not specified', (WidgetTester tester) async {
        final widget = const WnList(
          children: [
            WnListItem(title: 'Item 1'),
            WnListItem(title: 'Item 2'),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byType(WnList), findsOneWidget);
      });

      testWidgets('applies custom spacing when specified', (WidgetTester tester) async {
        final widget = const WnList(
          spacing: 12.0,
          children: [
            WnListItem(title: 'Item 1'),
            WnListItem(title: 'Item 2'),
          ],
        );
        await mountWidget(widget, tester);

        final columnFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Column &&
              widget.spacing == 12.0 &&
              widget.crossAxisAlignment == CrossAxisAlignment.stretch,
        );
        expect(columnFinder, findsOneWidget);
      });

      testWidgets('applies zero spacing when specified', (WidgetTester tester) async {
        final widget = const WnList(
          spacing: 0,
          children: [
            WnListItem(title: 'Item 1'),
            WnListItem(title: 'Item 2'),
          ],
        );
        await mountWidget(widget, tester);

        final columnFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Column &&
              widget.spacing == 0 &&
              widget.crossAxisAlignment == CrossAxisAlignment.stretch,
        );
        expect(columnFinder, findsOneWidget);
      });
    });

    group('list items with actions', () {
      testWidgets('renders list with items that have actions', (WidgetTester tester) async {
        final widget = WnList(
          children: [
            WnListItem(
              title: 'With Actions',
              actions: [WnListItemAction(label: 'Edit', onTap: () {})],
            ),
            const WnListItem(title: 'Without Actions'),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.text('With Actions'), findsOneWidget);
        expect(find.text('Without Actions'), findsOneWidget);
      });
    });
  });
}
