import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/utils/avatar_color.dart';
import 'package:sloth/utils/formatting.dart';
import 'package:sloth/utils/metadata.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_menu.dart';
import 'package:sloth/widgets/wn_menu_item.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(authProvider).value;
    final metadataSnapshot = useUserMetadata(context, pubkey);

    if (pubkey == null) {
      return const SizedBox.shrink();
    }

    final metadata = metadataSnapshot.data;
    final displayName = presentName(metadata);

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlate(
            showTopScrollEffect: true,
            showBottomScrollEffect: true,
            header: WnSlateNavigationHeader(
              title: context.l10n.settings,
              onNavigate: () => Routes.goBack(context),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Column(
                spacing: 16.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 8.w,
                    children: [
                      WnAvatar(
                        pictureUrl: metadata?.picture,
                        displayName: displayName,
                        size: WnAvatarSize.medium,
                        color: avatarColorFromPubkey(pubkey),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (displayName != null)
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: colors.backgroundContentPrimary,
                                  height: 22 / 16,
                                  letterSpacing: 0.2.sp,
                                ),
                              ),
                            SizedBox(height: 4.h),
                            Text(
                              formatPublicKey(
                                npubFromHex(pubkey) ?? pubkey,
                              ),
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: colors.backgroundContentSecondary,
                                height: 16 / 12,
                                letterSpacing: 0.6.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    spacing: 8.h,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: WnButton(
                          key: const Key('share_and_connect_button'),
                          text: context.l10n.shareAndConnect,
                          trailingIcon: WnIcons.qrCode,
                          size: WnButtonSize.medium,
                          onPressed: () => Routes.pushToShareProfile(context),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: WnButton(
                          text: context.l10n.switchProfile,
                          type: WnButtonType.outline,
                          trailingIcon: WnIcons.change,
                          size: WnButtonSize.medium,
                          onPressed: () => Routes.pushToSwitchProfile(context),
                        ),
                      ),
                    ],
                  ),
                  WnMenu(
                    children: [
                      WnMenuItem(
                        icon: WnIcons.user,
                        label: context.l10n.editProfile,
                        onTap: () => Routes.pushToEditProfile(context),
                      ),
                      WnMenuItem(
                        icon: WnIcons.key,
                        label: context.l10n.profileKeys,
                        onTap: () => Routes.pushToProfileKeys(context),
                      ),
                      WnMenuItem(
                        icon: WnIcons.network,
                        label: context.l10n.networkRelays,
                        onTap: () => Routes.pushToNetwork(context),
                      ),
                      WnMenuItem(
                        icon: WnIcons.settings,
                        label: context.l10n.appSettings,
                        onTap: () => Routes.pushToAppSettings(context),
                      ),
                      WnMenuItem(
                        icon: WnIcons.heart,
                        label: context.l10n.donateToWhiteNoise,
                        onTap: () => Routes.pushToDonate(context),
                      ),
                      WnMenuItem(
                        icon: WnIcons.developerSettings,
                        label: context.l10n.developerSettings,
                        onTap: () => Routes.pushToDeveloperSettings(context),
                      ),
                      WnMenuItem(
                        icon: WnIcons.logout,
                        label: context.l10n.signOut,
                        onTap: () => Routes.pushToSignOut(context),
                      ),
                    ],
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
