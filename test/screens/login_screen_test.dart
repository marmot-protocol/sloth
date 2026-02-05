import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/android_signer_service_provider.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/home_screen.dart';
import 'package:sloth/services/android_signer_service.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';
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

class _MockAndroidSignerService implements AndroidSignerService {
  @override
  bool get platformIsAndroid => false;

  bool _isAvailable = false;
  String? _pubkeyToReturn;
  Exception? _getPublicKeyError;

  void setAvailable(bool value) => _isAvailable = value;
  void setPubkeyToReturn(String value) => _pubkeyToReturn = value;
  void setGetPublicKeyError(Exception? value) => _getPublicKeyError = value;

  @override
  Future<bool> isAvailable() async => _isAvailable;

  @override
  Future<String> getPublicKey({List<SignerPermission>? permissions}) async {
    if (_getPublicKeyError != null) throw _getPublicKeyError!;
    return _pubkeyToReturn ?? testPubkeyA;
  }

  @override
  Future<AndroidSignerResponse> signEvent({
    required String eventJson,
    String? id,
    String? currentUser,
  }) async => throw UnimplementedError();

  @override
  Future<String> nip04Encrypt({
    required String plaintext,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async => throw UnimplementedError();

  @override
  Future<String> nip04Decrypt({
    required String encryptedText,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async => throw UnimplementedError();

  @override
  Future<String> nip44Encrypt({
    required String plaintext,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async => throw UnimplementedError();

  @override
  Future<String> nip44Decrypt({
    required String encryptedText,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async => throw UnimplementedError();

  @override
  Future<String?> getSignerPackageName() async => null;

  @override
  Future<void> setSignerPackageName(String packageName) async {}
}

void main() {
  setUpAll(() {
    RustLib.initMock(api: _MockApi());
  });

  late _MockAuthNotifier mockAuth;
  late _MockAndroidSignerService mockSignerService;

  Future<void> pumpLoginScreen(
    WidgetTester tester, {
    bool signerAvailable = false,
  }) async {
    mockAuth = _MockAuthNotifier();
    mockSignerService = _MockAndroidSignerService();
    mockSignerService.setAvailable(signerAvailable);
    mockSignerService.setPubkeyToReturn(testPubkeyA);

    await mountTestApp(
      tester,
      overrides: [
        authProvider.overrideWith(() => mockAuth),
        androidSignerServiceProvider.overrideWithValue(mockSignerService),
      ],
    );

    Routes.pushToLogin(tester.element(find.byType(Scaffold)));
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

      testWidgets('redirects to chat list on successful signer login', (tester) async {
        await pumpLoginScreen(tester, signerAvailable: true);
        await tester.tap(find.byKey(const Key('android_signer_login_button')));
        await tester.pumpAndSettle();
        expect(find.byType(ChatListScreen), findsOneWidget);
      });

      testWidgets('shows user-friendly error for AndroidSignerException', (tester) async {
        await pumpLoginScreen(tester, signerAvailable: true);
        mockSignerService.setGetPublicKeyError(
          const AndroidSignerException('USER_REJECTED', 'User rejected'),
        );
        await tester.tap(find.byKey(const Key('android_signer_login_button')));
        await tester.pumpAndSettle();
        expect(find.text('Login cancelled'), findsOneWidget);
        expect(find.byType(ChatListScreen), findsNothing);
      });

      testWidgets('shows generic error for other exceptions', (tester) async {
        await pumpLoginScreen(tester, signerAvailable: true);
        mockSignerService.setGetPublicKeyError(Exception('Network error'));
        await tester.tap(find.byKey(const Key('android_signer_login_button')));
        await tester.pumpAndSettle();
        expect(find.textContaining('Unable to connect to signer'), findsOneWidget);
        expect(find.byType(ChatListScreen), findsNothing);
      });
    });
  });
}
