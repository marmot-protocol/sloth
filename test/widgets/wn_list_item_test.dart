import 'package:flutter/material.dart'
    show BoxDecoration, Column, Container, GlobalKey, Key, UniqueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_icon.dart';
import 'package:whitenoise/widgets/wn_list_item.dart';

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

    group('type icons', () {
      testWidgets('does not show icon for neutral type without leadingIcon', (
        WidgetTester tester,
      ) async {
        final widget = const WnListItem(title: 'No Icon');
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('list_item_type_icon')), findsNothing);
      });

      testWidgets('shows custom icon for neutral type with leadingIcon', (
        WidgetTester tester,
      ) async {
        final widget = const WnListItem(
          title: 'Neutral with custom icon',
          leadingIcon: WnIcons.placeholder,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('list_item_type_icon')), findsOneWidget);
      });

      testWidgets('shows success icon when type is success', (WidgetTester tester) async {
        final widget = const WnListItem(
          title: 'Success',
          type: WnListItemType.success,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('list_item_type_icon')), findsOneWidget);
      });

      testWidgets('shows warning icon when type is warning', (WidgetTester tester) async {
        final widget = const WnListItem(
          title: 'Warning',
          type: WnListItemType.warning,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('list_item_type_icon')), findsOneWidget);
      });

      testWidgets('shows error icon when type is error', (WidgetTester tester) async {
        final widget = const WnListItem(
          title: 'Error',
          type: WnListItemType.error,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('list_item_type_icon')), findsOneWidget);
      });
    });

    group('interactive states', () {
      testWidgets('renders default state without border', (WidgetTester tester) async {
        final widget = const WnListItem(title: 'Default Item');
        await mountWidget(widget, tester);

        final containerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).border == null,
        );
        expect(containerFinder, findsOneWidget);
      });

      testWidgets('item with actions is still tappable', (WidgetTester tester) async {
        var tapped = false;
        final widget = WnListItem(
          title: 'Tappable with Actions',
          actions: [WnListItemAction(label: 'Edit', onTap: () {})],
          onTap: () => tapped = true,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnListItem));
        expect(tapped, isTrue);
      });

      testWidgets('shows pressed state on tap down', (WidgetTester tester) async {
        final widget = const WnListItem(title: 'Pressable Item');
        await mountWidget(widget, tester);

        final gesture = await tester.startGesture(tester.getCenter(find.byType(WnListItem)));
        await tester.pump();

        expect(find.byType(WnListItem), findsOneWidget);

        await gesture.up();
        await tester.pump();
      });

      testWidgets('resets pressed state on tap cancel', (WidgetTester tester) async {
        final widget = const WnListItem(title: 'Cancellable Item');
        await mountWidget(widget, tester);

        final gesture = await tester.startGesture(tester.getCenter(find.byType(WnListItem)));
        await tester.pump();

        await gesture.cancel();
        await tester.pump();

        expect(find.byType(WnListItem), findsOneWidget);
      });
    });

    group('expanded state with actions', () {
      testWidgets('does not show menu button when no actions', (WidgetTester tester) async {
        final widget = const WnListItem(title: 'No Actions');
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('list_item_menu_button')), findsNothing);
      });

      testWidgets('shows menu button when actions provided', (WidgetTester tester) async {
        final widget = WnListItem(
          title: 'With Actions',
          actions: [
            WnListItemAction(label: 'Edit', onTap: () {}),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('list_item_menu_button')), findsOneWidget);
        expect(find.byKey(const Key('list_item_menu_icon')), findsOneWidget);
      });

      testWidgets('expands to show actions when menu tapped', (WidgetTester tester) async {
        final widget = WnListItem(
          title: 'With Actions',
          actions: [
            WnListItemAction(label: 'Edit', onTap: () {}),
            WnListItemAction(label: 'Delete', onTap: () {}, isDestructive: true),
          ],
        );
        await mountWidget(widget, tester);

        expect(find.byKey(const Key('list_item_expanded_actions')), findsNothing);

        await tester.tap(find.byKey(const Key('list_item_menu_button')));
        await tester.pump();

        expect(find.byKey(const Key('list_item_expanded_actions')), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('calls action onTap and collapses when action tapped', (
        WidgetTester tester,
      ) async {
        var actionCalled = false;
        final widget = WnListItem(
          title: 'With Actions',
          actions: [
            WnListItemAction(label: 'Edit', onTap: () => actionCalled = true),
          ],
        );
        await mountWidget(widget, tester);

        await tester.tap(find.byKey(const Key('list_item_menu_button')));
        await tester.pump();

        await tester.tap(find.text('Edit'));
        await tester.pump();

        expect(actionCalled, isTrue);
        expect(find.byKey(const Key('list_item_expanded_actions')), findsNothing);
      });

      testWidgets('hides more icon when expanded', (WidgetTester tester) async {
        final widget = WnListItem(
          title: 'With Actions',
          actions: [
            WnListItemAction(label: 'Edit', onTap: () {}),
          ],
        );
        await mountWidget(widget, tester);

        final iconFinder = find.byKey(const Key('list_item_menu_icon'));
        expect(iconFinder, findsOneWidget);

        await tester.tap(find.byKey(const Key('list_item_menu_button')));
        await tester.pump();

        expect(find.byKey(const Key('list_item_expanded_actions')), findsOneWidget);
        expect(iconFinder, findsNothing);
      });
    });

    group('WnListItemController', () {
      testWidgets('collapses item when controller.collapse() is called', (
        WidgetTester tester,
      ) async {
        final controller = WnListItemController();

        final widget = WnListItemScope(
          controller: controller,
          child: WnListItem(
            title: 'Controlled Item',
            itemKey: 'test-item',
            actions: [
              WnListItemAction(label: 'Edit', onTap: () {}),
            ],
          ),
        );
        await mountWidget(widget, tester);

        await tester.tap(find.byKey(const Key('list_item_menu_button')));
        await tester.pump();

        expect(find.byKey(const Key('list_item_expanded_actions')), findsOneWidget);

        controller.collapse();
        await tester.pump();

        expect(find.byKey(const Key('list_item_expanded_actions')), findsNothing);

        controller.dispose();
      });

      testWidgets('only one item can be expanded at a time with controller', (
        WidgetTester tester,
      ) async {
        final controller = WnListItemController();

        final widget = WnListItemScope(
          controller: controller,
          child: Column(
            children: [
              WnListItem(
                title: 'Item 1',
                itemKey: 'item-1',
                actions: [
                  WnListItemAction(label: 'Edit 1', onTap: () {}),
                ],
              ),
              WnListItem(
                title: 'Item 2',
                itemKey: 'item-2',
                actions: [
                  WnListItemAction(label: 'Edit 2', onTap: () {}),
                ],
              ),
            ],
          ),
        );
        await mountWidget(widget, tester);

        await tester.tap(find.byKey(const Key('list_item_menu_button')).first);
        await tester.pump();

        expect(find.text('Edit 1'), findsOneWidget);
        expect(find.text('Edit 2'), findsNothing);

        await tester.tap(find.byKey(const Key('list_item_menu_button')).last);
        await tester.pump();

        expect(find.text('Edit 1'), findsNothing);
        expect(find.text('Edit 2'), findsOneWidget);

        controller.dispose();
      });

      testWidgets('uses title as key when itemKey not provided', (WidgetTester tester) async {
        final controller = WnListItemController();

        final widget = WnListItemScope(
          controller: controller,
          child: WnListItem(
            title: 'Unique Title',
            actions: [
              WnListItemAction(label: 'Edit', onTap: () {}),
            ],
          ),
        );
        await mountWidget(widget, tester);

        await tester.tap(find.byKey(const Key('list_item_menu_button')));
        await tester.pump();

        expect(controller.expandedItemKey, 'Unique Title');
        expect(find.byKey(const Key('list_item_expanded_actions')), findsOneWidget);

        controller.dispose();
      });

      testWidgets('uses widget ValueKey value when itemKey not provided', (
        WidgetTester tester,
      ) async {
        final controller = WnListItemController();

        final widget = WnListItemScope(
          controller: controller,
          child: WnListItem(
            key: const Key('my-unique-key'),
            title: 'Same Title',
            actions: [
              WnListItemAction(label: 'Edit', onTap: () {}),
            ],
          ),
        );
        await mountWidget(widget, tester);

        await tester.tap(find.byKey(const Key('list_item_menu_button')));
        await tester.pump();

        expect(controller.expandedItemKey, 'my-unique-key');
        expect(find.byKey(const Key('list_item_expanded_actions')), findsOneWidget);

        controller.dispose();
      });

      testWidgets('uses widget GlobalKey.toString() when itemKey not provided', (
        WidgetTester tester,
      ) async {
        final controller = WnListItemController();
        final globalKey = GlobalKey(debugLabel: 'test-global-key');

        final widget = WnListItemScope(
          controller: controller,
          child: WnListItem(
            key: globalKey,
            title: 'Same Title',
            actions: [
              WnListItemAction(label: 'Edit', onTap: () {}),
            ],
          ),
        );
        await mountWidget(widget, tester);

        await tester.tap(find.byKey(const Key('list_item_menu_button')));
        await tester.pump();

        expect(controller.expandedItemKey, globalKey.toString());
        expect(find.byKey(const Key('list_item_expanded_actions')), findsOneWidget);

        controller.dispose();
      });

      testWidgets('throws assertion error when using UniqueKey without itemKey', (
        WidgetTester tester,
      ) async {
        final controller = WnListItemController();

        final widget = WnListItemScope(
          controller: controller,
          child: WnListItem(
            key: UniqueKey(),
            title: 'Unstable Item',
            actions: [
              WnListItemAction(label: 'Edit', onTap: () {}),
            ],
          ),
        );

        await mountWidget(widget, tester);

        final exception = tester.takeException();
        expect(exception, isNotNull);
        expect(exception.toString(), contains('UniqueKey'));

        controller.dispose();
      });

      testWidgets('allows UniqueKey when explicit itemKey is provided', (
        WidgetTester tester,
      ) async {
        final controller = WnListItemController();

        final widget = WnListItemScope(
          controller: controller,
          child: WnListItem(
            key: UniqueKey(),
            title: 'Stable Item',
            itemKey: 'stable-item-key',
            actions: [
              WnListItemAction(label: 'Edit', onTap: () {}),
            ],
          ),
        );
        await mountWidget(widget, tester);

        await tester.tap(find.byKey(const Key('list_item_menu_button')));
        await tester.pump();

        expect(controller.expandedItemKey, 'stable-item-key');
        expect(find.byKey(const Key('list_item_expanded_actions')), findsOneWidget);

        controller.dispose();
      });

      testWidgets('tapping on list item body collapses expanded menu', (WidgetTester tester) async {
        final controller = WnListItemController();

        final widget = WnListItemScope(
          controller: controller,
          child: Column(
            children: [
              WnListItem(
                title: 'Item 1',
                itemKey: 'item-1',
                actions: [
                  WnListItemAction(label: 'Edit 1', onTap: () {}),
                ],
              ),
              WnListItem(
                title: 'Item 2',
                itemKey: 'item-2',
                actions: [
                  WnListItemAction(label: 'Edit 2', onTap: () {}),
                ],
              ),
            ],
          ),
        );
        await mountWidget(widget, tester);

        await tester.tap(find.byKey(const Key('list_item_menu_button')).first);
        await tester.pump();

        expect(find.text('Edit 1'), findsOneWidget);

        await tester.tap(find.text('Item 2'));
        await tester.pump();

        expect(find.text('Edit 1'), findsNothing);
        expect(find.text('Edit 2'), findsNothing);

        controller.dispose();
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
