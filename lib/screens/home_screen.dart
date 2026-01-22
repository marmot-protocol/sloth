import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useState;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:gap/gap.dart' show Gap;
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget, WidgetRef;
import 'package:sloth/providers/amber_provider.dart' show amberProvider;
import 'package:sloth/providers/auth_provider.dart' show authProvider;
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/services/amber_signer_service.dart' show AmberSignerException;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_filled_button.dart' show WnFilledButton;
import 'package:sloth/widgets/wn_outlined_button.dart' show WnOutlinedButton;
import 'package:sloth/widgets/wn_pixels_layer.dart' show WnPixelsLayer;
import 'package:sloth/widgets/wn_slate_container.dart' show WnSlateContainer;

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final amberState = ref.watch(amberProvider);
    final isAmberLoading = useState(false);
    final amberError = useState<String?>(null);

    Future<void> onAmberLogin() async {
      isAmberLoading.value = true;
      amberError.value = null;
      try {
        await ref.read(authProvider.notifier).loginWithAmber();
        if (context.mounted) {
          Routes.goToChatList(context);
        }
      } on AmberSignerException catch (e) {
        amberError.value = e.code == 'USER_REJECTED'
            ? 'Login cancelled'
            : 'Amber error: ${e.message}';
      } catch (e) {
        amberError.value = 'Unable to connect to Amber. Please try again.';
      } finally {
        isAmberLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          WnPixelsLayer(isAnimating: isAmberLoading.value),
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
                      // Show Amber login button if Amber is available
                      if (amberState.value?.isAvailable ?? false) ...[
                        WnFilledButton(
                          key: const Key('amber_login_button'),
                          text: 'Login with Amber',
                          onPressed: onAmberLogin,
                          loading: isAmberLoading.value,
                        ),
                        if (amberError.value != null) ...[
                          Gap(4.h),
                          Text(
                            amberError.value!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colors.backgroundContentTertiary,
                            ),
                          ),
                        ],
                        Gap(8.h),
                      ],
                      WnOutlinedButton(
                        text: 'Login',
                        onPressed: () {
                          Routes.pushToLogin(context);
                        },
                        disabled: isAmberLoading.value,
                      ),
                      Gap(8.h),
                      WnFilledButton(
                        text: 'Sign Up',
                        onPressed: () => Routes.pushToSignup(context),
                        disabled: isAmberLoading.value,
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
