import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_avatar.dart';
import 'package:whitenoise/widgets/wn_chat_list_item.dart';
import 'package:whitenoise/widgets/wn_chat_status.dart';
import 'package:whitenoise/widgets/wn_icon.dart';

import '../test_helpers.dart';

void main() {
  group('WnChatListItem', () {
    testWidgets('renders basic info correctly', (tester) async {
      await mountWidget(
        const WnChatListItem(
          title: 'Alice',
          subtitle: 'Hello there',
          timestamp: '10:00 AM',
        ),
        tester,
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('10:00 AM'), findsOneWidget);
      expect(find.byType(WnAvatar), findsOneWidget);

      // Verify subtitle exists in one of the RichText widgets (since we used RichText for subtitle)
      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      final hasSubtitle = richTexts.any((widget) {
        final text = widget.text;
        return text is TextSpan && text.toPlainText().contains('Hello there');
      });
      expect(hasSubtitle, isTrue);
    });

    testWidgets('renders notification off icon when notificationOff is true', (tester) async {
      await mountWidget(
        const WnChatListItem(
          title: 'Group',
          subtitle: 'Msg',
          timestamp: 'Now',
          notificationOff: true,
        ),
        tester,
      );

      // We expect the icon to be present
      final iconFinder = find.byWidgetPredicate(
        (widget) => widget is WnIcon && widget.icon == WnIcons.notificationOff,
      );
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('renders unread badge when status is unreadCount', (tester) async {
      await mountWidget(
        const WnChatListItem(
          title: 'Bob',
          subtitle: 'Hey',
          timestamp: 'Yesterday',
          status: ChatStatusType.unreadCount,
          unreadCount: 3,
        ),
        tester,
      );

      expect(find.byType(WnChatStatus), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders status icon when status is provided', (tester) async {
      await mountWidget(
        const WnChatListItem(
          title: 'Charlie',
          subtitle: 'Sent',
          timestamp: '1m',
          status: ChatStatusType.sent,
        ),
        tester,
      );

      expect(find.byType(WnChatStatus), findsOneWidget);
      // WnChatStatus handles the icon internally
    });

    testWidgets('renders prefix subtitle', (tester) async {
      await mountWidget(
        const WnChatListItem(
          title: 'Me',
          subtitle: 'Hello',
          timestamp: 'Now',
          prefixSubtitle: 'You: ',
        ),
        tester,
      );

      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      final hasCombinedText = richTexts.any((widget) {
        final text = widget.text;
        if (text is TextSpan) {
          final plainText = text.toPlainText();
          return plainText.contains('You: ') && plainText.contains('Hello');
        }
        return false;
      });

      expect(hasCombinedText, isTrue);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await mountWidget(
        WnChatListItem(
          title: 'Tap me',
          subtitle: 'Tap',
          timestamp: 'Now',
          onTap: () => tapped = true,
        ),
        tester,
      );

      await tester.tap(find.byType(WnChatListItem));
      expect(tapped, isTrue);
    });

    testWidgets('renders selected state background', (tester) async {
      await mountWidget(
        const WnChatListItem(
          title: 'Selected',
          subtitle: 'Msg',
          timestamp: 'Now',
          isSelected: true,
        ),
        tester,
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(GestureDetector),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      // We need to access the theme context to get the color, or mock it.
      // mountWidget uses a real theme.
      // But verifying the exact color might be tricky without context.
      // We can check if color is not transparent/null.
      expect(decoration.color, isNotNull);
      expect(decoration.color, isNot(Colors.transparent));
    });
  });
}
