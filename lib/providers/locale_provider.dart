import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:sloth/l10n/generated/app_localizations.dart';
import 'package:sloth/providers/auth_provider.dart' show secureStorageProvider;
import 'package:sloth/src/rust/api.dart' as rust_api;
import 'package:sloth/src/rust/api/utils.dart' as rust_utils;

final _logger = Logger('LocaleNotifier');
const _localePreferenceKey = 'locale_preference';
const _systemLocaleValue = 'system';

class LocalePersistenceException implements Exception {
  final String message;
  final Object? cause;
  LocalePersistenceException(this.message, [this.cause]);

  @override
  String toString() => 'LocalePersistenceException: $message';
}

sealed class LocaleSetting {
  const LocaleSetting();
}

class SystemLocale extends LocaleSetting {
  const SystemLocale();

  @override
  bool operator ==(Object other) => other is SystemLocale;

  @override
  int get hashCode => runtimeType.hashCode;
}

class SpecificLocale extends LocaleSetting {
  final Locale locale;
  const SpecificLocale(this.locale);

  @override
  bool operator ==(Object other) =>
      other is SpecificLocale && other.locale.languageCode == locale.languageCode;

  @override
  int get hashCode => locale.languageCode.hashCode;
}

class LocaleNotifier extends AsyncNotifier<LocaleSetting> {
  @override
  Future<LocaleSetting> build() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final storedPreference = await storage.read(key: _localePreferenceKey);

      if (storedPreference == null || storedPreference == _systemLocaleValue) {
        return const SystemLocale();
      }

      final isSupported = AppLocalizations.supportedLocales.any(
        (l) => l.languageCode == storedPreference,
      );
      if (isSupported) {
        return SpecificLocale(Locale(storedPreference));
      }

      _logger.warning('Stored locale "$storedPreference" not supported, using system default');
      return const SystemLocale();
    } catch (e) {
      _logger.warning('Failed to load locale settings, using system default: $e');
      return const SystemLocale();
    }
  }

  Future<void> setLocale(LocaleSetting setting) async {
    final previousState = state.value;
    try {
      final storage = ref.read(secureStorageProvider);

      final preferenceValue = switch (setting) {
        SystemLocale() => _systemLocaleValue,
        SpecificLocale(locale: final locale) => locale.languageCode,
      };
      await storage.write(key: _localePreferenceKey, value: preferenceValue);

      final rustLanguage = _settingToRustLanguage(setting);
      await rust_api.updateLanguage(language: rustLanguage);

      state = AsyncData(setting);
      _logger.info('Locale setting updated to: $setting');
    } catch (e) {
      _logger.warning('Failed to persist locale settings: $e');
      if (previousState != null) {
        state = AsyncData(previousState);
      }
      throw LocalePersistenceException('Failed to save language preference', e);
    }
  }

  Locale resolveLocale() {
    final currentState = state.value ?? const SystemLocale();
    return switch (currentState) {
      SystemLocale() => _resolveSystemLocale(),
      SpecificLocale(locale: final locale) => locale,
    };
  }

  Locale _resolveSystemLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    final isSupported = AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == deviceLocale.languageCode,
    );
    if (isSupported) {
      return Locale(deviceLocale.languageCode);
    }
    return const Locale('en');
  }

  rust_api.Language _settingToRustLanguage(LocaleSetting setting) {
    final languageCode = switch (setting) {
      SystemLocale() => _resolveSystemLanguageCode(),
      SpecificLocale(locale: final locale) => locale.languageCode,
    };
    return _languageCodeToRust(languageCode);
  }

  rust_api.Language _languageCodeToRust(String code) {
    return switch (code) {
      'en' => rust_utils.languageEnglish(),
      'es' => rust_utils.languageSpanish(),
      'fr' => rust_utils.languageFrench(),
      'de' => rust_utils.languageGerman(),
      'it' => rust_utils.languageItalian(),
      'pt' => rust_utils.languagePortuguese(),
      'ru' => rust_utils.languageRussian(),
      'tr' => rust_utils.languageTurkish(),
      _ => rust_utils.languageEnglish(),
    };
  }
}

final localeProvider = AsyncNotifierProvider<LocaleNotifier, LocaleSetting>(LocaleNotifier.new);

String getLanguageDisplayName(String languageCode) {
  return switch (languageCode) {
    'de' => 'Deutsch',
    'en' => 'English',
    'es' => 'Español',
    'fr' => 'Français',
    'it' => 'Italiano',
    'pt' => 'Português',
    'ru' => 'Русский',
    'tr' => 'Türkçe',
    _ => languageCode,
  };
}

class LocaleFormatters {
  final String _localeCode;

  LocaleFormatters(this._localeCode);

  String formatDateShort(DateTime date) {
    return DateFormat.yMd(_localeCode).format(date);
  }

  String formatDateMedium(DateTime date) {
    return DateFormat.yMMMd(_localeCode).format(date);
  }

  String formatDateLong(DateTime date) {
    return DateFormat.yMMMMd(_localeCode).format(date);
  }

  String formatTime(DateTime time) {
    return DateFormat.jm(_localeCode).format(time);
  }

  String formatDateTime(DateTime dateTime) {
    return '${formatDateMedium(dateTime)} ${formatTime(dateTime)}';
  }

  String formatRelativeTime(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return l10n.timeJustNow;
    } else if (difference.inMinutes < 60) {
      return l10n.timeMinutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.timeHoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.timeDaysAgo(difference.inDays);
    } else {
      return formatDateMedium(dateTime);
    }
  }

  String formatNumber(num number) {
    return NumberFormat.decimalPattern(_localeCode).format(number);
  }

  String formatCurrency(num amount, {String? symbol}) {
    final format = NumberFormat.currency(
      locale: _localeCode,
      symbol: symbol ?? '',
      decimalDigits: 2,
    );
    return format.format(amount).trim();
  }

  String formatCompact(num number) {
    return NumberFormat.compact(locale: _localeCode).format(number);
  }

  String formatPercent(double value) {
    return NumberFormat.percentPattern(_localeCode).format(value);
  }
}

final localeFormattersProvider = Provider<LocaleFormatters>((ref) {
  final localeSetting = ref.watch(localeProvider).value ?? const SystemLocale();
  final localeCode = switch (localeSetting) {
    SystemLocale() => _resolveSystemLanguageCode(),
    SpecificLocale(locale: final locale) => locale.languageCode,
  };
  return LocaleFormatters(localeCode);
});

String _resolveSystemLanguageCode() {
  final deviceLocale = PlatformDispatcher.instance.locale;
  final isSupported = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == deviceLocale.languageCode,
  );
  return isSupported ? deviceLocale.languageCode : 'en';
}
