import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData, ProviderScope;
import 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtilInit;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/l10n/generated/app_localizations.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/home_screen.dart';
import 'package:sloth/screens/login_screen.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_android_signer_channel.dart';
import '../mocks/mock_clipboard_paste.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockApi extends MockWnApi {
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
}

class _MockAuthNotifier extends AuthNotifier {
  bool loginCalled = false;
  String? lastNsec;
  Exception? errorToThrow;
  bool loginWithSignerCalled = false;
  String? lastSignerPubkey;
  Exception? signerErrorToThrow;

  @override
  Future<String?> build() async => null;

  @override
  Future<void> login(String nsec) async {
    loginCalled = true;
    lastNsec = nsec;
    if (errorToThrow != null) throw errorToThrow!;
    state = const AsyncData(testPubkeyA);
  }

  @override
  Future<void> loginWithAndroidSigner({
    required String pubkey,
    required Future<void> Function() onDisconnect,
  }) async {
    loginWithSignerCalled = true;
    lastSignerPubkey = pubkey;
    if (signerErrorToThrow != null) throw signerErrorToThrow!;
    state = AsyncData(pubkey);
  }
}

const _localizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

void main() {
  setUpAll(() {
    RustLib.initMock(api: _MockApi());
  });

  late _MockAuthNotifier mockAuth;
  late dynamic mockSignerChannel;

  tearDown(() {
    mockSignerChannel.reset();
  });

  Future<void> pumpLoginScreen(
    WidgetTester tester, {
    bool signerAvailable = false,
  }) async {
    mockAuth = _MockAuthNotifier();
    mockSignerChannel = mockAndroidSignerChannel();
    if (signerAvailable) {
      mockSignerChannel.setResult('isExternalSignerInstalled', true);
      mockSignerChannel.setResult('getPublicKey', {'result': testPubkeyA});
    }

    if (signerAvailable) {
      setUpTestView(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(() => mockAuth)],
          child: ScreenUtilInit(
            designSize: testDesignSize,
            builder: (_, __) => const MaterialApp(
              locale: Locale('en'),
              localizationsDelegates: _localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: LoginScreen(platformIsAndroidOverride: true),
            ),
          ),
        ),
      );
    } else {
      await mountTestApp(
        tester,
        overrides: [authProvider.overrideWith(() => mockAuth)],
      );
      Routes.pushToLogin(tester.element(find.byType(Scaffold)));
    }
    await tester.pumpAndSettle();
  }

  group('LoginScreen', () {
    group('navigation', () {
      testWidgets('tapping back button returns to home screen', (tester) async {
        await pumpLoginScreen(tester);
        await tester.tap(find.byKey(const Key('slate_back_button')));
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
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pump();
        expect(mockAuth.lastNsec, 'nsec1test');
        expect(mockAuth.loginCalled, isTrue);
      });

      group('when login is successful', () {
        testWidgets('redirects to chat list screen on success', (tester) async {
          await pumpLoginScreen(tester);
          await tester.enterText(find.byType(TextField), 'nsec1test');
          await tester.tap(find.byKey(const Key('login_button')));
          await tester.pumpAndSettle();
          expect(find.byType(ChatListScreen), findsOneWidget);
        });
      });

      group('when login fails', () {
        testWidgets('does not redirect to chat list screen', (tester) async {
          await pumpLoginScreen(tester);
          mockAuth.errorToThrow = Exception('Invalid key');
          await tester.enterText(find.byType(TextField), 'nsec1test');
          await tester.tap(find.byKey(const Key('login_button')));
          await tester.pumpAndSettle();
          expect(find.byType(ChatListScreen), findsNothing);
        });

        testWidgets('shows error message on failure', (tester) async {
          await pumpLoginScreen(tester);
          mockAuth.errorToThrow = Exception('Invalid key');
          await tester.enterText(find.byType(TextField), 'nsec1test');
          await tester.tap(find.byKey(const Key('login_button')));
          await tester.pumpAndSettle();
          expect(
            find.textContaining('Oh no! An error occurred, please try again.'),
            findsOneWidget,
          );
        });
      });
    });

    group('paste button', () {
      late void Function(Map<String, dynamic>?) setClipboardData;
      late void Function() resetClipboard;

      setUp(() {
        final mock = mockClipboardPaste();
        setClipboardData = mock.setData;
        resetClipboard = mock.reset;
      });

      tearDown(() {
        resetClipboard();
      });

      testWidgets('displays paste button', (tester) async {
        await pumpLoginScreen(tester);
        expect(find.byKey(const Key('paste_button')), findsOneWidget);
      });

      testWidgets('pastes clipboard text into field', (tester) async {
        await pumpLoginScreen(tester);
        setClipboardData({'text': 'nsec1pasted'});
        await tester.tap(find.byKey(const Key('paste_button')));
        await tester.pumpAndSettle();
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, 'nsec1pasted');
      });
    });

    group('Android signer login', () {
      testWidgets('does not show signer button when signer unavailable', (tester) async {
        await pumpLoginScreen(tester);
        expect(find.byKey(const Key('android_signer_login_button')), findsNothing);
      });

      testWidgets('shows signer button when signer is available', (tester) async {
        await pumpLoginScreen(tester, signerAvailable: true);
        expect(find.byKey(const Key('android_signer_login_button')), findsOneWidget);
      });

      testWidgets('calls loginWithAndroidSigner when signer button is tapped', (tester) async {
        await pumpLoginScreen(tester, signerAvailable: true);
        await tester.tap(find.byKey(const Key('android_signer_login_button')));
        await tester.pumpAndSettle();
        expect(mockAuth.loginWithSignerCalled, isTrue);
        expect(mockAuth.lastSignerPubkey, testPubkeyA);
      });

      testWidgets('completes signer login successfully', (tester) async {
        await pumpLoginScreen(tester, signerAvailable: true);
        await tester.tap(find.byKey(const Key('android_signer_login_button')));
        await tester.pumpAndSettle();
        expect(mockAuth.loginWithSignerCalled, isTrue);
        expect(mockAuth.lastSignerPubkey, testPubkeyA);
      });

      testWidgets('shows user-friendly error for AndroidSignerException', (tester) async {
        await pumpLoginScreen(tester, signerAvailable: true);
        mockSignerChannel.setException(
          'getPublicKey',
          PlatformException(code: 'USER_REJECTED', message: 'User rejected'),
        );
        await tester.tap(find.byKey(const Key('android_signer_login_button')));
        await tester.pumpAndSettle();
        expect(find.text('Login cancelled'), findsOneWidget);
        expect(find.byType(ChatListScreen), findsNothing);
      });

      testWidgets('shows generic error for other exceptions', (tester) async {
        await pumpLoginScreen(tester, signerAvailable: true);
        mockSignerChannel.setException(
          'getPublicKey',
          PlatformException(code: 'UNKNOWN', message: 'Network error'),
        );
        await tester.tap(find.byKey(const Key('android_signer_login_button')));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('An error occurred with the signer. Please try again.'),
          findsOneWidget,
        );
        expect(find.byType(ChatListScreen), findsNothing);
      });
    });
  });
}
