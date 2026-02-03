import 'package:flutter/material.dart' show BoxDecoration, Container, Icon, Icons, Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_list_item.dart';

import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnListItem tests', () {
    group('basic functionality', () {
      testWidgets('displays title text', (WidgetTester tester) async {
        final widget = const WnListItem(title: 'Test Item');
        await mountWidget(widget, tester);
        expect(find.text('Test Item'), findsOneWidget);
      });

      testWidgets('calls onTap when tapped', (WidgetTester tester) async {
        var onTapCalled = false;
        final widget = WnListItem(
          title: 'Tappable Item',
          onTap: () => onTapCalled = true,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnListItem));
        expect(onTapCalled, isTrue);
      });

      testWidgets('renders correctly with null onTap', (WidgetTester tester) async {
        final widget = const WnListItem(title: 'No Tap Handler');
        await mountWidget(widget, tester);
        expect(find.text('No Tap Handler'), findsOneWidget);
      });

      testWidgets('does not crash when tapped with null onTap', (WidgetTester tester) async {
        final widget = const WnListItem(title: 'No Tap Handler');
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnListItem));
        expect(find.text('No Tap Handler'), findsOneWidget);
      });
    });

    group('leading widget', () {
      testWidgets('renders leading widget when provided', (WidgetTester tester) async {
        final widget = const WnListItem(
          title: 'With Leading',
          leading: Icon(Icons.star, key: Key('leading_icon')),
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('leading_icon')), findsOneWidget);
        expect(find.byKey(const Key('list_item_leading')), findsOneWidget);
      });

      testWidgets('does not render leading widget when not provided', (WidgetTester tester) async {
        final widget = const WnListItem(title: 'No Leading');
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('list_item_leading')), findsNothing);
      });
    });

    group('trailing widget', () {
      testWidgets('renders trailing widget when provided', (WidgetTester tester) async {
        final widget = const WnListItem(
          title: 'With Trailing',
          trailing: Icon(Icons.chevron_right, key: Key('trailing_icon')),
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('trailing_icon')), findsOneWidget);
        expect(find.byKey(const Key('list_item_trailing')), findsOneWidget);
      });

      testWidgets('does not render trailing widget when not provided', (WidgetTester tester) async {
        final widget = const WnListItem(title: 'No Trailing');
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('list_item_trailing')), findsNothing);
      });
    });

    group('combined leading and trailing', () {
      testWidgets('renders both leading and trailing widgets', (WidgetTester tester) async {
        final widget = const WnListItem(
          title: 'Full Item',
          leading: Icon(Icons.person, key: Key('person_icon')),
          trailing: Icon(Icons.chevron_right, key: Key('chevron_icon')),
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('person_icon')), findsOneWidget);
        expect(find.byKey(const Key('chevron_icon')), findsOneWidget);
        expect(find.byKey(const Key('list_item_leading')), findsOneWidget);
        expect(find.byKey(const Key('list_item_trailing')), findsOneWidget);
      });
    });

    group('styling', () {
      testWidgets('has rounded container with background color', (WidgetTester tester) async {
        final widget = const WnListItem(title: 'Styled Item');
        await mountWidget(widget, tester);

        final containerFinder = find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration,
        );
        expect(containerFinder, findsOneWidget);
      });
    });
  });
}
