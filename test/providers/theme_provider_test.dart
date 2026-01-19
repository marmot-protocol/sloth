import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/theme_provider.dart';
import 'package:sloth/src/rust/api.dart' as rust_api;
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_wn_api.dart';

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
  bool shouldFailGetAppSettings = false;
  bool shouldFailUpdateThemeMode = false;

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
    if (shouldFailGetAppSettings) {
      throw Exception('Failed to get app settings');
    }
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
    if (shouldFailUpdateThemeMode) {
      throw Exception('Failed to update theme mode');
    }
    currentThemeMode = (themeMode as _MockThemeMode).mode;
  }
}

void main() {
  late _MockApi mockApi;
  late ProviderContainer container;

  setUpAll(() {
    mockApi = _MockApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.currentThemeMode = 'system';
    mockApi.shouldFailGetAppSettings = false;
    mockApi.shouldFailUpdateThemeMode = false;
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('ThemeNotifier', () {
    test('initializes with theme from app settings', () async {
      mockApi.currentThemeMode = 'dark';

      final theme = await container.read(themeProvider.future);

      expect(theme, ThemeMode.dark);
    });

    test('returns system theme mode by default', () async {
      final theme = await container.read(themeProvider.future);

      expect(theme, ThemeMode.system);
    });

    test('setThemeMode updates to light theme', () async {
      await container.read(themeProvider.future);
      await container.read(themeProvider.notifier).setThemeMode(ThemeMode.light);

      expect(container.read(themeProvider).value, ThemeMode.light);
      expect(mockApi.currentThemeMode, 'light');
    });

    test('setThemeMode updates to dark theme', () async {
      await container.read(themeProvider.future);
      await container.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);

      expect(container.read(themeProvider).value, ThemeMode.dark);
      expect(mockApi.currentThemeMode, 'dark');
    });

    test('setThemeMode updates to system theme', () async {
      mockApi.currentThemeMode = 'light';
      await container.read(themeProvider.future);
      await container.read(themeProvider.notifier).setThemeMode(ThemeMode.system);

      expect(container.read(themeProvider).value, ThemeMode.system);
      expect(mockApi.currentThemeMode, 'system');
    });

    test('returns system theme when getAppSettings fails', () async {
      mockApi.shouldFailGetAppSettings = true;

      final theme = await container.read(themeProvider.future);

      expect(theme, ThemeMode.system);
    });

    test('setThemeMode updates state even when persist fails', () async {
      await container.read(themeProvider.future);
      mockApi.shouldFailUpdateThemeMode = true;

      await container.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);

      expect(container.read(themeProvider).value, ThemeMode.dark);
    });

    test('initializes with light theme from app settings', () async {
      mockApi.currentThemeMode = 'light';

      final theme = await container.read(themeProvider.future);

      expect(theme, ThemeMode.light);
    });

    test('handles unknown theme mode string by returning system', () async {
      mockApi.currentThemeMode = 'unknown';

      final theme = await container.read(themeProvider.future);

      expect(theme, ThemeMode.system);
    });
  });
}
