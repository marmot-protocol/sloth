import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_screen_header.dart' show WnScreenHeader;
import 'package:sloth/widgets/wn_slate_container.dart' show WnSlateContainer;

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.title, required this.description});
  final String title;
  final String description;

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
              spacing: 16.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WnScreenHeader(title: title),
                Expanded(
                  child: Center(
                    child: Column(
                      spacing: 8.h,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '🦥',
                          style: TextStyle(
                            color: colors.backgroundContentPrimary,
                            fontSize: 56.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          context.l10n.ohNo,
                          style: TextStyle(
                            color: colors.backgroundContentPrimary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          description,
                          style: TextStyle(
                            color: colors.backgroundContentTertiary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(4.h),
                        WnButton(
                          text: context.l10n.goBack,
                          onPressed: () {
                            Routes.goBack(context);
                          },
                        ),
                        WnButton(
                          text: context.l10n.reportError,
                          type: WnButtonType.outline,
                          onPressed: () {
                            Routes.pushToWip(context);
                          },
                        ),
                      ],
                    ),
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
