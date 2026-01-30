import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/home_screen.dart';
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

  @override
  Future<String?> build() async => null;

  @override
  Future<void> login(String nsec) async {
    loginCalled = true;
    lastNsec = nsec;
    if (errorToThrow != null) throw errorToThrow!;
    state = const AsyncData(testPubkeyA);
  }
}

void main() {
  setUpAll(() {
    RustLib.initMock(api: _MockApi());
  });

  late _MockAuthNotifier mockAuth;

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    mockAuth = _MockAuthNotifier();

    await mountTestApp(
      tester,
      overrides: [authProvider.overrideWith(() => mockAuth)],
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
        await tester.tap(find.text('Login'));
        await tester.pump();
        expect(mockAuth.lastNsec, 'nsec1test');
        expect(mockAuth.loginCalled, isTrue);
      });

      group('when login is successful', () {
        testWidgets('redirects to chat list screen on success', (tester) async {
          await pumpLoginScreen(tester);
          await tester.enterText(find.byType(TextField), 'nsec1test');
          await tester.tap(find.text('Login'));
          await tester.pumpAndSettle();
          expect(find.byType(ChatListScreen), findsOneWidget);
        });
      });

      group('when login fails', () {
        testWidgets('does not redirect to chat list screen', (tester) async {
          await pumpLoginScreen(tester);
          mockAuth.errorToThrow = Exception('Invalid key');
          await tester.enterText(find.byType(TextField), 'nsec1test');
          await tester.tap(find.text('Login'));
          await tester.pumpAndSettle();
          expect(find.byType(ChatListScreen), findsNothing);
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
  });
}
