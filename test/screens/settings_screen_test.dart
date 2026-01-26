import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/app_settings_screen.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/developer_settings_screen.dart';
import 'package:sloth/screens/donate_screen.dart';
import 'package:sloth/screens/edit_profile_screen.dart';
import 'package:sloth/screens/network_screen.dart';
import 'package:sloth/screens/profile_keys_screen.dart';
import 'package:sloth/screens/share_profile_screen.dart';
import 'package:sloth/screens/sign_out_screen.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/wn_avatar.dart';

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
  Future<String> crateApiAccountsExportAccountNsec({required String pubkey}) async {
    return 'nsec1test${pubkey.substring(0, 10)}';
  }
}

class _MockAuthNotifier extends AuthNotifier {
  _MockAuthNotifier([this._pubkey = testPubkeyA]);

  final String _pubkey;
  bool logoutCalled = false;

  @override
  Future<String?> build() async {
    state = AsyncData(_pubkey);
    return _pubkey;
  }

  @override
  Future<String?> logout({Future<void> Function()? onAmberDisconnect}) async {
    logoutCalled = true;
    return null;
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
  });

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

    testWidgets('displays formatted pubkey under display name', (tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text(testNpubAFormatted), findsOneWidget);
    });

    testWidgets('tapping close icon returns to previous screen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.byKey(const Key('slate_close_button')));
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

    testWidgets('tapping Share & connect button navigates to ShareProfileScreen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.byKey(const Key('share_and_connect_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ShareProfileScreen), findsOneWidget);
    });

    testWidgets('tapping Network relays navigates to NetworkScreen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('Network relays'));
      await tester.pumpAndSettle();
      expect(find.byType(NetworkScreen), findsOneWidget);
    });

    testWidgets('tapping App settings navigates to AppSettingsScreen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('App settings'));
      await tester.pumpAndSettle();
      expect(find.byType(AppSettingsScreen), findsOneWidget);
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

    testWidgets('tapping Switch profile navigates to SwitchProfileScreen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('Switch profile'));
      await tester.pumpAndSettle();
      expect(find.text('Profiles'), findsOneWidget);
    });

    testWidgets('renders empty widget when pubkey becomes null', (tester) async {
      await pumpSettingsScreen(tester);

      expect(find.text('Settings'), findsOneWidget);

      mockAuth.state = const AsyncData(null);
      await tester.pump();

      expect(find.text('Edit profile'), findsNothing);
    });

    testWidgets('passes color derived from pubkey to avatar', (tester) async {
      await pumpSettingsScreen(tester);

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.color, AvatarColor.violet);
    });

    testWidgets('different pubkey passes different avatar color', (tester) async {
      await mountTestApp(
        tester,
        overrides: [
          authProvider.overrideWith(() => _MockAuthNotifier(testPubkeyD)),
          secureStorageProvider.overrideWithValue(MockSecureStorage()),
        ],
      );
      Routes.pushToSettings(tester.element(find.byType(Scaffold)));
      await tester.pumpAndSettle();

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.color, AvatarColor.cyan);
    });
  });
}
