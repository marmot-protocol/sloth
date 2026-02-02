import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/utils/avatar_color.dart';
import 'package:sloth/utils/formatting.dart';
import 'package:sloth/utils/metadata.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';

class ShareProfileScreen extends HookConsumerWidget {
  const ShareProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final metadataSnapshot = useUserMetadata(context, pubkey);
    final npub = npubFromHex(pubkey);

    void copyToClipboard(String text) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.publicKeyCopied),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    final metadata = metadataSnapshot.data;
    final displayName = presentName(metadata);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colors.backgroundPrimary,
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: WnSlate(
                header: WnSlateNavigationHeader(
                  title: context.l10n.shareProfileTitle,
                  onNavigate: () => Routes.goBack(context),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
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
                                  color: avatarColorFromPubkey(pubkey),
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
                                Gap(18.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          formatPublicKey(npub ?? pubkey),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: colors.backgroundContentTertiary,
                                          ),
                                        ),
                                      ),
                                      Gap(8.w),
                                      IconButton(
                                        key: const Key('copy_button'),
                                        onPressed: npub != null
                                            ? () => copyToClipboard(npub)
                                            : null,
                                        icon: WnIcon(
                                          WnIcons.copy,
                                          color: npub != null
                                              ? colors.backgroundContentPrimary
                                              : colors.backgroundContentTertiary,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(
                                          minWidth: 24.w,
                                          minHeight: 24.w,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Gap(32.h),
                                if (npub != null)
                                  QrImageView(
                                    data: npub,
                                    size: 256.w,
                                    gapless: false,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: colors.backgroundContentPrimary,
                                    ),
                                    backgroundColor: colors.backgroundPrimary,
                                  ),
                                Gap(10.h),
                                Text(
                                  context.l10n.scanToConnect,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: colors.backgroundContentTertiary,
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
          ),
        ),
      ),
    );
  }
}
