import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sloth/l10n/generated/app_localizations.dart';
import 'package:sloth/src/rust/api/chat_list.dart';
import 'package:sloth/src/rust/api/groups.dart' show GroupType;
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/utils/avatar_color.dart';
import 'package:sloth/widgets/chat_list_tile.dart';
import 'package:sloth/widgets/wn_avatar.dart';

import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

ChatSummary _chatSummary({
  String? name,
  GroupType groupType = GroupType.group,
  bool pendingConfirmation = false,
  String? lastMessageContent,
  String? groupImagePath,
  String? groupImageUrl,
  String? welcomerPubkey,
}) => ChatSummary(
  mlsGroupId: 'a1b2c3d4',
  name: name,
  groupType: groupType,
  createdAt: DateTime(2024),
  pendingConfirmation: pendingConfirmation,
  unreadCount: BigInt.zero,
  groupImagePath: groupImagePath,
  groupImageUrl: groupImageUrl,
  welcomerPubkey: welcomerPubkey,
  lastMessage: lastMessageContent != null
      ? ChatMessageSummary(
          mlsGroupId: 'a1b2c3d4',
          author: 'author',
          content: lastMessageContent,
          createdAt: DateTime(2024),
          mediaAttachmentCount: BigInt.zero,
        )
      : null,
);

class _MockApi extends MockWnApi {
  FlutterMetadata welcomerMetadata = const FlutterMetadata(custom: {});
  bool shouldThrow = false;

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async {
    if (shouldThrow) throw Exception('Network error');
    return welcomerMetadata;
  }
}

final _api = _MockApi();

void main() {
  setUpAll(() => RustLib.initMock(api: _api));
  setUp(() {
    _api.welcomerMetadata = const FlutterMetadata(custom: {});
    _api.shouldThrow = false;
  });

  Future<void> pumpTile(
    WidgetTester tester,
    ChatSummary chatSummary, {
    bool settle = true,
  }) async {
    await mountWidget(ChatListTile(chatSummary: chatSummary), tester);
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  group('ChatListTile', () {
    group('title', () {
      testWidgets('shows name when present', (tester) async {
        await pumpTile(tester, _chatSummary(name: 'My Group'));

        expect(find.text('My Group'), findsOneWidget);
      });

      testWidgets('shows name for DM with name', (tester) async {
        await pumpTile(
          tester,
          _chatSummary(name: 'Alice', groupType: GroupType.directMessage),
        );

        expect(find.text('Alice'), findsOneWidget);
      });

      testWidgets('shows "Unknown user" for DM without name', (tester) async {
        await pumpTile(
          tester,
          _chatSummary(groupType: GroupType.directMessage),
        );

        expect(find.text('Unknown user'), findsOneWidget);
      });

      testWidgets('shows "Unknown group" for group without name', (tester) async {
        await pumpTile(tester, _chatSummary());

        expect(find.text('Unknown group'), findsOneWidget);
      });

      testWidgets('shows "Unknown user" for DM with empty name', (tester) async {
        await pumpTile(
          tester,
          _chatSummary(name: '', groupType: GroupType.directMessage),
        );

        expect(find.text('Unknown user'), findsOneWidget);
      });
    });

    group('subtitle', () {
      group('when pending', () {
        group('DM', () {
          testWidgets('shows invite message', (tester) async {
            await pumpTile(
              tester,
              _chatSummary(
                groupType: GroupType.directMessage,
                pendingConfirmation: true,
              ),
            );

            expect(
              find.text('Has invited you to a secure chat'),
              findsOneWidget,
            );
          });
        });

        group('group', () {
          testWidgets('shows welcomer name in invite when available', (tester) async {
            _api.welcomerMetadata = const FlutterMetadata(
              displayName: 'Charlie',
              custom: {},
            );
            await pumpTile(
              tester,
              _chatSummary(
                pendingConfirmation: true,
                welcomerPubkey: 'welcomer-pubkey',
              ),
            );

            expect(
              find.text('Charlie has invited you to a secure chat'),
              findsOneWidget,
            );
          });

          testWidgets('shows generic invite without welcomer metadata', (tester) async {
            await pumpTile(
              tester,
              _chatSummary(pendingConfirmation: true),
            );

            expect(
              find.text('You have been invited to a secure chat'),
              findsOneWidget,
            );
          });

          testWidgets('shows generic invite when metadata fetch fails', (tester) async {
            _api.shouldThrow = true;
            await pumpTile(
              tester,
              _chatSummary(
                pendingConfirmation: true,
                welcomerPubkey: 'welcomer-pubkey',
              ),
            );

            expect(
              find.text('You have been invited to a secure chat'),
              findsOneWidget,
            );
          });

          testWidgets('shows generic invite when metadata has only picture', (tester) async {
            _api.welcomerMetadata = const FlutterMetadata(
              picture: 'https://example.com/avatar.png',
              custom: {},
            );
            await pumpTile(
              tester,
              _chatSummary(
                pendingConfirmation: true,
                welcomerPubkey: 'welcomer-pubkey',
              ),
            );

            expect(
              find.text('You have been invited to a secure chat'),
              findsOneWidget,
            );
          });
        });
      });

      testWidgets('shows last message content when available', (tester) async {
        await pumpTile(
          tester,
          _chatSummary(lastMessageContent: 'Hello world'),
        );

        expect(find.text('Hello world'), findsOneWidget);
      });

      testWidgets('shows empty string when no last message', (tester) async {
        await pumpTile(tester, _chatSummary());

        expect(find.text(''), findsOneWidget);
      });
    });

    group('avatar', () {
      testWidgets('receives expected name', (tester) async {
        await pumpTile(tester, _chatSummary(name: 'My Group'));

        final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
        expect(avatar.displayName, 'My Group');
      });

      testWidgets('uses groupImagePath for groups', (tester) async {
        await pumpTile(
          tester,
          _chatSummary(groupImagePath: '/path/to/image'),
          settle: false,
        );

        final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
        expect(avatar.pictureUrl, '/path/to/image');
      });

      testWidgets('uses groupImageUrl for DMs', (tester) async {
        await pumpTile(
          tester,
          _chatSummary(
            groupType: GroupType.directMessage,
            groupImageUrl: 'https://example.com/avatar.png',
          ),
          settle: false,
        );

        final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
        expect(avatar.pictureUrl, 'https://example.com/avatar.png');
      });

      testWidgets('receives color derived from mlsGroupId', (tester) async {
        await pumpTile(tester, _chatSummary(name: 'Test'));

        final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
        expect(avatar.color, avatarColorFromPubkey('a1b2c3d4'));
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
            ProviderScope(
              child: ScreenUtilInit(
                designSize: testDesignSize,
                builder: (_, _) => MaterialApp.router(
                  routerConfig: buildRouter('/pending'),
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,
                ),
              ),
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
            ProviderScope(
              child: ScreenUtilInit(
                designSize: testDesignSize,
                builder: (_, _) => MaterialApp.router(
                  routerConfig: buildRouter('/not-pending'),
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,
                ),
              ),
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
