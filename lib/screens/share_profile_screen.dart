import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/utils/formatting.dart';
import 'package:sloth/utils/metadata.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

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
        const SnackBar(
          content: Text('Public key copied to clipboard'),
          duration: Duration(seconds: 2),
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
              child: WnSlateContainer(
                child: Column(
                  spacing: 16.h,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WnScreenHeader(title: 'Share profile'),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Center(
                          child: Column(
                            children: [
                              WnAvatar(
                                pictureUrl: metadata?.picture,
                                displayName: displayName,
                                size: 96.w,
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
                                      onPressed: npub != null ? () => copyToClipboard(npub) : null,
                                      icon: WnIcon(
                                        WnIcons.copy,
                                        color: colors.backgroundContentPrimary,
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
                                'Scan to connect',
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
    );
  }
}
