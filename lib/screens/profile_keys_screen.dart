import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_nsec.dart';
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
    final npub = npubFromPubkey(pubkey);
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
                const WnScreenHeader(title: 'Profile keys'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(24.h),
                          WnCopyableField(
                            label: 'Public key',
                            value: npub ?? '',
                            copiedMessage: 'Public key copied to clipboard',
                          ),
                          Gap(12.h),
                          Text(
                            'Your public key (npub) can be shared with others. It\'s used to identify you on the network.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: colors.backgroundContentTertiary,
                            ),
                          ),
                          Gap(36.h),
                          WnCopyableField(
                            label: 'Private key',
                            value: state.nsec ?? '',
                            obscurable: true,
                            obscured: obscurePrivateKey.value,
                            onToggleVisibility: togglePrivateKeyVisibility,
                            copiedMessage: 'Private key copied to clipboard',
                          ),
                          Gap(10.h),
                          Text(
                            'Your private key (nsec) should be kept secret. Anyone with access to it can control your account.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: colors.backgroundContentTertiary,
                            ),
                          ),
                          Gap(12.h),
                          const WnWarningBox(
                            title: 'Keep your private key secure',
                            description:
                                'Don\'t share your private key publicly, and use it only to log in to other Nostr apps.',
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
