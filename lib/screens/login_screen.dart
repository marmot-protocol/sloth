import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useState;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget, WidgetRef;
import 'package:sloth/hooks/use_android_signer.dart' show useAndroidSigner;
import 'package:sloth/hooks/use_login.dart' show useLogin;
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/android_signer_service_provider.dart'
    show androidSignerServiceProvider;
import 'package:sloth/providers/auth_provider.dart' show authProvider;
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/services/android_signer_service.dart' show AndroidSignerException;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_input_password.dart' show WnInputPassword;
import 'package:sloth/widgets/wn_pixels_layer.dart' show WnPixelsLayer;
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final (:controller, :state, :paste, :submit, :clearError) = useLogin(
      (nsec) => ref.read(authProvider.notifier).login(nsec),
    );
    final signerService = ref.watch(androidSignerServiceProvider);
    final androidSigner = useAndroidSigner(signerService);
    final signerError = useState<String?>(null);
    final isSignerLoading = useState(false);

    Future<void> onSubmit() async {
      final success = await submit();
      if (success && context.mounted) {
        Routes.goToChatList(context);
      }
    }

    Future<void> onScan() async {
      final scannedValue = await Routes.pushToScanNsec(context);
      if (scannedValue != null && scannedValue.isNotEmpty) {
        controller.text = scannedValue;
        clearError();
      }
    }

    Future<void> onAndroidSignerLogin() async {
      final signerConnectionErrorMessage = context.l10n.signerConnectionError;
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
      } catch (_) {
        signerError.value = signerConnectionErrorMessage;
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
                WnSlate(
                  header: WnSlateNavigationHeader(
                    title: context.l10n.loginTitle,
                    type: WnSlateNavigationType.back,
                    onNavigate: () => Routes.goBack(context),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                    child: Column(
                      spacing: 8.h,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WnInputPassword(
                          label: context.l10n.enterPrivateKey,
                          placeholder: context.l10n.nsecPlaceholder,
                          controller: controller,
                          autofocus: true,
                          errorText: state.error,
                          onChanged: (_) => clearError(),
                          onPaste: paste,
                          onScan: onScan,
                        ),
                        WnButton(
                          key: const Key('login_button'),
                          text: context.l10n.login,
                          onPressed: onSubmit,
                          loading: state.isLoading,
                        ),
                        if (androidSigner.isAvailable) ...[
                          WnButton(
                            key: const Key('android_signer_login_button'),
                            text: context.l10n.loginWithSigner,
                            type: WnButtonType.outline,
                            onPressed: onAndroidSignerLogin,
                            loading: androidSigner.isConnecting,
                            disabled: state.isLoading,
                          ),
                          if (signerError.value != null) ...[
                            Text(
                              signerError.value!,
                              textAlign: TextAlign.center,
                              style: context.typographyScaled.medium12,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
