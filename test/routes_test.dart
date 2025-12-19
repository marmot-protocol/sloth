import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/developer_settings_screen.dart';
import 'package:sloth/screens/donate_screen.dart';
import 'package:sloth/screens/home_screen.dart';
import 'package:sloth/screens/login_screen.dart';
import 'package:sloth/screens/settings_screen.dart';
import 'package:sloth/screens/signup_screen.dart';
import 'package:sloth/screens/welcome_screen.dart' show WelcomeScreen;
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/api/welcomes.dart' show Welcome, WelcomeState;
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
  Future<Welcome> crateApiWelcomesFindWelcomeByEventId({
    required String pubkey,
    required String welcomeEventId,
  }) async {
    return Welcome(
      id: welcomeEventId,
      mlsGroupId: '',
      nostrGroupId: '',
      groupName: '',
      groupDescription: '',
      groupAdminPubkeys: const [],
      groupRelays: const [],
      welcomer: '',
      memberCount: 0,
      state: WelcomeState.pending,
      createdAt: BigInt.zero,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final methodName = invocation.memberName.toString();
    throw UnimplementedError('_MockRustLibApi.$methodName is not implemented');
  }
}

class _AuthenticatedAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async => 'test_pubkey';
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
              return MaterialApp.router(routerConfig: router);
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
      Routes.goToHome(getContext(tester));
      await tester.pumpAndSettle();
      expect(() => Routes.goBack(getContext(tester)), throwsA(isA<GoError>()));
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
      expect(() => Routes.goBack(getContext(tester)), throwsA(isA<GoError>()));
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
      expect(() => Routes.goBack(getContext(tester)), throwsA(isA<GoError>()));
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

  group('pushToWelcome', () {
    testWidgets('pushes WelcomeScreen onto stack', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.pushToWelcome(getContext(tester), 'test-id');
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('does not reset navigation stack', (tester) async {
      await pumpRouter(
        tester,
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
      );
      Routes.pushToWelcome(getContext(tester), 'test-id');
      await tester.pumpAndSettle();
      Routes.goBack(getContext(tester));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });
  });
}
