import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useTextEditingController, useState;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget, WidgetRef;
import 'package:sloth/hooks/use_android_signer.dart' show useAndroidSigner;
import 'package:sloth/providers/auth_provider.dart' show authProvider;
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/services/android_signer_service.dart' show AndroidSignerException;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_filled_button.dart' show WnFilledButton;
import 'package:sloth/widgets/wn_outlined_button.dart' show WnOutlinedButton;
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
    final androidSigner = useAndroidSigner();
    final signerError = useState<String?>(null);

    Future<void> onSubmit() async {
      final nsec = controller.text.trim();
      if (nsec.isEmpty) return;

      isLoading.value = true;
      error.value = null;
      try {
        await ref.read(authProvider.notifier).login(nsec);
        if (context.mounted) {
          Routes.goToChatList(context);
        }
      } catch (e) {
        error.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> onAndroidSignerLogin() async {
      signerError.value = null;
      error.value = null;
      try {
        final pubkey = await androidSigner.connect();
        await ref
            .read(authProvider.notifier)
            .loginWithAndroidSigner(
              pubkey: pubkey,
              onDisconnect: androidSigner.disconnect,
            );
        if (context.mounted) {
          Routes.goToChatList(context);
        }
      } on AndroidSignerException catch (e) {
        signerError.value = e.userFriendlyMessage;
      } catch (e) {
        signerError.value = 'Unable to connect to signer. Please try again.';
      }
    }

    final anyLoading = isLoading.value || androidSigner.isConnecting;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          WnPixelsLayer(isAnimating: anyLoading),
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
                            color: context.colors.backgroundContentTertiary,
                            iconSize: 24.sp,
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
                        errorText: error.value != null
                            ? 'Oh no! An error occurred, please try again.'
                            : null,
                        onChanged: (_) => error.value = null,
                      ),
                      WnFilledButton(
                        text: 'Login',
                        onPressed: onSubmit,
                        loading: isLoading.value,
                        disabled: androidSigner.isConnecting,
                      ),
                      if (androidSigner.isAvailable) ...[
                        WnOutlinedButton(
                          key: const Key('android_signer_login_button'),
                          text: 'Login with Signer',
                          onPressed: onAndroidSignerLogin,
                          loading: androidSigner.isConnecting,
                          disabled: isLoading.value,
                        ),
                        if (signerError.value != null) ...[
                          Gap(4.h),
                          Text(
                            signerError.value!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colors.backgroundContentDestructive,
                            ),
                          ),
                        ],
                      ],
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
