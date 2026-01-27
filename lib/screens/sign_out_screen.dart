import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_android_signer.dart';
import 'package:sloth/hooks/use_nsec.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_callout.dart';
import 'package:sloth/widgets/wn_copyable_field.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';
import 'package:sloth/widgets/wn_system_notice.dart';

class SignOutScreen extends HookConsumerWidget {
  const SignOutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typographyScaled;
    final pubkey = ref.watch(authProvider).value;
    final (:state, :loadNsec) = useNsec(pubkey);
    final androidSigner = useAndroidSigner();
    final obscurePrivateKey = useState(true);
    final isLoggingOut = useState(false);
    final noticeMessage = useState<String?>(null);

    useEffect(() {
      loadNsec();
      return null;
    }, [pubkey]);

    if (pubkey == null) {
      return const SizedBox.shrink();
    }

    void togglePrivateKeyVisibility() {
      obscurePrivateKey.value = !obscurePrivateKey.value;
    }

    void showCopiedNotice(String message) {
      noticeMessage.value = message;
    }

    void dismissNotice() {
      noticeMessage.value = null;
    }

    Future<void> signOut() async {
      isLoggingOut.value = true;
      final nextPubkey = await ref
          .read(authProvider.notifier)
          .logout(
            onAndroidSignerDisconnect: androidSigner.disconnect,
          );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          if (nextPubkey != null) {
            Routes.goBack(context);
          } else {
            Routes.goToHome(context);
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlate(
            header: WnSlateNavigationHeader(
              title: context.l10n.signOut,
              type: WnSlateNavigationType.back,
              onNavigate: () => Routes.goBack(context),
            ),
            systemNotice: noticeMessage.value != null
                ? WnSystemNotice(
                    key: ValueKey(noticeMessage.value),
                    title: noticeMessage.value!,
                    onDismiss: dismissNotice,
                  )
                : null,
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(24.h),
                          WnCallout(
                            title: context.l10n.signOutConfirmation,
                            description: context.l10n.signOutWarning,
                            type: CalloutType.warning,
                          ),
                          Gap(24.h),
                          Text(
                            context.l10n.backUpPrivateKey,
                            style: typography.semiBold16.copyWith(
                              color: colors.backgroundContentPrimary,
                            ),
                          ),
                          Gap(8.h),
                          Text(
                            context.l10n.copyPrivateKeyHint,
                            style: typography.medium14.copyWith(
                              color: colors.backgroundContentSecondary,
                            ),
                          ),
                          Gap(16.h),
                          WnCopyableField(
                            label: context.l10n.privateKey,
                            value: state.nsec ?? '',
                            obscurable: true,
                            obscured: obscurePrivateKey.value,
                            onToggleVisibility: togglePrivateKeyVisibility,
                            onCopied: () => showCopiedNotice(context.l10n.privateKeyCopied),
                          ),
                          Gap(32.h),
                          SizedBox(
                            width: double.infinity,
                            child: WnButton(
                              text: context.l10n.signOut,
                              onPressed: signOut,
                              loading: isLoggingOut.value,
                              size: WnButtonSize.medium,
                            ),
                          ),
                          Gap(24.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
