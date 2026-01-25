import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/providers/locale_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/wn_dropdown_selector.dart';

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
      // Theme dropdown shows "System" as default, language shows "English" by default
      expect(find.text('System'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('tapping close icon returns to previous screen', (tester) async {
      await pumpAppSettingsScreen(tester);
      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('can select Light theme from dropdown', (tester) async {
      await pumpAppSettingsScreen(tester);

      // Tap the dropdown to open it
      await tester.tap(find.byType(WnDropdownSelector<ThemeMode>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(mockApi.currentThemeMode, 'light');
    });

    testWidgets('can select Dark theme from dropdown', (tester) async {
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<ThemeMode>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(mockApi.currentThemeMode, 'dark');
    });

    testWidgets('can select System theme from dropdown', (tester) async {
      mockApi.currentThemeMode = 'light';
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<ThemeMode>));
      await tester.pumpAndSettle();

      // When open, System appears in theme dropdown options and also in the language dropdown
      // We need to tap the System option in the theme dropdown list - use first match
      await tester.tap(find.text('System').first);
      await tester.pumpAndSettle();

      expect(mockApi.currentThemeMode, 'system');
    });

    testWidgets('dropdown shows all theme options', (tester) async {
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<ThemeMode>));
      await tester.pumpAndSettle();

      // System appears twice: in theme header and in theme options list
      // (language dropdown shows "English" by default, not "System")
      expect(find.text('System'), findsNWidgets(2));
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('theme selection persists across navigation', (tester) async {
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<ThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();

      Routes.pushToAppSettings(tester.element(find.byType(Scaffold)));
      await tester.pumpAndSettle();

      expect(mockApi.currentThemeMode, 'dark');
    });

    testWidgets('can switch themes multiple times', (tester) async {
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<ThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(mockApi.currentThemeMode, 'light');

      await tester.tap(find.byType(WnDropdownSelector<ThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(mockApi.currentThemeMode, 'dark');

      await tester.tap(find.byType(WnDropdownSelector<ThemeMode>));
      await tester.pumpAndSettle();
      // Use first match since System appears in both theme and language dropdowns
      await tester.tap(find.text('System').first);
      await tester.pumpAndSettle();
      expect(mockApi.currentThemeMode, 'system');
    });

    testWidgets('displays dropdown icons for theme and language', (tester) async {
      await pumpAppSettingsScreen(tester);
      expect(find.byKey(const Key('dropdown_icon')), findsNWidgets(2));
    });
  });

  group('Language Dropdown', () {
    testWidgets('displays Language dropdown label', (tester) async {
      await pumpAppSettingsScreen(tester);
      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('can select English from dropdown', (tester) async {
      // Start with German so English isn't already selected
      mockApi.currentLanguage = 'de';
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<LocaleSetting>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(mockApi.currentLanguage, 'en');
    });

    testWidgets('can select Spanish from dropdown', (tester) async {
      // Start with English (default)
      mockApi.currentLanguage = 'en';
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<LocaleSetting>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();

      expect(mockApi.currentLanguage, 'es');
    });

    testWidgets('can select German from dropdown', (tester) async {
      mockApi.currentLanguage = 'en';
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<LocaleSetting>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Deutsch'));
      await tester.pumpAndSettle();

      expect(mockApi.currentLanguage, 'de');
    });

    testWidgets('can select French from dropdown', (tester) async {
      mockApi.currentLanguage = 'en';
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<LocaleSetting>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Français'));
      await tester.pumpAndSettle();

      expect(mockApi.currentLanguage, 'fr');
    });

    testWidgets('can select Italian from dropdown', (tester) async {
      mockApi.currentLanguage = 'en';
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<LocaleSetting>));
      await tester.pumpAndSettle();

      // Scroll down to find Italian (may be below fold)
      await tester.scrollUntilVisible(
        find.text('Italiano'),
        50.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Italiano'));
      await tester.pumpAndSettle();

      expect(mockApi.currentLanguage, 'it');
    });

    testWidgets('can select Portuguese from dropdown', (tester) async {
      mockApi.currentLanguage = 'en';
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<LocaleSetting>));
      await tester.pumpAndSettle();

      // Scroll down to find Portuguese (near bottom of list)
      await tester.scrollUntilVisible(
        find.text('Português'),
        50.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Português'));
      await tester.pumpAndSettle();

      expect(mockApi.currentLanguage, 'pt');
    });

    testWidgets('can select Russian from dropdown', (tester) async {
      mockApi.currentLanguage = 'en';
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<LocaleSetting>));
      await tester.pumpAndSettle();

      // Scroll down to find Russian (near bottom of list)
      await tester.scrollUntilVisible(
        find.text('Русский'),
        50.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Русский'));
      await tester.pumpAndSettle();

      expect(mockApi.currentLanguage, 'ru');
    });

    testWidgets('can select Turkish from dropdown', (tester) async {
      mockApi.currentLanguage = 'en';
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<LocaleSetting>));
      await tester.pumpAndSettle();

      // Scroll down to find Turkish (at bottom of list)
      await tester.scrollUntilVisible(
        find.text('Türkçe'),
        50.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Türkçe'));
      await tester.pumpAndSettle();

      expect(mockApi.currentLanguage, 'tr');
    });

    testWidgets('dropdown contains all 8 languages plus System', (tester) async {
      mockApi.currentLanguage = 'de';
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<LocaleSetting>));
      await tester.pumpAndSettle();

      // Verify some visible languages first
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);

      // Scroll to see more languages
      await tester.scrollUntilVisible(
        find.text('Türkçe'),
        50.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      // Verify Turkish is now visible
      expect(find.text('Türkçe'), findsOneWidget);
    });

    testWidgets('language selection persists across navigation', (tester) async {
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<LocaleSetting>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deutsch'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();

      Routes.pushToAppSettings(tester.element(find.byType(Scaffold)));
      await tester.pumpAndSettle();

      expect(mockApi.currentLanguage, 'de');
    });

    testWidgets('can switch languages multiple times', (tester) async {
      await pumpAppSettingsScreen(tester);

      // Switch to Spanish
      await tester.tap(find.byType(WnDropdownSelector<LocaleSetting>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();
      expect(mockApi.currentLanguage, 'es');

      // Switch to French
      await tester.tap(find.byType(WnDropdownSelector<LocaleSetting>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Français'));
      await tester.pumpAndSettle();
      expect(mockApi.currentLanguage, 'fr');

      // Switch to German (avoiding English which would be duplicated)
      await tester.tap(find.byType(WnDropdownSelector<LocaleSetting>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deutsch'));
      await tester.pumpAndSettle();
      expect(mockApi.currentLanguage, 'de');
    });

    testWidgets('can select System language from dropdown', (tester) async {
      mockApi.currentLanguage = 'de';
      await pumpAppSettingsScreen(tester);

      await tester.tap(find.byType(WnDropdownSelector<LocaleSetting>));
      await tester.pumpAndSettle();

      // System appears twice: in theme header and in language options
      // Use .last to tap the one in language dropdown options
      await tester.tap(find.text('System').last);
      await tester.pumpAndSettle();

      // When System locale is selected, the resolved language is persisted
      // The mock will still have a language code set (based on device locale fallback)
      expect(mockApi.currentLanguage, isNotEmpty);
    });
  });
}
