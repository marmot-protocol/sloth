import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sloth/l10n/generated/app_localizations_en.dart';
import 'package:sloth/providers/auth_provider.dart' show secureStorageProvider;
import 'package:sloth/providers/locale_provider.dart';
import 'package:sloth/src/rust/api.dart' as rust_api;
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';

class _MockApi extends MockWnApi {
  bool shouldFailGetAppSettings = false;

  @override
  Future<rust_api.AppSettings> crateApiGetAppSettings() async {
    if (shouldFailGetAppSettings) {
      throw Exception('Failed to get app settings');
    }
    return MockAppSettings();
  }

  @override
  Future<void> crateApiUpdateLanguage({
    required rust_api.Language language,
  }) async {
    if (shouldFailUpdateLanguage) {
      throw Exception('Failed to update language');
    }
    await super.crateApiUpdateLanguage(language: language);
  }
}

void main() {
  late _MockApi mockApi;
  late MockSecureStorage mockStorage;
  late ProviderContainer container;

  setUpAll(() {
    mockApi = _MockApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.reset();
    mockApi.shouldFailGetAppSettings = false;
    mockApi.shouldFailUpdateLanguage = false;
    mockStorage = MockSecureStorage();
    container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(mockStorage),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('LocaleNotifier', () {
    test('initializes with language from secure storage', () async {
      await mockStorage.write(key: 'locale_preference', value: 'de');

      final localeSetting = await container.read(localeProvider.future);

      expect(localeSetting, isA<SpecificLocale>());
      expect((localeSetting as SpecificLocale).locale.languageCode, 'de');
    });

    test('returns SystemLocale by default when no preference stored', () async {
      final localeSetting = await container.read(localeProvider.future);

      expect(localeSetting, isA<SystemLocale>());
    });

    test('setLocale updates to Spanish', () async {
      await container.read(localeProvider.future);
      await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('es')));

      final current = container.read(localeProvider).value;
      expect(current, isA<SpecificLocale>());
      expect((current as SpecificLocale).locale.languageCode, 'es');
      expect(mockApi.currentLanguage, 'es');
    });

    test('setLocale updates to German', () async {
      await container.read(localeProvider.future);
      await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('de')));

      final current = container.read(localeProvider).value;
      expect(current, isA<SpecificLocale>());
      expect((current as SpecificLocale).locale.languageCode, 'de');
      expect(mockApi.currentLanguage, 'de');
    });

    test('setLocale updates to French', () async {
      await container.read(localeProvider.future);
      await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('fr')));

      final current = container.read(localeProvider).value;
      expect(current, isA<SpecificLocale>());
      expect((current as SpecificLocale).locale.languageCode, 'fr');
      expect(mockApi.currentLanguage, 'fr');
    });

    test('setLocale updates to Italian', () async {
      await container.read(localeProvider.future);
      await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('it')));

      final current = container.read(localeProvider).value;
      expect(current, isA<SpecificLocale>());
      expect((current as SpecificLocale).locale.languageCode, 'it');
      expect(mockApi.currentLanguage, 'it');
    });

    test('setLocale updates to Portuguese', () async {
      await container.read(localeProvider.future);
      await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('pt')));

      final current = container.read(localeProvider).value;
      expect(current, isA<SpecificLocale>());
      expect((current as SpecificLocale).locale.languageCode, 'pt');
      expect(mockApi.currentLanguage, 'pt');
    });

    test('setLocale updates to Russian', () async {
      await container.read(localeProvider.future);
      await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('ru')));

      final current = container.read(localeProvider).value;
      expect(current, isA<SpecificLocale>());
      expect((current as SpecificLocale).locale.languageCode, 'ru');
      expect(mockApi.currentLanguage, 'ru');
    });

    test('setLocale updates to Turkish', () async {
      await container.read(localeProvider.future);
      await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('tr')));

      final current = container.read(localeProvider).value;
      expect(current, isA<SpecificLocale>());
      expect((current as SpecificLocale).locale.languageCode, 'tr');
      expect(mockApi.currentLanguage, 'tr');
    });

    test('setLocale can switch back to English', () async {
      await mockStorage.write(key: 'locale_preference', value: 'de');
      await container.read(localeProvider.future);
      await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('en')));

      final current = container.read(localeProvider).value;
      expect(current, isA<SpecificLocale>());
      expect((current as SpecificLocale).locale.languageCode, 'en');
      expect(mockApi.currentLanguage, 'en');
    });

    test('returns SystemLocale when stored value is "system"', () async {
      await mockStorage.write(key: 'locale_preference', value: 'system');

      final localeSetting = await container.read(localeProvider.future);

      expect(localeSetting, isA<SystemLocale>());
    });

    test('returns SystemLocale when stored locale is not supported', () async {
      await mockStorage.write(key: 'locale_preference', value: 'xx');

      final localeSetting = await container.read(localeProvider.future);

      expect(localeSetting, isA<SystemLocale>());
    });

    test('returns SystemLocale when storage read fails', () async {
      mockStorage.shouldThrowOnRead = true;

      final localeSetting = await container.read(localeProvider.future);

      expect(localeSetting, isA<SystemLocale>());
    });

    test('setLocale throws LocalePersistenceException when persist fails', () async {
      await container.read(localeProvider.future);
      mockApi.shouldFailUpdateLanguage = true;

      await expectLater(
        container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('fr'))),
        throwsA(isA<LocalePersistenceException>()),
      );
    });

    test('setLocale reverts state when persist fails', () async {
      await mockStorage.write(key: 'locale_preference', value: 'en');
      await container.read(localeProvider.future);
      final initialState = container.read(localeProvider).value;
      expect((initialState as SpecificLocale).locale.languageCode, 'en');

      mockApi.shouldFailUpdateLanguage = true;

      try {
        await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('fr')));
      } on LocalePersistenceException catch (_) {}

      final current = container.read(localeProvider).value;
      expect(current, isA<SpecificLocale>());
      expect((current as SpecificLocale).locale.languageCode, 'en');
    });

    test('setLocale reverts storage when rust API fails', () async {
      await mockStorage.write(key: 'locale_preference', value: 'en');
      await container.read(localeProvider.future);

      mockApi.shouldFailUpdateLanguage = true;

      try {
        await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('fr')));
      } on LocalePersistenceException catch (_) {}

      final storedValue = await mockStorage.read(key: 'locale_preference');
      expect(storedValue, 'en');
    });

    test('setLocale deletes storage when rust API fails and no previous preference', () async {
      await container.read(localeProvider.future);
      expect(await mockStorage.read(key: 'locale_preference'), isNull);

      mockApi.shouldFailUpdateLanguage = true;

      try {
        await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('fr')));
      } on LocalePersistenceException catch (_) {}

      final storedValue = await mockStorage.read(key: 'locale_preference');
      expect(storedValue, isNull);
    });

    test('setLocale reverts both state and storage atomically on failure', () async {
      await mockStorage.write(key: 'locale_preference', value: 'de');
      await container.read(localeProvider.future);

      mockApi.shouldFailUpdateLanguage = true;

      try {
        await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('es')));
      } on LocalePersistenceException catch (_) {}

      final current = container.read(localeProvider).value;
      expect((current as SpecificLocale).locale.languageCode, 'de');
      final storedValue = await mockStorage.read(key: 'locale_preference');
      expect(storedValue, 'de');
    });

    test('setLocale to SystemLocale works', () async {
      await mockStorage.write(key: 'locale_preference', value: 'de');
      await container.read(localeProvider.future);
      await container.read(localeProvider.notifier).setLocale(const SystemLocale());

      final current = container.read(localeProvider).value;
      expect(current, isA<SystemLocale>());
      final storedValue = await mockStorage.read(key: 'locale_preference');
      expect(storedValue, 'system');
    });

    test('resolveLocale returns English for SpecificLocale(en)', () async {
      await container.read(localeProvider.future);
      await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('en')));

      final resolved = container.read(localeProvider.notifier).resolveLocale();

      expect(resolved.languageCode, 'en');
    });

    test('resolveLocale returns German for SpecificLocale(de)', () async {
      await container.read(localeProvider.future);
      await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('de')));

      final resolved = container.read(localeProvider.notifier).resolveLocale();

      expect(resolved.languageCode, 'de');
    });

    test('can switch languages multiple times', () async {
      await container.read(localeProvider.future);

      await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('es')));
      expect(mockApi.currentLanguage, 'es');

      await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('fr')));
      expect(mockApi.currentLanguage, 'fr');

      await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('ru')));
      expect(mockApi.currentLanguage, 'ru');

      await container.read(localeProvider.notifier).setLocale(const SpecificLocale(Locale('en')));
      expect(mockApi.currentLanguage, 'en');
    });
  });

  group('LocaleSetting equality', () {
    test('SystemLocale instances are equal', () {
      const locale1 = SystemLocale();
      const locale2 = SystemLocale();

      expect(locale1, equals(locale2));
      expect(locale1.hashCode, equals(locale2.hashCode));
    });

    test('SpecificLocale instances with same language code are equal', () {
      const locale1 = SpecificLocale(Locale('en'));
      const locale2 = SpecificLocale(Locale('en'));

      expect(locale1, equals(locale2));
      expect(locale1.hashCode, equals(locale2.hashCode));
    });

    test('SpecificLocale instances with different language codes are not equal', () {
      const locale1 = SpecificLocale(Locale('en'));
      const locale2 = SpecificLocale(Locale('de'));

      expect(locale1, isNot(equals(locale2)));
    });

    test('SystemLocale and SpecificLocale are not equal', () {
      const systemLocale = SystemLocale();
      const specificLocale = SpecificLocale(Locale('en'));

      expect(systemLocale, isNot(equals(specificLocale)));
    });
  });

  group('getLanguageDisplayName', () {
    test('returns correct display name for English', () {
      expect(getLanguageDisplayName('en'), 'English');
    });

    test('returns correct display name for Spanish', () {
      expect(getLanguageDisplayName('es'), 'Español');
    });

    test('returns correct display name for German', () {
      expect(getLanguageDisplayName('de'), 'Deutsch');
    });

    test('returns correct display name for French', () {
      expect(getLanguageDisplayName('fr'), 'Français');
    });

    test('returns correct display name for Italian', () {
      expect(getLanguageDisplayName('it'), 'Italiano');
    });

    test('returns correct display name for Portuguese', () {
      expect(getLanguageDisplayName('pt'), 'Português');
    });

    test('returns correct display name for Russian', () {
      expect(getLanguageDisplayName('ru'), 'Русский');
    });

    test('returns correct display name for Turkish', () {
      expect(getLanguageDisplayName('tr'), 'Türkçe');
    });

    test('returns language code for unknown languages', () {
      expect(getLanguageDisplayName('xx'), 'xx');
    });
  });

  group('LocaleFormatters', () {
    setUpAll(() async {
      await initializeDateFormatting('en');
      await initializeDateFormatting('de');
    });

    test('formatNumber uses locale-appropriate grouping for English', () {
      final formatters = LocaleFormatters('en');
      expect(formatters.formatNumber(1234567), '1,234,567');
    });

    test('formatNumber uses locale-appropriate grouping for German', () {
      final formatters = LocaleFormatters('de');
      expect(formatters.formatNumber(1234567), '1.234.567');
    });

    test('formatDateShort formats correctly for English', () {
      final formatters = LocaleFormatters('en');
      final date = DateTime(2026, 1, 25);
      final formatted = formatters.formatDateShort(date);

      expect(formatted, contains('1'));
      expect(formatted, contains('25'));
      expect(formatted, contains('26'));
    });

    test('formatDateShort formats correctly for German', () {
      final formatters = LocaleFormatters('de');
      final date = DateTime(2026, 1, 25);
      final formatted = formatters.formatDateShort(date);

      expect(formatted, contains('25'));
      expect(formatted, contains('.'));
    });

    test('formatDateMedium produces readable format', () {
      final formatters = LocaleFormatters('en');
      final date = DateTime(2026, 1, 25);
      final formatted = formatters.formatDateMedium(date);
      expect(formatted, contains('Jan'));
      expect(formatted, contains('25'));
      expect(formatted, contains('2026'));
    });

    test('formatTime produces time string', () {
      final formatters = LocaleFormatters('en');
      final time = DateTime(2026, 1, 25, 14, 30);
      final formatted = formatters.formatTime(time);

      expect(formatted.isNotEmpty, isTrue);
    });

    test('formatCurrency formats with symbol', () {
      final formatters = LocaleFormatters('en');
      final formatted = formatters.formatCurrency(1234.56, symbol: r'$');
      expect(formatted, contains('1'));
      expect(formatted, contains(r'$'));
    });

    test('formatCompact produces compact numbers', () {
      final formatters = LocaleFormatters('en');
      expect(formatters.formatCompact(1500), contains('K'));
      expect(formatters.formatCompact(2500000), contains('M'));
    });

    test('formatPercent formats as percentage', () {
      final formatters = LocaleFormatters('en');
      final formatted = formatters.formatPercent(0.85);
      expect(formatted, contains('85'));
      expect(formatted, contains('%'));
    });

    test('formatRelativeTime returns "just now" for recent times', () {
      final formatters = LocaleFormatters('en');
      final l10n = AppLocalizationsEn();
      final now = DateTime.now();
      expect(formatters.formatRelativeTime(now, l10n), 'just now');
    });

    test('formatRelativeTime returns minutes ago', () {
      final formatters = LocaleFormatters('en');
      final l10n = AppLocalizationsEn();
      final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
      expect(formatters.formatRelativeTime(fiveMinutesAgo, l10n), '5 minutes ago');
    });

    test('formatRelativeTime returns hours ago', () {
      final formatters = LocaleFormatters('en');
      final l10n = AppLocalizationsEn();
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
      expect(formatters.formatRelativeTime(twoHoursAgo, l10n), '2 hours ago');
    });

    test('formatRelativeTime returns days ago', () {
      final formatters = LocaleFormatters('en');
      final l10n = AppLocalizationsEn();
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      expect(formatters.formatRelativeTime(threeDaysAgo, l10n), '3 days ago');
    });

    test('formatRelativeTime falls back to date for older times', () {
      final formatters = LocaleFormatters('en');
      final l10n = AppLocalizationsEn();
      final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
      final formatted = formatters.formatRelativeTime(twoWeeksAgo, l10n);

      expect(formatted, isNot(contains('ago')));
    });

    test('formatDateLong produces full date format', () {
      final formatters = LocaleFormatters('en');
      final date = DateTime(2026, 1, 25);
      final formatted = formatters.formatDateLong(date);
      expect(formatted, contains('January'));
      expect(formatted, contains('25'));
      expect(formatted, contains('2026'));
    });

    test('formatDateTime produces date and time together', () {
      final formatters = LocaleFormatters('en');
      final dateTime = DateTime(2026, 1, 25, 14, 30);
      final formatted = formatters.formatDateTime(dateTime);
      expect(formatted, contains('Jan'));
      expect(formatted, contains('25'));
      expect(formatted, contains('2026'));
    });
  });

  group('LocalePersistenceException', () {
    test('toString returns formatted message', () {
      final exception = LocalePersistenceException('test error');
      expect(exception.toString(), 'LocalePersistenceException: test error');
    });

    test('toString includes cause when provided', () {
      final cause = Exception('root cause');
      final exception = LocalePersistenceException('test error', cause);
      expect(exception.toString(), 'LocalePersistenceException: test error');
      expect(exception.cause, cause);
    });
  });

  group('localeFormattersProvider', () {
    test('uses specific locale when set', () async {
      await mockStorage.write(key: 'locale_preference', value: 'de');
      await container.read(localeProvider.future);

      final formatters = container.read(localeFormattersProvider);
      expect(formatters.formatNumber(1234567), '1.234.567');
    });
  });
}
