import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/providers/theme_provider.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_dropdown_selector.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  static const _themeOptions = [
    WnDropdownOption(value: ThemeMode.system, label: 'System'),
    WnDropdownOption(value: ThemeMode.light, label: 'Light'),
    WnDropdownOption(value: ThemeMode.dark, label: 'Dark'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final currentThemeMode = ref.watch(themeProvider).value ?? ThemeMode.system;

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
                const WnScreenHeader(title: 'App Settings'),
                WnDropdownSelector<ThemeMode>(
                  label: 'Theme',
                  options: _themeOptions,
                  value: currentThemeMode,
                  onChanged: (mode) => ref.read(themeProvider.notifier).setThemeMode(mode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
