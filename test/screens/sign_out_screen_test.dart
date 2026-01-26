import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/home_screen.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_text_form_field.dart';

import '../mocks/mock_clipboard.dart' show mockClipboard;
import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockApi extends MockWnApi {
  @override
  String crateApiUtilsNpubFromHexPubkey({required String hexPubkey}) {
    return 'npub1test${hexPubkey.substring(0, 10)}';
  }

  @override
  Future<String> crateApiAccountsExportAccountNsec({required String pubkey}) async {
    return 'nsec1test${pubkey.substring(0, 10)}';
  }
}

class _MockAuthNotifier extends AuthNotifier {
  bool logoutCalled = false;
  String? nextPubkeyAfterLogout;

  @override
  Future<String?> build() async {
    state = const AsyncData('test_pubkey');
    return 'test_pubkey';
  }

  @override
  Future<String?> logout() async {
    logoutCalled = true;
    if (nextPubkeyAfterLogout == null) {
      state = const AsyncData(null);
    }
    return nextPubkeyAfterLogout;
  }
}

void main() {
  setUpAll(() => RustLib.initMock(api: _MockApi()));

  late _MockAuthNotifier mockAuth;

  Future<void> pumpSignOutScreen(
    WidgetTester tester, {
    _MockAuthNotifier? authNotifier,
  }) async {
    mockAuth = authNotifier ?? _MockAuthNotifier();

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
      final copyButton = find.byKey(const Key('copy_button'));
      expect(copyButton, findsOneWidget);
      await tester.tap(copyButton);
      await tester.pump();
      expect(getClipboard(), startsWith('nsec1'));
    });

    testWidgets('shows success message when copying private key', (tester) async {
      await pumpSignOutScreen(tester);
      await tester.pumpAndSettle();
      final copyButton = find.byKey(const Key('copy_button'));
      await tester.tap(copyButton);
      await tester.pump();
      expect(find.text('Private key copied to clipboard'), findsOneWidget);
    });

    testWidgets('tapping visibility toggle shows/hides private key', (tester) async {
      await pumpSignOutScreen(tester);
      await tester.pumpAndSettle();
      final visibilityToggle = find.byKey(const Key('visibility_toggle'));
      expect(visibilityToggle, findsOneWidget);

      var icons = find.byType(WnIcon).evaluate();
      var hasViewIcon = icons.any((e) => (e.widget as WnIcon).icon == WnIcons.view);
      expect(hasViewIcon, isTrue);

      await tester.tap(visibilityToggle);
      await tester.pump();

      icons = find.byType(WnIcon).evaluate();
      final hasViewOffIcon = icons.any((e) => (e.widget as WnIcon).icon == WnIcons.viewOff);
      expect(hasViewOffIcon, isTrue);

      await tester.tap(visibilityToggle);
      await tester.pump();

      icons = find.byType(WnIcon).evaluate();
      hasViewIcon = icons.any((e) => (e.widget as WnIcon).icon == WnIcons.view);
      expect(hasViewIcon, isTrue);
    });

    testWidgets('tapping close icon returns to previous screen', (tester) async {
      await pumpSignOutScreen(tester);
      await tester.tap(find.byKey(const Key('close_button')));
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

    testWidgets('signing out with another account returns to previous screen', (tester) async {
      final authNotifier = _MockAuthNotifier();
      authNotifier.nextPubkeyAfterLogout = 'another_pubkey';

      await pumpSignOutScreen(tester, authNotifier: authNotifier);

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      final signOutButtons = find.text('Sign out');
      await tester.tap(signOutButtons.last);
      await tester.pumpAndSettle();

      expect(mockAuth.logoutCalled, isTrue);
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('renders empty widget when pubkey becomes null during logout', (tester) async {
      // This test verifies the fix for issue #35: during logout, there's a race
      // condition where authProvider sets pubkey to null but widgets are still
      // mounted and try to rebuild. The screen should handle this gracefully
      // by returning SizedBox.shrink() instead of throwing.
      await pumpSignOutScreen(tester);

      // Verify screen is showing normally first
      expect(find.text('Sign out'), findsWidgets);

      // Now simulate the logout race condition by setting pubkey to null
      mockAuth.state = const AsyncData(null);
      await tester.pump();

      // The screen should now render an empty widget without throwing
      // The sign out content should no longer be visible
      expect(find.text('Are you sure you want to sign out?'), findsNothing);
      expect(find.byType(WnTextFormField), findsNothing);
    });
  });
}
