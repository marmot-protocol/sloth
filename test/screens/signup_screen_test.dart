import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData, Consumer, ProviderScope;
import 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtilInit;
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/l10n/generated/app_localizations.dart';
import 'package:whitenoise/providers/auth_provider.dart';
import 'package:whitenoise/providers/is_adding_account_provider.dart';
import 'package:whitenoise/routes.dart';
import 'package:whitenoise/screens/chat_list_screen.dart';
import 'package:whitenoise/screens/home_screen.dart';
import 'package:whitenoise/screens/onboarding_screen.dart';
import 'package:whitenoise/src/rust/api/accounts.dart';
import 'package:whitenoise/src/rust/api/metadata.dart';
import 'package:whitenoise/src/rust/frb_generated.dart';
import 'package:whitenoise/widgets/wn_system_notice.dart';

import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockApi extends MockWnApi {
  @override
  Future<Account> crateApiAccountsCreateIdentity() async {
    return Account(
      pubkey: testPubkeyA,
      accountType: AccountType.local,
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
    state = const AsyncData(testPubkeyA);
    return testPubkeyA;
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
        await tester.tap(find.byKey(const Key('slate_back_button')));
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
      testWidgets(
        'scrolls to bottom when keyboard appears',
        (tester) async {
          tester.view.physicalSize = const Size(390, 550);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            ProviderScope(
              child: ScreenUtilInit(
                designSize: testDesignSize,
                builder: (_, _) => Consumer(
                  builder: (context, ref, _) {
                    return MaterialApp.router(
                      routerConfig: Routes.build(ref),
                      locale: const Locale('en'),
                      localizationsDelegates: AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                    );
                  },
                ),
              ),
            ),
          );

          Routes.pushToSignup(tester.element(find.byType(Scaffold)));
          await tester.pumpAndSettle();

          final signUpButtonFinder = find.text('Sign Up');
          expect(signUpButtonFinder, findsOneWidget);

          tester.view.viewInsets = const FakeViewPadding(bottom: 300);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));

          expect(signUpButtonFinder, findsOneWidget);

          addTearDown(() => tester.view.resetViewInsets());
        },
      );
    });

    group('image picker', () {
      testWidgets('shows system notice when image picker fails', (tester) async {
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

        expect(find.byType(WnSystemNotice), findsOneWidget);
        expect(find.text('Failed to pick image. Please try again.'), findsOneWidget);
      });

      testWidgets('dismisses notice after auto-hide duration', (tester) async {
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
        expect(find.byType(WnSystemNotice), findsOneWidget);

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(find.byType(WnSystemNotice), findsNothing);
      });
    });
  });
}
