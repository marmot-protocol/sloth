import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_account_bar.dart';
import 'package:sloth/widgets/wn_filled_button.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_outlined_button.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: GestureDetector(
        key: const Key('onboarding_background'),
        onTap: () => Routes.goToChatList(context),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.w),
                child: const WnAccountBar(),
              ),
              const Spacer(),
              WnSlateContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8.h,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            context.l10n.profileReady,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: colors.backgroundContentPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          key: const Key('close_button'),
                          onPressed: () => Routes.goToChatList(context),
                          icon: WnIcon(
                            WnIcons.closeLarge,
                            size: 20.w,
                            color: colors.backgroundContentTertiary,
                          ),
                        ),
                      ],
                    ),
                    Gap(8.h),
                    Text(
                      context.l10n.startConversationHint,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: colors.backgroundContentTertiary,
                      ),
                    ),
                    Gap(8.h),
                    WnOutlinedButton(
                      text: context.l10n.shareYourProfile,
                      onPressed: () {
                        Routes.pushToWip(context);
                      },
                    ),
                    WnFilledButton(
                      text: context.l10n.startChat,
                      onPressed: () {
                        Routes.pushToWip(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
