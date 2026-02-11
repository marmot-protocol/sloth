import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:whitenoise/hooks/use_delete_all_data.dart';
import 'package:whitenoise/hooks/use_system_notice.dart';
import 'package:whitenoise/l10n/l10n.dart';
import 'package:whitenoise/providers/auth_provider.dart';
import 'package:whitenoise/providers/locale_provider.dart';
import 'package:whitenoise/providers/theme_provider.dart';
import 'package:whitenoise/routes.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_button.dart';
import 'package:whitenoise/widgets/wn_confirmation_bottom_sheet.dart';
import 'package:whitenoise/widgets/wn_dropdown_selector.dart';
import 'package:whitenoise/widgets/wn_icon.dart';
import 'package:whitenoise/widgets/wn_slate.dart';
import 'package:whitenoise/widgets/wn_slate_navigation_header.dart';
import 'package:whitenoise/widgets/wn_system_notice.dart';

class AppSettingsScreen extends HookConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final currentThemeMode = ref.watch(themeProvider).value ?? ThemeMode.system;
    final currentLocaleSetting = ref.watch(localeProvider).value ?? const SystemLocale();
    final (:state, :deleteAllData) = useDeleteAllData();
    final systemNotice = useSystemNotice();

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

    Future<void> handleDeleteAllData() async {
      final confirmed = await WnConfirmationBottomSheet.show(
        context: context,
        title: context.l10n.deleteAllDataConfirmation,
        message: context.l10n.deleteAllDataWarning,
        confirmText: context.l10n.delete,
        isDestructive: true,
      );

      if (confirmed == true) {
        try {
          await deleteAllData();
          if (!context.mounted) return;

          await ref.read(authProvider.notifier).resetAuth();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Routes.goToHome(context);
            }
          });
        } catch (e) {
          if (!context.mounted) return;
          systemNotice.showErrorNotice('Failed to delete all data. Please try again.');
        }
      }
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlate(
            header: WnSlateNavigationHeader(
              title: context.l10n.appSettingsTitle,
              type: WnSlateNavigationType.back,
              onNavigate: () => Routes.goBack(context),
            ),
            systemNotice: systemNotice.noticeMessage != null
                ? WnSystemNotice(
                    key: ValueKey(systemNotice.noticeMessage),
                    title: systemNotice.noticeMessage!,
                    type: systemNotice.noticeType,
                    variant: WnSystemNoticeVariant.dismissible,
                    onDismiss: systemNotice.dismissNotice,
                  )
                : null,
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Column(
                spacing: 24.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    onChanged: (setting) => ref.read(localeProvider.notifier).setLocale(setting),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: WnButton(
                      key: const Key('delete_all_data_button'),
                      text: context.l10n.deleteAllData,
                      onPressed: handleDeleteAllData,
                      type: WnButtonType.destructive,
                      size: WnButtonSize.medium,
                      loading: state.isDeleting,
                      disabled: state.isDeleting,
                      trailingIcon: WnIcons.trashCan,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
