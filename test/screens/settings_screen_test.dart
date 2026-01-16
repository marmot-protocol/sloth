import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/developer_settings_screen.dart';
import 'package:sloth/screens/donate_screen.dart';
import 'package:sloth/screens/edit_profile_screen.dart';
import 'package:sloth/screens/network_screen.dart';
import 'package:sloth/screens/profile_keys_screen.dart';
import 'package:sloth/screens/share_profile_screen.dart';
import 'package:sloth/screens/sign_out_screen.dart';
import 'package:sloth/screens/wip_screen.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockApi extends MockWnApi {
  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async => const FlutterMetadata(
    name: 'Test User',
    displayName: 'Test Display Name',
    custom: {},
  );

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

  @override
  Future<String?> build() async {
    state = const AsyncData('test_pubkey');
    return 'test_pubkey';
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}

void main() {
  setUpAll(() => RustLib.initMock(api: _MockApi()));

  late _MockAuthNotifier mockAuth;

  Future<void> pumpSettingsScreen(WidgetTester tester) async {
    mockAuth = _MockAuthNotifier();

    await mountTestApp(
      tester,
      overrides: [
        authProvider.overrideWith(() => mockAuth),
        secureStorageProvider.overrideWithValue(MockSecureStorage()),
      ],
    );
    Routes.pushToSettings(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('SettingsScreen', () {
    testWidgets('displays Settings title', (tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('displays user display name', (tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Test Display Name'), findsOneWidget);
    });

    testWidgets('tapping close icon returns to previous screen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('tapping Edit profile navigates to EditProfileScreen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('Edit profile'));
      await tester.pumpAndSettle();
      expect(find.byType(EditProfileScreen), findsOneWidget);
    });

    testWidgets('tapping Profile keys navigates to ProfileKeysScreen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('Profile keys'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileKeysScreen), findsOneWidget);
    });

    testWidgets('tapping QR code icon navigates to ShareProfileScreen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.byKey(const Key('qr_code_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ShareProfileScreen), findsOneWidget);
    });

    testWidgets('tapping Network relays navigates to NetworkScreen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('Network relays'));
      await tester.pumpAndSettle();
      expect(find.byType(NetworkScreen), findsOneWidget);
    });

    testWidgets('tapping App settings navigates to WIP screen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('App settings'));
      await tester.pumpAndSettle();
      expect(find.byType(WipScreen), findsOneWidget);
    });

    testWidgets('tapping Donate navigates to Donate screen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('Donate to White Noise'));
      await tester.pumpAndSettle();
      expect(find.byType(DonateScreen), findsOneWidget);
    });

    testWidgets('tapping Sign out navigates to SignOutScreen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.byType(SignOutScreen), findsOneWidget);
    });

    testWidgets('tapping Developer settings navigates to Developer settings screen', (
      tester,
    ) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('Developer settings'));
      await tester.pumpAndSettle();
      expect(find.byType(DeveloperSettingsScreen), findsOneWidget);
    });

    testWidgets('renders empty widget when pubkey becomes null', (tester) async {
      // This test verifies that hooks are called unconditionally and
      // the screen handles null pubkey gracefully without breaking hook ordering
      await pumpSettingsScreen(tester);

      // Verify screen is showing normally first
      expect(find.text('Settings'), findsOneWidget);

      // Now simulate the pubkey becoming null
      mockAuth.state = const AsyncData(null);
      await tester.pump();

      // The screen should now render an empty widget without throwing
      // The settings content should no longer be visible
      expect(find.text('Edit profile'), findsNothing);
    });
  });
}
