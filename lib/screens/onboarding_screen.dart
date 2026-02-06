import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:whitenoise/l10n/l10n.dart';
import 'package:whitenoise/routes.dart';
import 'package:whitenoise/theme.dart';

import 'package:whitenoise/widgets/wn_button.dart';
import 'package:whitenoise/widgets/wn_slate.dart';
import 'package:whitenoise/widgets/wn_slate_navigation_header.dart';

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
              const Spacer(),
              WnSlate(
                header: WnSlateNavigationHeader(
                  title: context.l10n.profileReady,
                  onNavigate: () => Routes.goToChatList(context),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8.h,
                    children: [
                      Text(
                        context.l10n.startConversationHint,
                        style: context.typographyScaled.medium14.copyWith(
                          color: colors.backgroundContentTertiary,
                        ),
                      ),
                      WnButton(
                        text: context.l10n.shareYourProfile,
                        type: WnButtonType.outline,
                        onPressed: () {
                          Routes.pushToShareProfile(context);
                        },
                        size: WnButtonSize.medium,
                      ),
                      WnButton(
                        text: context.l10n.startChat,
                        onPressed: () {
                          Routes.pushToUserSearch(context);
                        },
                        size: WnButtonSize.medium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
