import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/home_screen.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/wn_text_form_field.dart';

import '../mocks/mock_clipboard.dart' show mockClipboard;
import '../mocks/mock_secure_storage.dart';
import '../test_helpers.dart';

class _MockApi implements RustLibApi {
  @override
  String crateApiUtilsNpubFromHexPubkey({required String hexPubkey}) {
    return 'npub1test${hexPubkey.substring(0, 10)}';
  }

  @override
  Future<String> crateApiAccountsExportAccountNsec({required String pubkey}) async {
    return 'nsec1test${pubkey.substring(0, 10)}';
  }

  @override
  Future<void> crateApiAccountsLogout({required String pubkey}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _MockAuthNotifier extends AuthNotifier {
  bool logoutCalled = false;

  @override
  Future<String?> build() async {
    state = const AsyncData('test_pubkey');
    return 'test_pubkey';
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    state = const AsyncData(null);
  }
}

void main() {
  setUpAll(() => RustLib.initMock(api: _MockApi()));

  late _MockAuthNotifier mockAuth;

  Future<void> pumpSignOutScreen(WidgetTester tester) async {
    mockAuth = _MockAuthNotifier();

    await mountTestApp(
      tester,
      overrides: [
        authProvider.overrideWith(() => mockAuth),
        secureStorageProvider.overrideWithValue(MockSecureStorage()),
      ],
    );
    Routes.pushToSignOut(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('SignOutScreen', () {
    testWidgets('displays Sign out title', (tester) async {
      await pumpSignOutScreen(tester);
      expect(find.text('Sign out'), findsWidgets);
    });

    testWidgets('displays warning box with confirmation message', (tester) async {
      await pumpSignOutScreen(tester);
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
      expect(
        find.textContaining('When you sign out of White Noise'),
        findsOneWidget,
      );
    });

    testWidgets('displays back up section', (tester) async {
      await pumpSignOutScreen(tester);
      expect(find.text('Back up your private key'), findsOneWidget);
      expect(find.text('Private key'), findsOneWidget);
    });

    testWidgets('loads and displays nsec in private key field', (tester) async {
      await pumpSignOutScreen(tester);
      await tester.pumpAndSettle();
      final privateKeyField = find.byType(WnTextFormField);
      expect(privateKeyField, findsOneWidget);
      final textField = find.descendant(
        of: privateKeyField,
        matching: find.byType(TextFormField),
      );
      expect(textField, findsOneWidget);
      final fieldText = tester.widget<TextFormField>(textField).controller?.text ?? '';
      expect(fieldText, startsWith('nsec1'));
    });

    testWidgets('tapping copy button copies private key to clipboard', (tester) async {
      final getClipboard = mockClipboard();
      await pumpSignOutScreen(tester);
      await tester.pumpAndSettle();
      final copyButton = find.byIcon(Icons.copy);
      expect(copyButton, findsOneWidget);
      await tester.tap(copyButton);
      await tester.pump();
      expect(getClipboard(), startsWith('nsec1'));
    });

    testWidgets('shows success message when copying private key', (tester) async {
      await pumpSignOutScreen(tester);
      await tester.pumpAndSettle();
      final copyButton = find.byIcon(Icons.copy);
      await tester.tap(copyButton);
      await tester.pump();
      expect(find.text('Private key copied to clipboard'), findsOneWidget);
    });

    testWidgets('tapping visibility toggle shows/hides private key', (tester) async {
      await pumpSignOutScreen(tester);
      await tester.pumpAndSettle();
      final visibilityButton = find.byIcon(Icons.visibility_outlined);
      expect(visibilityButton, findsOneWidget);
      await tester.tap(visibilityButton);
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('tapping close icon returns to previous screen', (tester) async {
      await pumpSignOutScreen(tester);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('tapping Sign out button calls logout and navigates to home', (tester) async {
      await pumpSignOutScreen(tester);
      await tester.pumpAndSettle();

      // Scroll to the bottom to find the sign out button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      final signOutButtons = find.text('Sign out');
      // Find the button (not the header title)
      await tester.tap(signOutButtons.last);
      await tester.pumpAndSettle();

      expect(mockAuth.logoutCalled, isTrue);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
