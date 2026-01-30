import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useState;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget, WidgetRef;
import 'package:sloth/hooks/use_android_signer.dart' show useAndroidSigner;
import 'package:sloth/hooks/use_login.dart' show useLogin;
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/auth_provider.dart' show authProvider;
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/services/android_signer_service.dart' show AndroidSignerException;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
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
    final androidSigner = useAndroidSigner();
    final signerError = useState<String?>(null);
    final isSignerLoading = useState(false);

    Future<void> onSubmit() async {
      final success = await submit();
      if (success && context.mounted) {
        Routes.goToChatList(context);
      }
    }

    Future<void> onAndroidSignerLogin() async {
      signerError.value = null;
      clearError();
      isSignerLoading.value = true;
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
      } finally {
        isSignerLoading.value = false;
      }
    }

    final anyLoading = state.isLoading || isSignerLoading.value;

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
                            icon: WnIcon(
                              WnIcons.chevronLeft,
                              size: 24.sp,
                              color: context.colors.backgroundContentTertiary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              context.l10n.loginTitle,
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
                        label: context.l10n.enterPrivateKey,
                        placeholder: context.l10n.nsecPlaceholder,
                        controller: controller,
                        autofocus: true,
                        obscureText: true,
                        errorText: state.error,
                        onChanged: (_) => clearError(),
                        onPaste: paste,
                      ),
                      WnButton(
                        text: context.l10n.login,
                        onPressed: onSubmit,
                        loading: state.isLoading,
                        disabled: isSignerLoading.value,
                      ),
                      if (androidSigner.isAvailable) ...[
                        WnButton(
                          key: const Key('android_signer_login_button'),
                          text: 'Login with Signer',
                          type: WnButtonType.outline,
                          onPressed: onAndroidSignerLogin,
                          loading: isSignerLoading.value,
                          disabled: state.isLoading,
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
