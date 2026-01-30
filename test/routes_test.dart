import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sloth/l10n/generated/app_localizations.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_invite_screen.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/chat_screen.dart';
import 'package:sloth/screens/developer_settings_screen.dart';
import 'package:sloth/screens/donate_screen.dart';
import 'package:sloth/screens/home_screen.dart';
import 'package:sloth/screens/login_screen.dart';
import 'package:sloth/screens/settings_screen.dart';
import 'package:sloth/screens/signup_screen.dart';
import 'package:sloth/screens/user_search_screen.dart';
import 'package:sloth/src/rust/api/chat_list.dart';
import 'package:sloth/src/rust/api/groups.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/api/users.dart' show User;
import 'package:sloth/src/rust/frb_generated.dart';
import 'test_helpers.dart';

class _MockRustLibApi implements RustLibApi {
  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async {
    return const FlutterMetadata(
      name: 'Test User',
      displayName: 'Test Display Name',
      about: 'Test bio',
      custom: {},
    );
  }

  @override
  Stream<MessageStreamItem> crateApiMessagesSubscribeToGroupMessages({
    required String groupId,
  }) async* {
    yield const MessageStreamItem.initialSnapshot(messages: []);
  }

  @override
  Future<Group> crateApiGroupsGetGroup({
    required String accountPubkey,
    required String groupId,
  }) async {
    return Group(
      mlsGroupId: groupId,
      nostrGroupId: '',
      name: 'Test Group',
      description: '',
      adminPubkeys: const [],
      epoch: BigInt.zero,
      state: GroupState.active,
    );
  }

  @override
  Future<bool> crateApiGroupsGroupIsDirectMessageType({
    required Group that,
    required String accountPubkey,
  }) async {
    return false;
  }

  @override
  Future<String?> crateApiGroupsGetGroupImagePath({
    required String accountPubkey,
    required String groupId,
  }) async {
    return null;
  }

  @override
  Future<List<ChatMessage>> crateApiMessagesFetchAggregatedMessagesForGroup({
    required String pubkey,
    required String groupId,
  }) async {
    return [];
  }

  @override
  Stream<ChatListStreamItem> crateApiChatListSubscribeToChatList({
    required String accountPubkey,
  }) {
    return Stream.value(const ChatListStreamItem.initialSnapshot(items: []));
  }

  @override
  String crateApiUtilsNpubFromHexPubkey({required String hexPubkey}) {
    return 'npub1test${hexPubkey.substring(0, 10)}';
  }

  @override
  Future<List<User>> crateApiAccountsAccountFollows({required String pubkey}) async {
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final methodName = invocation.memberName.toString();
    throw UnimplementedError('_MockRustLibApi.$methodName is not implemented');
  }
}

class _AuthenticatedAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async => testPubkeyA;
}

void main() {
  setUpAll(() {
    RustLib.initMock(api: _MockRustLibApi());
  });
  late GoRouter router;

  Future<void> pumpRouter(
    WidgetTester tester, {
    List overrides = const [],
  }) async {
    setUpTestView(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [...overrides],
        child: ScreenUtilInit(
          designSize: testDesignSize,
          builder: (_, _) => Consumer(
            builder: (context, ref, _) {
              router = Routes.build(ref);
              return MaterialApp.router(
                routerConfig: router,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
          ),
        ),
      ),
    );
  }

  BuildContext getContext(WidgetTester tester) => tester.element(find.byType(Scaffold));

  group('build', () {
    group('when user is authenticated', () {
      testWidgets('navigates to ChatListScreen', (tester) async {
        await pumpRouter(
          tester,
          overrides: [
            authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
          ],
        );
        Routes.pushToLogin(getContext(tester));
        await tester.pumpAndSettle();
        Routes.pushToHome(getContext(tester));
        await tester.pumpAndSettle();
        expect(find.byType(ChatListScreen), findsOneWidget);
      });
    });

    group('when user is not authenticated', () {
      testWidgets('navigates to HomeScreen', (tester) async {
        await pumpRouter(tester);
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('redirects to LoginScreen when accessing /chats', (tester) async {
        await pumpRouter(tester);
        Routes.goToChatList(getContext(tester));
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);
      });

      testWidgets('redirects to LoginScreen when accessing /settings', (tester) async {
        await pumpRouter(tester);
        Routes.pushToSettings(getContext(tester));
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);
      });

      testWidgets('redirects to LoginScreen when accessing /donate', (tester) async {
        await pumpRouter(tester);
        Routes.pushToDonate(getContext(tester));
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);
      });

      testWidgets('redirects to LoginScreen when accessing /user-search', (tester) async {
        await pumpRouter(tester);
        Routes.pushToUserSearch(getContext(tester));
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);
      });
    });
  });

  group('goBack', () {
    testWidgets('navigates to previous route', (tester) async {
      await pumpRouter(tester);
      Routes.pushToLogin(getContext(tester));
      await tester.pumpAndSettle();
      Routes.pushToSignup(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goBack(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    group('when navigation stack is empty', () {
      testWidgets('navigates to HomeScreen', (tester) async {
        await pumpRouter(tester);
        Routes.goToChatList(getContext(tester));
        await tester.pumpAndSettle();
        Routes.goBack(getContext(tester));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });
  });

  group('goToHome', () {
    testWidgets('navigates to HomeScreen', (tester) async {
      await pumpRouter(tester);
      Routes.goToLogin(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goToHome(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('resets navigation stack', (tester) async {
      await pumpRouter(tester);
      Routes.pushToLogin(getContext(tester));
      await tester.pumpAndSettle();
      Routes.pushToSignup(getContext(tester));
      await tester.pumpAndSettle();
      Routes.pushToChatList(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goToHome(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goBack(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('pushToHome', () {
    testWidgets('navigates to HomeScreen', (tester) async {
      await pumpRouter(tester);
      Routes.pushToLogin(getContext(tester));
      await tester.pumpAndSettle();
      Routes.pushToHome(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('does not reset navigation stack', (tester) async {
      await pumpRouter(tester);
      Routes.pushToLogin(getContext(tester));
      await tester.pumpAndSettle();
      Routes.pushToSignup(getContext(tester));
      await tester.pumpAndSettle();
      Routes.pushToHome(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goBack(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(SignupScreen), findsOneWidget);
    });
  });

  group('goToLogin', () {
    testWidgets('navigates to LoginScreen', (tester) async {
      await pumpRouter(tester);
      Routes.goToLogin(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('resets navigation stack', (tester) async {
      await pumpRouter(tester);
      Routes.pushToSignup(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goToLogin(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goBack(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('pushToLogin', () {
    testWidgets('pushes LoginScreen onto stack', (tester) async {
      await pumpRouter(tester);
      Routes.pushToLogin(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('does not reset navigation stack', (tester) async {
      await pumpRouter(tester);
      Routes.pushToSignup(getContext(tester));
      await tester.pumpAndSettle();
      Routes.pushToLogin(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goBack(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(SignupScreen), findsOneWidget);
    });
  });

  group('goToSignup', () {
    testWidgets('navigates to SignupScreen', (tester) async {
      await pumpRouter(tester);
      Routes.goToSignup(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(SignupScreen), findsOneWidget);
    });

    testWidgets('resets navigation stack', (tester) async {
      await pumpRouter(tester);
      Routes.goToLogin(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goToSignup(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goBack(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('pushToSignup', () {
    testWidgets('pushes SignupScreen onto stack', (tester) async {
      await pumpRouter(tester);
      Routes.pushToSignup(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(SignupScreen), findsOneWidget);
    });

    testWidgets('does not reset navigation stack', (tester) async {
      await pumpRouter(tester);
      Routes.pushToLogin(getContext(tester));
      await tester.pumpAndSettle();
      Routes.pushToSignup(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goBack(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('goToChatList', () {
    testWidgets('navigates to ChatListScreen', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.goToChatList(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });
  });

  group('pushToChatList', () {
    testWidgets('pushes ChatListScreen onto stack', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.pushToChatList(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });
  });

  group('pushToSettings', () {
    testWidgets('pushes SettingsScreen onto stack', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.pushToSettings(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('does not reset navigation stack', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.pushToSettings(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goBack(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });
  });

  group('pushToDonate', () {
    testWidgets('pushes DonateScreen onto stack', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.pushToDonate(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(DonateScreen), findsOneWidget);
    });

    testWidgets('does not reset navigation stack', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.pushToDonate(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goBack(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });
  });

  group('pushToDeveloperSettings', () {
    testWidgets('navigates to Developer Settings', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.pushToDeveloperSettings(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(DeveloperSettingsScreen), findsOneWidget);
    });

    testWidgets('does not reset navigation stack', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.pushToDeveloperSettings(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goBack(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });
  });

  group('pushToUserSearch', () {
    testWidgets('pushes UserSearchScreen onto stack', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.pushToUserSearch(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(UserSearchScreen), findsOneWidget);
    });

    testWidgets('does not reset navigation stack', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.pushToUserSearch(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goBack(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });
  });

  group('pushToInvite', () {
    testWidgets('pushes ChatInviteScreen onto stack', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.pushToInvite(getContext(tester), testGroupId);
      await tester.pumpAndSettle();
      expect(find.byType(ChatInviteScreen), findsOneWidget);
    });

    testWidgets('does not reset navigation stack', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.pushToInvite(getContext(tester), testGroupId);
      await tester.pumpAndSettle();
      Routes.goBack(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });
  });

  group('goToChat', () {
    testWidgets('navigates to ChatScreen', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.goToChat(getContext(tester), testGroupId);
      await tester.pumpAndSettle();
      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('resets navigation stack', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.pushToSettings(getContext(tester));
      await tester.pumpAndSettle();
      Routes.goToChat(getContext(tester), testGroupId);
      await tester.pumpAndSettle();
      Routes.goBack(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });
  });
}
