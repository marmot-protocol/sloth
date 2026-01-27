import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlateContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WnScreenHeader(title: context.l10n.privacyAndSecurity),
                Gap(12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.deleteAllAppData,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: colors.backgroundContentSecondary,
                        ),
                      ),
                      Gap(8.h),
                      SizedBox(
                        width: double.infinity,
                        child: WnButton(
                          key: const Key('delete_app_data_button'),
                          text: context.l10n.deleteAppData,
                          type: WnButtonType.destructive,
                          size: WnButtonSize.medium,
                          trailingIcon: WnIcons.trashCan,
                          onPressed: () => Routes.pushToDeleteAllDataConfirmation(context),
                        ),
                      ),
                      Gap(4.h),
                      Text(
                        context.l10n.deleteAllAppDataDescription,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                          color: colors.backgroundContentSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
