import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async {
    state = const AsyncData('test_pubkey');
    return 'test_pubkey';
  }
}

void main() {
  late MockWnApi mockApi;

  setUpAll(() {
    mockApi = MockWnApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.reset();
  });

  Future<void> pumpAppSettingsScreen(
    WidgetTester tester, {
    String? initialThemeMode,
  }) async {
    if (initialThemeMode != null) {
      mockApi.currentThemeMode = initialThemeMode;
    }

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
      expect(find.byKey(const Key('dropdown_icon')), findsOneWidget);
    });
  });
}
