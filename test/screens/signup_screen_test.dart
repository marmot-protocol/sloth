import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData, ProviderScope;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/providers/is_adding_account_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
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
    return Account(
      pubkey: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
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
    state = const AsyncData('a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4');
    return 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4';
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

      testWidgets('redirects to chat list when adding account', (tester) async {
        await mountTestApp(tester, overrides: overrides);

        final element = tester.element(find.byType(Scaffold));
        final container = ProviderScope.containerOf(element);
        container.read(isAddingAccountProvider.notifier).set(true);

        Routes.pushToSignup(element);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'Test User');
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        expect(find.byType(ChatListScreen), findsOneWidget);
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

    group('image picker', () {
      testWidgets('shows error snackbar when image picker fails', (tester) async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/image_picker'),
          (MethodCall methodCall) async {
            throw PlatformException(code: 'error', message: 'Test error');
          },
        );
        addTearDown(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                const MethodChannel('plugins.flutter.io/image_picker'),
                null,
              );
        });

        await pumpSignupScreen(tester);
        await tester.tap(find.byKey(const Key('avatar_edit_button')));
        await tester.pumpAndSettle();

        expect(find.text('Failed to pick image. Please try again.'), findsOneWidget);
      });
    });
  });
}
