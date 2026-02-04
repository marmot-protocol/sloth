import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.title, required this.description});
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typographyScaled;
    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlate(
            header: WnSlateNavigationHeader(
              title: title,
              onNavigate: () => Routes.goBack(context),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Column(
                spacing: 8.h,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '🦥',
                    style: typography.semiBold60.copyWith(
                      color: colors.backgroundContentPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    context.l10n.ohNo,
                    style: typography.semiBold16.copyWith(
                      color: colors.backgroundContentPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    description,
                    style: typography.medium14.copyWith(
                      color: colors.backgroundContentTertiary,
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
        ),
      ),
    );
  }
}
