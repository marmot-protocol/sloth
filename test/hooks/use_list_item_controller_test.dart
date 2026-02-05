import 'package:flutter/material.dart' show Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_list_item.dart';

import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnListItemController', () {
    test('can expand and collapse items', () {
      final controller = WnListItemController();

      expect(controller.expandedItemKey, isNull);

      controller.expand('test-key');
      expect(controller.expandedItemKey, 'test-key');
      expect(controller.isExpanded('test-key'), isTrue);
      expect(controller.isExpanded('other-key'), isFalse);

      controller.collapse();
      expect(controller.expandedItemKey, isNull);
      expect(controller.isExpanded('test-key'), isFalse);

      controller.dispose();
    });

    test('expanding a new key collapses the previous one', () {
      final controller = WnListItemController();

      controller.expand('key-1');
      expect(controller.isExpanded('key-1'), isTrue);

      controller.expand('key-2');
      expect(controller.isExpanded('key-1'), isFalse);
      expect(controller.isExpanded('key-2'), isTrue);

      controller.dispose();
    });

    test('collapse does nothing if nothing is expanded', () {
      final controller = WnListItemController();

      expect(controller.expandedItemKey, isNull);
      controller.collapse();
      expect(controller.expandedItemKey, isNull);

      controller.dispose();
    });

    test('expand does not notify if already expanded', () {
      final controller = WnListItemController();
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.expand('key-1');
      expect(notifyCount, 1);

      controller.expand('key-1');
      expect(notifyCount, 1);

      controller.dispose();
    });

    testWidgets('works with WnListItemScope', (WidgetTester tester) async {
      final controller = WnListItemController();

      final widget = WnListItemScope(
        controller: controller,
        child: WnListItem(
          title: 'Test Item',
          itemKey: 'test-item',
          actions: [
            WnListItemAction(label: 'Edit', onTap: () {}),
          ],
        ),
      );
      await mountWidget(widget, tester);

      await tester.tap(find.byKey(const Key('list_item_menu_button')));
      await tester.pump();

      expect(controller.isExpanded('test-item'), isTrue);
      expect(find.byKey(const Key('list_item_expanded_actions')), findsOneWidget);

      controller.dispose();
    });
  });
}
