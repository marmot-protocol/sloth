import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_nsec.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/utils/formatting.dart';
import 'package:sloth/widgets/wn_callout.dart';
import 'package:sloth/widgets/wn_copyable_field.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';
import 'package:sloth/widgets/wn_system_notice.dart';

class ProfileKeysScreen extends HookConsumerWidget {
  const ProfileKeysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final npub = npubFromHex(pubkey);
    final (:state, :loadNsec) = useNsec(pubkey);
    final obscurePrivateKey = useState(true);
    final isUsingExternalSigner = useState<bool?>(null);
    final noticeMessage = useState<String?>(null);

    useEffect(() {
      var disposed = false;
      loadNsec();

      Future<void> checkSignerType() async {
        final isExternal = await ref.read(authProvider.notifier).isUsingAndroidSigner();
        if (!disposed) {
          isUsingExternalSigner.value = isExternal;
        }
      }

      checkSignerType();
      return () {
        disposed = true;
      };
    }, [pubkey]);

    void togglePrivateKeyVisibility() {
      obscurePrivateKey.value = !obscurePrivateKey.value;
    }

    void showCopiedNotice(String message) {
      noticeMessage.value = message;
    }

    void dismissNotice() {
      noticeMessage.value = null;
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlate(
            header: WnSlateNavigationHeader(
              title: context.l10n.profileKeys,
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
                          WnCopyableField(
                            label: context.l10n.publicKey,
                            value: npub ?? '',
                            onCopied: () => showCopiedNotice(context.l10n.publicKeyCopied),
                          ),
                          Gap(12.h),
                          Text(
                            context.l10n.publicKeyDescription,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: colors.backgroundContentSecondary,
                            ),
                          ),
                          if (isUsingExternalSigner.value == false) ...[
                            Gap(36.h),
                            WnCopyableField(
                              label: context.l10n.privateKey,
                              value: state.nsec ?? '',
                              obscurable: true,
                              obscured: obscurePrivateKey.value,
                              onToggleVisibility: togglePrivateKeyVisibility,
                              onCopied: () => showCopiedNotice(context.l10n.privateKeyCopied),
                            ),
                            Gap(10.h),
                            Text(
                              context.l10n.privateKeyDescription,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: colors.backgroundContentSecondary,
                              ),
                            ),
                            Gap(12.h),
                            WnCallout(
                              title: context.l10n.keepPrivateKeySecure,
                              description: context.l10n.privateKeyWarning,
                              type: CalloutType.warning,
                            ),
                          ],
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
