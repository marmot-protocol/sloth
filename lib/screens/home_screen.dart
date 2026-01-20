import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:gap/gap.dart' show Gap;
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_filled_button.dart' show WnFilledButton;
import 'package:sloth/widgets/wn_outlined_button.dart' show WnOutlinedButton;
import 'package:sloth/widgets/wn_pixels_layer.dart' show WnPixelsLayer;
import 'package:sloth/widgets/wn_slate_container.dart' show WnSlateContainer;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WnPixelsLayer(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
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
                          'White Noise',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 48.sp,
                            letterSpacing: -0.6.sp,
                            color: context.colors.backgroundContentPrimary,
                          ),
                        ),
                        Text(
                          'Decentralized. Uncensorable.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp,
                            letterSpacing: 0.1.sp,
                            color: context.colors.backgroundContentTertiary,
                          ),
                        ),
                        Text(
                          'Secure Messaging.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp,
                            letterSpacing: 0.1.sp,
                            color: context.colors.backgroundContentTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                WnSlateContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WnOutlinedButton(
                        text: 'Login',
                        onPressed: () {
                          Routes.pushToLogin(context);
                        },
                      ),
                      Gap(8.h),
                      WnFilledButton(
                        text: 'Sign Up',
                        onPressed: () => Routes.pushToSignup(context),
                      ),
                    ],
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
