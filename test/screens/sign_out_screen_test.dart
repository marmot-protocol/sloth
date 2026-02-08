import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/providers/auth_provider.dart';
import 'package:whitenoise/routes.dart';
import 'package:whitenoise/screens/chat_list_screen.dart';
import 'package:whitenoise/screens/home_screen.dart';
import 'package:whitenoise/src/rust/api/accounts.dart';
import 'package:whitenoise/src/rust/frb_generated.dart';
import 'package:whitenoise/widgets/wn_copyable_field.dart' show WnCopyableField;
import 'package:whitenoise/widgets/wn_icon.dart';

import '../mocks/mock_clipboard.dart' show mockClipboard;
import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockApi extends MockWnApi {
  bool _exportNsecThrows = false;
  String? _exportThrowsForPubkey;
  AccountType _accountType = AccountType.local;

  void setExportNsecThrows(bool value) {
    _exportNsecThrows = value;
  }

  void setExportThrowsForPubkey(String? pubkey) {
    _exportThrowsForPubkey = pubkey;
  }

  void setAccountType(AccountType type) {
    _accountType = type;
  }

  @override
  Future<Account> crateApiAccountsGetAccount({required String pubkey}) async {
    return Account(
      pubkey: pubkey,
      accountType: _accountType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<String> crateApiAccountsExportAccountNsec({required String pubkey}) async {
    if (_exportNsecThrows || pubkey == _exportThrowsForPubkey) {
      throw Exception('Export error');
    }
    return 'nsec1test${pubkey.substring(0, 10)}';
  }
}

class _MockAuthNotifier extends AuthNotifier {
  bool logoutCalled = false;
  String? nextPubkeyAfterLogout;

  @override
  Future<String?> build() async {
    state = const AsyncData(testPubkeyA);
    return testPubkeyA;
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
  late _MockApi mockApi;

  setUpAll(() {
    mockApi = _MockApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.reset();
    mockApi.setExportNsecThrows(false);
    mockApi.setExportThrowsForPubkey(null);
    mockApi.setAccountType(AccountType.local);
  });

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
      expect(
        find.textContaining('If you haven\'t backed up your private key'),
        findsOneWidget,
      );
    });

    group('when nsec storage is external', () {
      testWidgets('shows only sign-out warning without backup paragraph or section', (
        tester,
      ) async {
        mockApi.setAccountType(AccountType.external_);
        await pumpSignOutScreen(tester);
        await tester.pumpAndSettle();
        expect(
          find.textContaining('When you sign out of White Noise'),
          findsOneWidget,
        );
        expect(
          find.textContaining('If you haven\'t backed up your private key'),
          findsNothing,
        );
        expect(find.text('Back up your private key'), findsNothing);
        expect(find.byType(WnCopyableField), findsNothing);
      });
    });

    testWidgets('displays back up section', (tester) async {
      await pumpSignOutScreen(tester);
      expect(find.text('Back up your private key'), findsOneWidget);
      expect(find.text('Private Key'), findsOneWidget);
    });

    testWidgets('loads and displays private key field', (tester) async {
      await pumpSignOutScreen(tester);
      await tester.pumpAndSettle();
      final privateKeyField = find.byType(WnCopyableField);
      expect(privateKeyField, findsOneWidget);
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

    testWidgets('dismisses notice after auto-hide duration', (tester) async {
      await pumpSignOutScreen(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('copy_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Private key copied to clipboard'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Private key copied to clipboard'), findsNothing);
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

    testWidgets('tapping back icon returns to previous screen', (tester) async {
      await pumpSignOutScreen(tester);
      await tester.tap(find.byKey(const Key('slate_back_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('tapping Sign out button calls logout and navigates to home', (tester) async {
      await pumpSignOutScreen(tester);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      final signOutButtons = find.text('Sign out');

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
      await pumpSignOutScreen(tester);

      expect(find.text('Sign out'), findsWidgets);

      mockAuth.state = const AsyncData(null);
      await tester.pump();

      expect(find.text('Are you sure you want to sign out?'), findsNothing);
      expect(find.byType(WnCopyableField), findsNothing);
    });

    testWidgets('shows error notice when nsec fails to load', (tester) async {
      mockApi.setExportNsecThrows(true);
      await pumpSignOutScreen(tester);
      await tester.pumpAndSettle();

      const errorText = 'Could not load private key. Please try again.';
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (tester.widgetList(find.text(errorText)).isNotEmpty) break;
      }
      expect(find.text(errorText), findsOneWidget);
    });

    testWidgets('dismisses error notice when nsec loads successfully after previous error', (
      tester,
    ) async {
      mockApi.setExportThrowsForPubkey(testPubkeyA);
      await pumpSignOutScreen(tester);
      await tester.pumpAndSettle();
      mockAuth.state = const AsyncData(testPubkeyB);
      await tester.pumpAndSettle();
      expect(
        find.text('Could not load private key. Please try again.'),
        findsNothing,
      );
    });
  });
}
