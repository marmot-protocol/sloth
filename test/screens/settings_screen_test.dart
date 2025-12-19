import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/developer_settings_screen.dart';
import 'package:sloth/screens/donate_screen.dart';
import 'package:sloth/screens/wip_screen.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';
import '../test_helpers.dart';

class _MockApi implements RustLibApi {
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
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('tapping Edit profile navigates to WIP screen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('Edit profile'));
      await tester.pumpAndSettle();
      expect(find.byType(WipScreen), findsOneWidget);
    });

    testWidgets('tapping Profile keys navigates to WIP screen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('Profile keys'));
      await tester.pumpAndSettle();
      expect(find.byType(WipScreen), findsOneWidget);
    });

    testWidgets('tapping Network relays navigates to WIP screen', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('Network relays'));
      await tester.pumpAndSettle();
      expect(find.byType(WipScreen), findsOneWidget);
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

    testWidgets('tapping Sign out calls logout', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('Sign out'));
      await tester.pump();
      expect(mockAuth.logoutCalled, isTrue);
    });

    testWidgets('tapping Developer settings navigates to Developer settings screen', (
      tester,
    ) async {
      await pumpSettingsScreen(tester);
      await tester.tap(find.text('Developer settings'));
      await tester.pumpAndSettle();
      expect(find.byType(DeveloperSettingsScreen), findsOneWidget);
    });
  });
}
