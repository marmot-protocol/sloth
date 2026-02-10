import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:gap/gap.dart' show Gap;
import 'package:whitenoise/l10n/l10n.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_auth_buttons_container.dart' show WnAuthButtonsContainer;
import 'package:whitenoise/widgets/wn_slate.dart' show WnSlate;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typographyScaled;
    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Gap(60.h),
                          SvgPicture.asset(
                            'assets/svgs/whitenoise.svg',
                            colorFilter: ColorFilter.mode(
                              colors.backgroundContentPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                          Gap(16.h),
                          Text(
                            context.l10n.appTitle,
                            textAlign: TextAlign.center,
                            style: typography.bold48.copyWith(
                              color: colors.backgroundContentPrimary,
                            ),
                          ),
                          Text(
                            context.l10n.tagline1,
                            textAlign: TextAlign.center,
                            style: typography.semiBold18.copyWith(
                              color: colors.backgroundContentTertiary,
                            ),
                          ),
                          Text(
                            context.l10n.tagline2,
                            textAlign: TextAlign.center,
                            style: typography.semiBold18.copyWith(
                              color: colors.backgroundContentTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                WnSlate(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
                    child: const WnAuthButtonsContainer(),
                  ),
                ),
                Gap(44.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
