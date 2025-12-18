import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useTextEditingController, useState;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget, WidgetRef;
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/providers/auth_provider.dart' show authProvider;
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/widgets/wn_filled_button.dart' show WnFilledButton;
import 'package:sloth/widgets/wn_pixels_layer.dart' show WnPixelsLayer;
import 'package:sloth/widgets/wn_slate_container.dart' show WnSlateContainer;
import 'package:sloth/widgets/wn_text_form_field.dart' show WnTextFormField;

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final controller = useTextEditingController();
    final isLoading = useState(false);
    final error = useState<String?>(null);

    Future<void> onSubmit() async {
      final nsec = controller.text.trim();
      if (nsec.isEmpty) return;

      isLoading.value = true;
      error.value = null;
      try {
        await ref.read(authProvider.notifier).login(nsec);
        if (context.mounted) {
          Routes.goToOnboarding(context);
        }
      } catch (e) {
        error.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          WnPixelsLayer(isAnimating: isLoading.value),
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
                            icon: const Icon(Icons.chevron_left),
                            color: context.colors.foregroundTertiary,
                            iconSize: 24.sp,
                          ),
                          Expanded(
                            child: Text(
                              'Login to White Noise',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: context.colors.foregroundTertiary,
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
                        errorText: error.value != null
                            ? 'Oh no! An error occurred, please try again.'
                            : null,
                        onChanged: (_) => error.value = null,
                      ),
                      WnFilledButton(
                        text: 'Login',
                        onPressed: onSubmit,
                        loading: isLoading.value,
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
