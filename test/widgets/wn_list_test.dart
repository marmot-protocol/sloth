import 'package:flutter/material.dart' show Column, Icon, Icons, Key, SizedBox, Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_list.dart';
import 'package:sloth/widgets/wn_separator.dart';

import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnList tests', () {
    group('basic functionality', () {
      testWidgets('displays list items', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
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

      testWidgets('calls onTap when item tapped', (WidgetTester tester) async {
        var tappedIndex = -1;
        final widget = WnList(
          items: [
            WnListItem(title: 'Item 1', onTap: () => tappedIndex = 0),
            WnListItem(title: 'Item 2', onTap: () => tappedIndex = 1),
          ],
        );
        await mountWidget(widget, tester);
        await tester.tap(find.text('Item 1'));
        expect(tappedIndex, 0);
        await tester.tap(find.text('Item 2'));
        expect(tappedIndex, 1);
      });

      testWidgets('renders empty list without error', (WidgetTester tester) async {
        final widget = const WnList(items: []);
        await mountWidget(widget, tester);
        expect(find.byType(WnList), findsOneWidget);
      });

      testWidgets('renders single item list', (WidgetTester tester) async {
        final widget = const WnList(
          items: [WnListItem(title: 'Single Item')],
        );
        await mountWidget(widget, tester);
        expect(find.text('Single Item'), findsOneWidget);
      });
    });

    group('item content', () {
      testWidgets('displays title text', (WidgetTester tester) async {
        final widget = const WnList(
          items: [WnListItem(title: 'Test Title')],
        );
        await mountWidget(widget, tester);
        expect(find.text('Test Title'), findsOneWidget);
      });

      testWidgets('displays subtitle when provided', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
            WnListItem(title: 'Title', subtitle: 'Subtitle text'),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.text('Title'), findsOneWidget);
        expect(find.text('Subtitle text'), findsOneWidget);
      });

      testWidgets('does not display subtitle when not provided', (WidgetTester tester) async {
        final widget = const WnList(
          items: [WnListItem(title: 'Title Only')],
        );
        await mountWidget(widget, tester);
        expect(find.text('Title Only'), findsOneWidget);
        expect(find.byKey(const Key('list_item_subtitle_0')), findsNothing);
      });
    });

    group('separators', () {
      testWidgets('shows separators by default', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
            WnListItem(title: 'Item 1'),
            WnListItem(title: 'Item 2'),
            WnListItem(title: 'Item 3'),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byType(WnSeparator), findsNWidgets(2));
      });

      testWidgets('hides separators when showSeparators is false', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
            WnListItem(title: 'Item 1'),
            WnListItem(title: 'Item 2'),
          ],
          showSeparators: false,
        );
        await mountWidget(widget, tester);
        expect(find.byType(WnSeparator), findsNothing);
      });

      testWidgets('no separator for single item', (WidgetTester tester) async {
        final widget = const WnList(
          items: [WnListItem(title: 'Single')],
        );
        await mountWidget(widget, tester);
        expect(find.byType(WnSeparator), findsNothing);
      });

      testWidgets('no separator for empty list', (WidgetTester tester) async {
        final widget = const WnList(items: []);
        await mountWidget(widget, tester);
        expect(find.byType(WnSeparator), findsNothing);
      });
    });

    group('leading widgets', () {
      testWidgets('renders leading widget when provided', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
            WnListItem(
              title: 'With Leading',
              leading: Icon(Icons.star, key: Key('leading_icon')),
            ),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('leading_icon')), findsOneWidget);
      });

      testWidgets('does not render leading widget when not provided', (WidgetTester tester) async {
        final widget = const WnList(
          items: [WnListItem(title: 'No Leading')],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('list_item_leading_0')), findsNothing);
      });

      testWidgets('renders different leading widgets per item', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
            WnListItem(
              title: 'Item 1',
              leading: Icon(Icons.star, key: Key('star_icon')),
            ),
            WnListItem(
              title: 'Item 2',
              leading: Icon(Icons.favorite, key: Key('favorite_icon')),
            ),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('star_icon')), findsOneWidget);
        expect(find.byKey(const Key('favorite_icon')), findsOneWidget);
      });
    });

    group('trailing widgets', () {
      testWidgets('renders trailing widget when provided', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
            WnListItem(
              title: 'With Trailing',
              trailing: Icon(Icons.chevron_right, key: Key('trailing_icon')),
            ),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('trailing_icon')), findsOneWidget);
      });

      testWidgets('does not render trailing widget when not provided', (WidgetTester tester) async {
        final widget = const WnList(
          items: [WnListItem(title: 'No Trailing')],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('list_item_trailing_0')), findsNothing);
      });

      testWidgets('renders different trailing widgets per item', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
            WnListItem(
              title: 'Item 1',
              trailing: Icon(Icons.arrow_forward, key: Key('arrow_icon')),
            ),
            WnListItem(
              title: 'Item 2',
              trailing: Icon(Icons.more_vert, key: Key('more_icon')),
            ),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('arrow_icon')), findsOneWidget);
        expect(find.byKey(const Key('more_icon')), findsOneWidget);
      });
    });

    group('combined leading and trailing', () {
      testWidgets('renders both leading and trailing widgets', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
            WnListItem(
              title: 'Full Item',
              leading: Icon(Icons.person, key: Key('person_icon')),
              trailing: Icon(Icons.chevron_right, key: Key('chevron_icon')),
            ),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('person_icon')), findsOneWidget);
        expect(find.byKey(const Key('chevron_icon')), findsOneWidget);
      });

      testWidgets('renders item with subtitle and both widgets', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
            WnListItem(
              title: 'Title',
              subtitle: 'Subtitle',
              leading: Icon(Icons.star, key: Key('star_icon')),
              trailing: Icon(Icons.arrow_forward, key: Key('arrow_icon')),
            ),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.text('Title'), findsOneWidget);
        expect(find.text('Subtitle'), findsOneWidget);
        expect(find.byKey(const Key('star_icon')), findsOneWidget);
        expect(find.byKey(const Key('arrow_icon')), findsOneWidget);
      });
    });

    group('null onTap', () {
      testWidgets('renders correctly with null onTap', (WidgetTester tester) async {
        final widget = const WnList(
          items: [WnListItem(title: 'No Tap Handler')],
        );
        await mountWidget(widget, tester);
        expect(find.text('No Tap Handler'), findsOneWidget);
      });

      testWidgets('does not crash when tapped with null onTap', (WidgetTester tester) async {
        final widget = const WnList(
          items: [WnListItem(title: 'No Tap Handler')],
        );
        await mountWidget(widget, tester);
        await tester.tap(find.text('No Tap Handler'));
        expect(find.text('No Tap Handler'), findsOneWidget);
      });
    });

    group('selection state', () {
      testWidgets('highlights selected item', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
            WnListItem(title: 'Item 1'),
            WnListItem(title: 'Item 2', isSelected: true),
            WnListItem(title: 'Item 3'),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('list_item_selected_1')), findsOneWidget);
        expect(find.byKey(const Key('list_item_selected_0')), findsNothing);
        expect(find.byKey(const Key('list_item_selected_2')), findsNothing);
      });

      testWidgets('no selected styling when isSelected is false', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
            WnListItem(title: 'Item 1'),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('list_item_selected_0')), findsNothing);
      });

      testWidgets('multiple items can be selected', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
            WnListItem(title: 'Item 1', isSelected: true),
            WnListItem(title: 'Item 2', isSelected: true),
            WnListItem(title: 'Item 3'),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('list_item_selected_0')), findsOneWidget);
        expect(find.byKey(const Key('list_item_selected_1')), findsOneWidget);
        expect(find.byKey(const Key('list_item_selected_2')), findsNothing);
      });
    });

    group('custom item content', () {
      testWidgets('renders with complex leading widget', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
            WnListItem(
              title: 'Complex Leading',
              leading: SizedBox(
                key: Key('complex_leading'),
                width: 48,
                height: 48,
                child: Column(
                  children: [
                    Icon(Icons.person),
                    Text('A'),
                  ],
                ),
              ),
            ),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('complex_leading')), findsOneWidget);
      });

      testWidgets('renders with complex trailing widget', (WidgetTester tester) async {
        final widget = const WnList(
          items: [
            WnListItem(
              title: 'Complex Trailing',
              trailing: Column(
                key: Key('complex_trailing'),
                children: [
                  Text('99+'),
                  Icon(Icons.notifications),
                ],
              ),
            ),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('complex_trailing')), findsOneWidget);
      });
    });
  });
}
