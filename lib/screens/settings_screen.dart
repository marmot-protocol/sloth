import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/utils/formatting.dart';
import 'package:sloth/utils/metadata.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

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
          child: WnSlateContainer(
            child: Column(
              spacing: 16.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WnScreenHeader(title: context.l10n.settings),
                Row(
                  spacing: 8.w,
                  children: [
                    WnAvatar(
                      pictureUrl: metadata?.picture,
                      displayName: displayName,
                      size: 56.w,
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
                                letterSpacing: 0.2,
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
                              letterSpacing: 0.6,
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
                        size: WnButtonSize.medium,
                        onPressed: () => Routes.pushToSwitchProfile(context),
                      ),
                    ),
                  ],
                ),
                _SettingsTile(
                  icon: WnIcons.user,
                  label: context.l10n.editProfile,
                  onTap: () => Routes.pushToEditProfile(context),
                ),
                _SettingsTile(
                  icon: WnIcons.key,
                  label: context.l10n.profileKeys,
                  onTap: () => Routes.pushToProfileKeys(context),
                ),
                _SettingsTile(
                  icon: WnIcons.network,
                  label: context.l10n.networkRelays,
                  onTap: () => Routes.pushToNetwork(context),
                ),
                _SettingsTile(
                  icon: WnIcons.settings,
                  label: context.l10n.appSettings,
                  onTap: () => Routes.pushToAppSettings(context),
                ),
                _SettingsTile(
                  icon: WnIcons.heart,
                  label: context.l10n.donateToWhiteNoise,
                  onTap: () => Routes.pushToDonate(context),
                ),
                _SettingsTile(
                  icon: WnIcons.developerSettings,
                  label: context.l10n.developerSettings,
                  onTap: () => Routes.pushToDeveloperSettings(context),
                ),
                _SettingsTile(
                  icon: WnIcons.logout,
                  label: context.l10n.signOut,
                  onTap: () => Routes.pushToSignOut(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final WnIcons icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            WnIcon(icon, color: colors.backgroundContentPrimary),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: colors.backgroundContentPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
