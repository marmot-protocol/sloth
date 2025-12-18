import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/home_screen.dart';
import 'package:sloth/screens/onboarding_screen.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

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
  dynamic noSuchMethod(Invocation invocation) {
    final methodName = invocation.memberName.toString();
    throw UnimplementedError('_MockRustLibApi.$methodName is not implemented');
  }
}

class _MockAuthNotifier extends AuthNotifier {
  bool loginCalled = false;
  String? lastNsec;
  Exception? errorToThrow;

  @override
  Future<String?> build() async => null;

  @override
  Future<void> login(String nsec) async {
    loginCalled = true;
    lastNsec = nsec;
    if (errorToThrow != null) throw errorToThrow!;
    state = const AsyncData('test_pubkey');
  }
}

void main() {
  setUpAll(() {
    RustLib.initMock(api: _MockRustLibApi());
  });

  late _MockAuthNotifier mockAuth;

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    mockAuth = _MockAuthNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith(() => mockAuth)],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, _) => Consumer(
            builder: (context, ref, _) {
              return MaterialApp.router(routerConfig: Routes.build(ref));
            },
          ),
        ),
      ),
    );

    Routes.pushToLogin(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('LoginScreen', () {
    group('navigation', () {
      testWidgets('tapping back button returns to home screen', (tester) async {
        await pumpLoginScreen(tester);
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('tapping outside slate returns to home screen', (tester) async {
        await pumpLoginScreen(tester);
        await tester.tap(find.byKey(const Key('login_background')));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('login', () {
      testWidgets('calls login method with entered nsec', (tester) async {
        await pumpLoginScreen(tester);
        await tester.enterText(find.byType(TextField), 'nsec1test');
        await tester.tap(find.text('Login'));
        await tester.pump();
        expect(mockAuth.lastNsec, 'nsec1test');
        expect(mockAuth.loginCalled, isTrue);
      });

      group('when login is successful', () {
        testWidgets('redirects to onboarding screen on success', (tester) async {
          await pumpLoginScreen(tester);
          await tester.enterText(find.byType(TextField), 'nsec1test');
          await tester.tap(find.text('Login'));
          await tester.pumpAndSettle();
          expect(find.byType(OnboardingScreen), findsOneWidget);
        });
      });

      group('when login fails', () {
        testWidgets('does not redirect to onboarding screen', (tester) async {
          await pumpLoginScreen(tester);
          mockAuth.errorToThrow = Exception('Invalid key');
          await tester.enterText(find.byType(TextField), 'nsec1test');
          await tester.tap(find.text('Login'));
          await tester.pumpAndSettle();
          expect(find.byType(OnboardingScreen), findsNothing);
        });

        testWidgets('shows error message on failure', (tester) async {
          await pumpLoginScreen(tester);
          mockAuth.errorToThrow = Exception('Invalid key');
          await tester.enterText(find.byType(TextField), 'nsec1test');
          await tester.tap(find.text('Login'));
          await tester.pumpAndSettle();
          expect(
            find.textContaining('Oh no! An error occurred, please try again.'),
            findsOneWidget,
          );
        });
      });
    });
  });
}
