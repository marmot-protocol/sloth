import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget, WidgetRef;
import 'package:sloth/hooks/use_login.dart' show useLogin;
import 'package:sloth/providers/auth_provider.dart' show authProvider;
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_filled_button.dart' show WnFilledButton;
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_pixels_layer.dart' show WnPixelsLayer;
import 'package:sloth/widgets/wn_slate_container.dart' show WnSlateContainer;
import 'package:sloth/widgets/wn_text_form_field.dart' show WnTextFormField;

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final (:controller, :state, :paste, :submit, :clearError) = useLogin(
      (nsec) => ref.read(authProvider.notifier).login(nsec),
    );

    Future<void> onSubmit() async {
      final success = await submit();
      if (success && context.mounted) {
        Routes.goToChatList(context);
      }
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          WnPixelsLayer(isAnimating: state.isLoading),
          Positioned.fill(
            child: GestureDetector(
              key: const Key('login_background'),
              onTap: () => Routes.goBack(context),
              behavior: HitTestBehavior.opaque,
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                WnSlateContainer(
                  child: Column(
                    spacing: 8.h,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        spacing: 4.w,
                        children: [
                          IconButton(
                            key: const Key('back_button'),
                            onPressed: () => Routes.goBack(context),
                            icon: WnIcon(
                              WnIcons.chevronLeft,
                              size: 24.sp,
                              color: context.colors.backgroundContentTertiary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Login to White Noise',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: context.colors.backgroundContentTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap(8.h),
                      WnTextFormField(
                        label: 'Enter your private key',
                        placeholder: 'nsec...',
                        controller: controller,
                        autofocus: true,
                        obscureText: true,
                        errorText: state.error,
                        onChanged: (_) => clearError(),
                        onPaste: paste,
                      ),
                      WnFilledButton(
                        text: 'Login',
                        onPressed: onSubmit,
                        loading: state.isLoading,
                      ),
                    ],
                  ),
                ),
                Gap(16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
