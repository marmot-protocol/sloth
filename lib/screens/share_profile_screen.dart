import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sloth/hooks/use_system_notice.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/utils/formatting.dart';
import 'package:sloth/utils/metadata.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_copy_card.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';
import 'package:sloth/widgets/wn_system_notice.dart' show WnSystemNotice;

class ShareProfileScreen extends HookConsumerWidget {
  const ShareProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final metadataSnapshot = useUserMetadata(context, pubkey);
    final npub = npubFromHex(pubkey);
    final (:noticeMessage, :noticeType, :showSuccessNotice, :showErrorNotice, :dismissNotice) =
        useSystemNotice();

    final metadata = metadataSnapshot.data;
    final displayName = presentName(metadata);

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlate(
            header: WnSlateNavigationHeader(
              title: context.l10n.shareProfileTitle,
              onNavigate: () => Routes.goBack(context),
            ),
            systemNotice: noticeMessage != null
                ? WnSystemNotice(
                    key: ValueKey(noticeMessage),
                    title: noticeMessage,
                    type: noticeType,
                    onDismiss: dismissNotice,
                  )
                : null,
            child: Column(
              spacing: 16.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          WnAvatar(
                            pictureUrl: metadata?.picture,
                            displayName: displayName,
                            size: WnAvatarSize.large,
                            color: AvatarColor.fromPubkey(pubkey),
                          ),
                          Gap(8.h),
                          if (displayName != null)
                            Text(
                              displayName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: colors.backgroundContentPrimary,
                              ),
                            ),
                          Gap(16.h),
                          if (npub != null) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: WnCopyCard(
                                textToDisplay: formatPublicKey(npub),
                                textToCopy: npub,
                                onCopySuccess: () =>
                                    showSuccessNotice(context.l10n.publicKeyCopied),
                                onCopyError: () => showErrorNotice(
                                  context.l10n.publicKeyCopyError,
                                ),
                              ),
                            ),
                            Gap(36.h),
                            QrImageView(
                              data: npub,
                              size: 256.w,
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: colors.backgroundContentPrimary,
                              ),
                            ),
                          ] else
                            Gap(32.h),
                          Gap(10.h),
                          Text(
                            context.l10n.scanToConnect,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: colors.backgroundContentSecondary,
                            ),
                          ),
                          Gap(24.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: SizedBox(
                              width: double.infinity,
                              child: WnButton(
                                key: const Key('scan_qr_button'),
                                text: context.l10n.scanNpub,
                                type: WnButtonType.outline,
                                trailingIcon: WnIcons.scan,
                                size: WnButtonSize.medium,
                                onPressed: () => Routes.pushToScanNpub(context),
                              ),
                            ),
                          ),
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
