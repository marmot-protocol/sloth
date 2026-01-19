import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/src/rust/api.dart' as rust_api;
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockThemeMode implements rust_api.ThemeMode {
  final String mode;
  const _MockThemeMode(this.mode);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _MockAppSettings implements rust_api.AppSettings {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _MockApi extends MockWnApi {
  String currentThemeMode = 'system';

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
  rust_api.ThemeMode crateApiUtilsThemeModeLight() => const _MockThemeMode('light');

  @override
  rust_api.ThemeMode crateApiUtilsThemeModeDark() => const _MockThemeMode('dark');

  @override
  rust_api.ThemeMode crateApiUtilsThemeModeSystem() => const _MockThemeMode('system');

  @override
  String crateApiUtilsThemeModeToString({required rust_api.ThemeMode themeMode}) {
    return (themeMode as _MockThemeMode).mode;
  }

  @override
  Future<rust_api.AppSettings> crateApiGetAppSettings() async {
    return _MockAppSettings();
  }

  @override
  Future<rust_api.ThemeMode> crateApiAppSettingsThemeMode({
    required rust_api.AppSettings appSettings,
  }) async {
    return _MockThemeMode(currentThemeMode);
  }

  @override
  Future<void> crateApiUpdateThemeMode({
    required rust_api.ThemeMode themeMode,
  }) async {
    currentThemeMode = (themeMode as _MockThemeMode).mode;
  }
}

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async {
    state = const AsyncData('test_pubkey');
    return 'test_pubkey';
  }
}

void main() {
  late _MockApi mockApi;

  setUpAll(() {
    mockApi = _MockApi();
    RustLib.initMock(api: mockApi);
  });

  Future<void> pumpAppSettingsScreen(WidgetTester tester) async {
    mockApi.currentThemeMode = 'system';

    await mountTestApp(
      tester,
      overrides: [
        authProvider.overrideWith(() => _MockAuthNotifier()),
        secureStorageProvider.overrideWithValue(MockSecureStorage()),
      ],
    );
    Routes.pushToAppSettings(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('AppSettingsScreen', () {
    testWidgets('displays App Settings title', (tester) async {
      await pumpAppSettingsScreen(tester);
      expect(find.text('App Settings'), findsOneWidget);
    });

    testWidgets('displays Theme dropdown label', (tester) async {
      await pumpAppSettingsScreen(tester);
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('displays current theme value in dropdown', (tester) async {
      await pumpAppSettingsScreen(tester);
      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('tapping close icon returns to previous screen', (tester) async {
      await pumpAppSettingsScreen(tester);
      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('can select Light theme from dropdown', (tester) async {
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(DropdownButton<ThemeMode>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Light').last);
      await tester.pumpAndSettle();

      expect(mockApi.currentThemeMode, 'light');
    });

    testWidgets('can select Dark theme from dropdown', (tester) async {
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(DropdownButton<ThemeMode>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();

      expect(mockApi.currentThemeMode, 'dark');
    });

    testWidgets('can select System theme from dropdown', (tester) async {
      mockApi.currentThemeMode = 'light';
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(DropdownButton<ThemeMode>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('System').last);
      await tester.pumpAndSettle();

      expect(mockApi.currentThemeMode, 'system');
    });

    testWidgets('dropdown shows all theme options', (tester) async {
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(DropdownButton<ThemeMode>));
      await tester.pumpAndSettle();

      expect(find.text('System'), findsWidgets);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('theme selection persists across navigation', (tester) async {
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(DropdownButton<ThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();

      Routes.pushToAppSettings(tester.element(find.byType(Scaffold)));
      await tester.pumpAndSettle();

      expect(mockApi.currentThemeMode, 'dark');
    });

    testWidgets('can switch themes multiple times', (tester) async {
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(DropdownButton<ThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Light').last);
      await tester.pumpAndSettle();
      expect(mockApi.currentThemeMode, 'light');

      await tester.tap(find.byType(DropdownButton<ThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();
      expect(mockApi.currentThemeMode, 'dark');

      await tester.tap(find.byType(DropdownButton<ThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('System').last);
      await tester.pumpAndSettle();
      expect(mockApi.currentThemeMode, 'system');
    });

    testWidgets('displays dropdown icon', (tester) async {
      await pumpAppSettingsScreen(tester);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });
  });
}
