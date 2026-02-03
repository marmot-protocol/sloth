import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:whitenoise/l10n/l10n.dart';
import 'package:whitenoise/routes.dart' show Routes;
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_button.dart';
import 'package:whitenoise/widgets/wn_slate.dart';
import 'package:whitenoise/widgets/wn_slate_navigation_header.dart';

class WipScreen extends StatelessWidget {
  const WipScreen({super.key});

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
              title: context.l10n.workInProgress,
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
                    context.l10n.wipMessage,
                    style: typography.medium14.copyWith(
                      color: colors.backgroundContentTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(4.h),
                  WnButton(
                    text: context.l10n.donate,
                    onPressed: () {
                      Routes.pushToDonate(context);
                    },
                  ),
                  WnButton(
                    text: context.l10n.goBack,
                    type: WnButtonType.outline,
                    onPressed: () {
                      Routes.goBack(context);
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
