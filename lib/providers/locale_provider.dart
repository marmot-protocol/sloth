import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:sloth/l10n/generated/app_localizations.dart';
import 'package:sloth/src/rust/api.dart' as rust_api;
import 'package:sloth/src/rust/api/utils.dart' as rust_utils;

final _logger = Logger('LocaleNotifier');

/// Exception thrown when locale persistence fails
class LocalePersistenceException implements Exception {
  final String message;
  final Object? cause;
  LocalePersistenceException(this.message, [this.cause]);

  @override
  String toString() => 'LocalePersistenceException: $message';
}

/// Represents the locale setting - either system default or a specific locale
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
      final appSettings = await rust_api.getAppSettings();
      final rustLanguage = await rust_api.appSettingsLanguage(appSettings: appSettings);
      final languageCode = rust_utils.languageToString(language: rustLanguage);
      return SpecificLocale(Locale(languageCode));
    } catch (e) {
      _logger.warning('Failed to load locale settings, using system default: $e');
      return const SystemLocale();
    }
  }

  /// Updates the locale setting.
  ///
  /// Persists the setting first, then updates UI state on success.
  /// Throws [LocalePersistenceException] if persistence fails.
  Future<void> setLocale(LocaleSetting setting) async {
    final previousState = state.value;
    try {
      final rustLanguage = _settingToRustLanguage(setting);
      await rust_api.updateLanguage(language: rustLanguage);
      state = AsyncData(setting);
      _logger.info('Locale setting updated to: $setting');
    } catch (e) {
      _logger.warning('Failed to persist locale settings: $e');
      // Ensure state remains unchanged on failure
      if (previousState != null) {
        state = AsyncData(previousState);
      }
      throw LocalePersistenceException('Failed to save language preference', e);
    }
  }

  /// Resolves the actual locale to use based on the current setting.
  /// If system locale, uses device locale (falling back to English if unsupported).
  /// If specific locale, uses that locale directly.
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

  String _resolveSystemLanguageCode() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    final isSupported = AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == deviceLocale.languageCode,
    );
    return isSupported ? deviceLocale.languageCode : 'en';
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

/// Helper to get the display name for a locale
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

/// Locale-aware formatting utilities
class LocaleFormatters {
  final String _localeCode;

  LocaleFormatters(this._localeCode);

  /// Formats a date in short format (e.g., "1/25/26" or "25.01.26")
  String formatDateShort(DateTime date) {
    return DateFormat.yMd(_localeCode).format(date);
  }

  /// Formats a date in medium format (e.g., "Jan 25, 2026" or "25 janv. 2026")
  String formatDateMedium(DateTime date) {
    return DateFormat.yMMMd(_localeCode).format(date);
  }

  /// Formats a date in long format (e.g., "January 25, 2026")
  String formatDateLong(DateTime date) {
    return DateFormat.yMMMMd(_localeCode).format(date);
  }

  /// Formats time (e.g., "9:30 AM" or "09:30")
  String formatTime(DateTime time) {
    return DateFormat.jm(_localeCode).format(time);
  }

  /// Formats date and time together
  String formatDateTime(DateTime dateTime) {
    return '${formatDateMedium(dateTime)} ${formatTime(dateTime)}';
  }

  /// Formats a relative time (e.g., "2 hours ago", "yesterday")
  /// Requires AppLocalizations for proper localized strings.
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

  /// Formats a number with locale-appropriate grouping (e.g., "1,234" or "1.234")
  String formatNumber(num number) {
    return NumberFormat.decimalPattern(_localeCode).format(number);
  }

  /// Formats a number as currency
  String formatCurrency(num amount, {String? symbol}) {
    final format = NumberFormat.currency(
      locale: _localeCode,
      symbol: symbol ?? '',
      decimalDigits: 2,
    );
    return format.format(amount).trim();
  }

  /// Formats a number as a compact representation (e.g., "1.2K", "3.4M")
  String formatCompact(num number) {
    return NumberFormat.compact(locale: _localeCode).format(number);
  }

  /// Formats a percentage (e.g., "85%" or "85 %")
  String formatPercent(double value) {
    return NumberFormat.percentPattern(_localeCode).format(value);
  }
}

/// Provider for locale-aware formatters
final localeFormattersProvider = Provider<LocaleFormatters>((ref) {
  final localeSetting = ref.watch(localeProvider).value ?? const SystemLocale();
  final localeCode = switch (localeSetting) {
    SystemLocale() => PlatformDispatcher.instance.locale.languageCode,
    SpecificLocale(locale: final locale) => locale.languageCode,
  };
  return LocaleFormatters(localeCode);
});
