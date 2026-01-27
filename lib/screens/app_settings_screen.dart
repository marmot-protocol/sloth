import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/locale_provider.dart';
import 'package:sloth/providers/theme_provider.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_dropdown_selector.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final currentThemeMode = ref.watch(themeProvider).value ?? ThemeMode.system;
    final currentLocaleSetting = ref.watch(localeProvider).value ?? const SystemLocale();

    final themeOptions = [
      WnDropdownOption(value: ThemeMode.system, label: context.l10n.themeSystem),
      WnDropdownOption(value: ThemeMode.light, label: context.l10n.themeLight),
      WnDropdownOption(value: ThemeMode.dark, label: context.l10n.themeDark),
    ];

    final languageOptions = [
      WnDropdownOption<LocaleSetting>(
        value: const SystemLocale(),
        label: context.l10n.languageSystem,
      ),
      ...AppLocalizations.supportedLocales.map(
        (locale) => WnDropdownOption<LocaleSetting>(
          value: SpecificLocale(locale),
          label: getLanguageDisplayName(locale.languageCode),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlateContainer(
            child: Column(
              spacing: 24.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WnScreenHeader(title: context.l10n.appSettingsTitle),
                WnDropdownSelector<ThemeMode>(
                  label: context.l10n.theme,
                  options: themeOptions,
                  value: currentThemeMode,
                  onChanged: (mode) => ref.read(themeProvider.notifier).setThemeMode(mode),
                ),
                WnDropdownSelector<LocaleSetting>(
                  label: context.l10n.language,
                  options: languageOptions,
                  value: currentLocaleSetting,
                  onChanged: (setting) async {
                    try {
                      await ref.read(localeProvider.notifier).setLocale(setting);
                    } on LocalePersistenceException {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.l10n.languageUpdateFailed)),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
