import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_nsec.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/utils/formatting.dart';
import 'package:sloth/widgets/wn_copyable_field.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';
import 'package:sloth/widgets/wn_warning_box.dart';

class ProfileKeysScreen extends HookConsumerWidget {
  const ProfileKeysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final npub = npubFromHex(pubkey);
    final (:state, :loadNsec) = useNsec(pubkey);
    final obscurePrivateKey = useState(true);

    useEffect(() {
      loadNsec();
      return null;
    }, [pubkey]);

    void togglePrivateKeyVisibility() {
      obscurePrivateKey.value = !obscurePrivateKey.value;
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlateContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WnScreenHeader(title: context.l10n.profileKeys),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(24.h),
                          WnCopyableField(
                            label: context.l10n.publicKey,
                            value: npub ?? '',
                            copiedMessage: context.l10n.publicKeyCopied,
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
                          Gap(36.h),
                          WnCopyableField(
                            label: context.l10n.privateKey,
                            value: state.nsec ?? '',
                            obscurable: true,
                            obscured: obscurePrivateKey.value,
                            onToggleVisibility: togglePrivateKeyVisibility,
                            copiedMessage: context.l10n.privateKeyCopied,
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
                          WnWarningBox(
                            title: context.l10n.keepPrivateKeySecure,
                            description: context.l10n.privateKeyWarning,
                          ),
                          Gap(24.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
