import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/home_screen.dart';
import 'package:sloth/screens/onboarding_screen.dart';
import 'package:sloth/src/rust/api/accounts.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockApi extends MockWnApi {
  @override
  Future<Account> crateApiAccountsCreateIdentity() async {
    return Account(pubkey: 'test_pubkey', createdAt: DateTime.now(), updatedAt: DateTime.now());
  }

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async {
    return const FlutterMetadata(displayName: 'Test User', custom: {});
  }
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
  setUpAll(() => RustLib.initMock(api: _MockApi()));

  Future<void> pumpSignupScreen(WidgetTester tester, {List overrides = const []}) async {
    await mountTestApp(tester, overrides: overrides);
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
        await tester.tap(find.byKey(const Key('back_button')));
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

    group('keyboard', () {
      testWidgets('scrolls to bottom when keyboard appears', (tester) async {
        tester.view.physicalSize = const Size(390, 500);
        addTearDown(tester.view.reset);

        await pumpSignupScreen(tester);

        final scrollable = find.byType(Scrollable).first;
        final scrollPosition = tester.state<ScrollableState>(scrollable).position;

        expect(scrollPosition.pixels, 0);

        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();

        expect(scrollPosition.pixels, scrollPosition.maxScrollExtent);
      });
    });
  });
}
