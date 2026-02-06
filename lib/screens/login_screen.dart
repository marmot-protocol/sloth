import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget, WidgetRef;
import 'package:whitenoise/hooks/use_login_with_android_signer.dart' show useLoginWithAndroidSigner;
import 'package:whitenoise/hooks/use_login_with_nsec.dart' show useLoginWithNsec;
import 'package:whitenoise/l10n/l10n.dart';
import 'package:whitenoise/providers/auth_provider.dart' show authProvider;
import 'package:whitenoise/routes.dart' show Routes;
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_button.dart';
import 'package:whitenoise/widgets/wn_input_password.dart' show WnInputPassword;
import 'package:whitenoise/widgets/wn_pixels_layer.dart' show WnPixelsLayer;
import 'package:whitenoise/widgets/wn_slate.dart';
import 'package:whitenoise/widgets/wn_slate_navigation_header.dart';
import 'package:whitenoise/widgets/wn_system_notice.dart'
    show WnSystemNotice, WnSystemNoticeType, WnSystemNoticeVariant;

String _signerErrorL10n(String code, AppLocalizations l10n) {
  switch (code) {
    case 'USER_REJECTED':
      return l10n.signerErrorUserRejected;
    case 'NOT_CONNECTED':
      return l10n.signerErrorNotConnected;
    case 'NO_SIGNER':
      return l10n.signerErrorNoSigner;
    case 'NO_RESPONSE':
      return l10n.signerErrorNoResponse;
    case 'NO_PUBKEY':
      return l10n.signerErrorNoPubkey;
    case 'NO_RESULT':
      return l10n.signerErrorNoResult;
    case 'NO_EVENT':
      return l10n.signerErrorNoEvent;
    case 'REQUEST_IN_PROGRESS':
      return l10n.signerErrorRequestInProgress;
    case 'NO_ACTIVITY':
      return l10n.signerErrorNoActivity;
    case 'LAUNCH_ERROR':
      return l10n.signerErrorLaunchError;
    case 'CONNECTION_ERROR':
      return l10n.signerConnectionError;
    default:
      return l10n.signerErrorUnknown;
  }
}

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final (
      :nsecInputController,
      :loginWithNsecState,
      :pasteNsec,
      :submitLoginWithNsec,
      :clearLoginWithNsecError,
    ) = useLoginWithNsec(
      (nsec) => ref.read(authProvider.notifier).loginWithNsec(nsec),
    );
    final (
      :isAndroidSignerAvailable,
      :loginWithAndroidSignerState,
      :submitLoginWithAndroidSigner,
      :clearLoginWithAndroidSignerError,
    ) = useLoginWithAndroidSigner(
      (pubkey) => ref.read(authProvider.notifier).loginWithAndroidSigner(pubkey: pubkey),
    );

    Future<void> onSubmit() async {
      final success = await submitLoginWithNsec();
      if (success && context.mounted) {
        Routes.goToChatList(context);
      }
    }

    Future<void> onScan() async {
      final scannedValue = await Routes.pushToScanNsec(context);
      if (scannedValue != null && scannedValue.isNotEmpty) {
        nsecInputController.text = scannedValue;
        clearLoginWithNsecError();
      }
    }

    Future<void> onAndroidSignerSubmit() async {
      clearLoginWithNsecError();
      final success = await submitLoginWithAndroidSigner();
      if (success && context.mounted) {
        Routes.goToChatList(context);
      }
    }

    final isLoginLoading = loginWithNsecState.isLoading || loginWithAndroidSignerState.isLoading;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          WnPixelsLayer(isAnimating: isLoginLoading),
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
                  systemNotice: loginWithAndroidSignerState.error != null
                      ? WnSystemNotice(
                          key: ValueKey(loginWithAndroidSignerState.error),
                          title: _signerErrorL10n(
                            loginWithAndroidSignerState.error!,
                            context.l10n,
                          ),
                          type: WnSystemNoticeType.error,
                          variant: WnSystemNoticeVariant.dismissible,
                          onDismiss: clearLoginWithAndroidSignerError,
                        )
                      : null,
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
                          controller: nsecInputController,
                          errorText: loginWithNsecState.error,
                          onChanged: (_) => clearLoginWithNsecError(),
                          onPaste: pasteNsec,
                          onScan: onScan,
                        ),
                        ListenableBuilder(
                          listenable: nsecInputController,
                          builder: (context, _) {
                            final signerPrimary =
                                isAndroidSignerAvailable && nsecInputController.text.trim().isEmpty;
                            return Column(
                              spacing: 8.h,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                WnButton(
                                  key: const Key('login_button'),
                                  text: context.l10n.login,
                                  type: signerPrimary ? WnButtonType.outline : WnButtonType.primary,
                                  onPressed: onSubmit,
                                  loading: loginWithNsecState.isLoading,
                                  disabled: loginWithAndroidSignerState.isLoading,
                                ),
                                if (isAndroidSignerAvailable)
                                  WnButton(
                                    key: const Key('android_signer_login_button'),
                                    text: context.l10n.loginWithSigner,
                                    type: signerPrimary
                                        ? WnButtonType.primary
                                        : WnButtonType.outline,
                                    onPressed: onAndroidSignerSubmit,
                                    loading: loginWithAndroidSignerState.isLoading,
                                    disabled: loginWithNsecState.isLoading,
                                  ),
                              ],
                            );
                          },
                        ),
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
