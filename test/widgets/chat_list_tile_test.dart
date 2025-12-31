import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sloth/src/rust/api/groups.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/widgets/chat_list_tile.dart';
import 'package:sloth/widgets/wn_animated_avatar.dart';

import '../test_helpers.dart';

ChatSummary _chatSummary({
  String? name,
  GroupType groupType = GroupType.group,
  bool pendingConfirmation = false,
  String? lastMessageContent,
  String? groupImagePath,
  String? groupImageUrl,
}) => ChatSummary(
  mlsGroupId: 'test-group-id',
  name: name,
  groupType: groupType,
  createdAt: DateTime(2024),
  pendingConfirmation: pendingConfirmation,
  groupImagePath: groupImagePath,
  groupImageUrl: groupImageUrl,
  lastMessage: lastMessageContent != null
      ? ChatMessageSummary(
          mlsGroupId: 'test-group-id',
          author: 'author',
          content: lastMessageContent,
          createdAt: DateTime(2024),
          mediaAttachmentCount: BigInt.zero,
        )
      : null,
);

void main() {
  Future<void> pumpTile(WidgetTester tester, ChatSummary chatSummary) async {
    await mountWidget(ChatListTile(chatSummary: chatSummary), tester);
  }

  group('ChatListTile', () {
    group('title', () {
      testWidgets('displays name when present', (tester) async {
        await pumpTile(tester, _chatSummary(name: 'My Group'));

        expect(find.text('My Group'), findsOneWidget);
      });

      testWidgets('displays "Unknown user" for DM without name', (tester) async {
        await pumpTile(tester, _chatSummary(groupType: GroupType.directMessage));

        expect(find.text('Unknown user'), findsOneWidget);
      });

      testWidgets('displays "Unknown group" for group without name', (tester) async {
        await pumpTile(tester, _chatSummary());

        expect(find.text('Unknown group'), findsOneWidget);
      });

      testWidgets('displays "Unknown user" for DM with empty name', (tester) async {
        await pumpTile(tester, _chatSummary(name: '', groupType: GroupType.directMessage));

        expect(find.text('Unknown user'), findsOneWidget);
      });
    });

    group('subtitle', () {
      testWidgets('displays invite message when pending confirmation', (tester) async {
        await pumpTile(tester, _chatSummary(pendingConfirmation: true));

        expect(find.text('You have been invited to a secure chat'), findsOneWidget);
      });

      testWidgets('displays last message content when available', (tester) async {
        await pumpTile(tester, _chatSummary(lastMessageContent: 'Hello world'));

        expect(find.text('Hello world'), findsOneWidget);
      });

      testWidgets('displays empty string when no last message', (tester) async {
        await pumpTile(tester, _chatSummary());

        expect(find.text(''), findsOneWidget);
      });
    });

    group('avatar', () {
      testWidgets('receives expected name', (tester) async {
        await pumpTile(tester, _chatSummary(name: 'My Group'));

        final avatar = tester.widget<WnAnimatedAvatar>(find.byType(WnAnimatedAvatar));
        expect(avatar.displayName, 'My Group');
      });

      testWidgets('uses groupImagePath for groups', (tester) async {
        await pumpTile(tester, _chatSummary(groupImagePath: '/path/to/image'));

        final avatar = tester.widget<WnAnimatedAvatar>(find.byType(WnAnimatedAvatar));
        expect(avatar.pictureUrl, '/path/to/image');
      });

      testWidgets('uses groupImageUrl for DMs', (tester) async {
        await pumpTile(
          tester,
          _chatSummary(
            groupType: GroupType.directMessage,
            groupImageUrl: 'https://example.com/avatar.png',
          ),
        );

        final avatar = tester.widget<WnAnimatedAvatar>(find.byType(WnAnimatedAvatar));
        expect(avatar.pictureUrl, 'https://example.com/avatar.png');
      });
    });

    group('navigation', () {
      GoRouter buildRouter(initialLocation) {
        return GoRouter(
          initialLocation: initialLocation,
          routes: [
            GoRoute(
              path: '/pending',
              builder: (_, _) => Scaffold(
                body: ChatListTile(chatSummary: _chatSummary(pendingConfirmation: true)),
              ),
            ),
            GoRoute(
              path: '/not-pending',
              builder: (_, _) => Scaffold(
                body: ChatListTile(chatSummary: _chatSummary()),
              ),
            ),
            GoRoute(
              name: 'invite',
              path: '/invites/:mlsGroupId',
              builder: (_, _) => const Text('Invite Screen'),
            ),
            GoRoute(
              name: 'chat',
              path: '/chats/:groupId',
              builder: (_, _) => const Text('Chat Screen'),
            ),
          ],
        );
      }

      group('when pending', () {
        testWidgets('navigates to invite when pending', (tester) async {
          await tester.pumpWidget(
            ScreenUtilInit(
              designSize: testDesignSize,
              builder: (_, _) => MaterialApp.router(routerConfig: buildRouter('/pending')),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byType(ChatListTile));
          await tester.pumpAndSettle();

          expect(find.text('Invite Screen'), findsOneWidget);
        });
      });

      group('when not pending', () {
        testWidgets('navigates to chat when not pending', (tester) async {
          await tester.pumpWidget(
            ScreenUtilInit(
              designSize: testDesignSize,
              builder: (_, _) => MaterialApp.router(routerConfig: buildRouter('/not-pending')),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byType(ChatListTile));
          await tester.pumpAndSettle();

          expect(find.text('Chat Screen'), findsOneWidget);
        });
      });
    });
  });
}
