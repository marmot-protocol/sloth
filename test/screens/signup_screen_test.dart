import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/home_screen.dart';
import 'package:sloth/screens/onboarding_screen.dart';
import 'package:sloth/src/rust/api/accounts.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';

class _MockRustLibApi implements RustLibApi {
  @override
  Future<Account> crateApiAccountsCreateIdentity() async {
    return Account(pubkey: 'test_pubkey', createdAt: DateTime.now(), updatedAt: DateTime.now());
  }

  @override
  Future<String> crateApiUtilsGetDefaultBlossomServerUrl() async => 'https://blossom.example.com';

  @override
  Future<void> crateApiAccountsUpdateAccountMetadata({
    required String pubkey,
    required FlutterMetadata metadata,
  }) async {}

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async {
    return const FlutterMetadata(displayName: 'Test User', custom: {});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _MockAuthNotifier extends AuthNotifier {
  Exception? errorToThrow;

  @override
  Future<String?> build() async => null;

  @override
  Future<String> signup() async {
    if (errorToThrow != null) throw errorToThrow!;
    state = const AsyncData('test_pubkey');
    return 'test_pubkey';
  }
}

void main() {
  setUpAll(() => RustLib.initMock(api: _MockRustLibApi()));

  Future<void> pumpSignupScreen(WidgetTester tester, {List overrides = const []}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [...overrides],
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
    Routes.pushToSignup(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('SignupScreen', () {
    testWidgets('displays Setup profile title', (tester) async {
      await pumpSignupScreen(tester);
      expect(find.text('Setup profile'), findsOneWidget);
    });

    testWidgets('displays name input field', (tester) async {
      await pumpSignupScreen(tester);
      expect(find.text('Choose a name'), findsOneWidget);
    });

    testWidgets('displays bio input field', (tester) async {
      await pumpSignupScreen(tester);
      expect(find.text('Introduce yourself'), findsOneWidget);
    });

    testWidgets('displays Cancel button', (tester) async {
      await pumpSignupScreen(tester);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays Sign Up button', (tester) async {
      await pumpSignupScreen(tester);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    group('navigation', () {
      testWidgets('tapping back button returns to home screen', (tester) async {
        await pumpSignupScreen(tester);
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('tapping Cancel returns to home screen', (tester) async {
        await pumpSignupScreen(tester);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('tapping outside slate returns to home screen', (tester) async {
        await pumpSignupScreen(tester);
        await tester.tapAt(const Offset(195, 50));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('submit', () {
      late _MockAuthNotifier mockAuth;
      late List overrides;

      setUp(() {
        mockAuth = _MockAuthNotifier();
        overrides = [
          authProvider.overrideWith(() => mockAuth),
          secureStorageProvider.overrideWithValue(MockSecureStorage()),
        ];
      });

      testWidgets('redirects to onboarding on success', (tester) async {
        await pumpSignupScreen(tester, overrides: overrides);
        await tester.enterText(find.byType(TextField).first, 'Test User');
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();
        expect(find.byType(OnboardingScreen), findsOneWidget);
      });

      testWidgets('does not redirect on failure', (tester) async {
        mockAuth.errorToThrow = Exception('Network error');
        await pumpSignupScreen(tester, overrides: overrides);
        await tester.enterText(find.byType(TextField).first, 'Test User');
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();
        expect(find.byType(OnboardingScreen), findsNothing);
      });
    });
  });
}
