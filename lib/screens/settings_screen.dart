import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/utils/formatting.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final metadataSnapshot = useUserMetadata(pubkey);

    final metadata = metadataSnapshot.data;
    final displayName = metadata?.displayName ?? metadata?.name;

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
                const WnScreenHeader(title: 'Settings'),
                Center(
                  child: Row(
                    spacing: 8.w,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                  fontWeight: FontWeight.w600,
                                  color: colors.foregroundPrimary,
                                ),
                              ),
                            Text(
                              formatPublicKey(pubkey),
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: colors.foregroundTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _SettingsTile(
                  svgPath: 'assets/svgs/user.svg',
                  label: 'Edit profile',
                  onTap: () => Routes.pushToWip(context),
                ),
                _SettingsTile(
                  svgPath: 'assets/svgs/password.svg',
                  label: 'Profile keys',
                  onTap: () => Routes.pushToWip(context),
                ),
                _SettingsTile(
                  svgPath: 'assets/svgs/relays.svg',
                  label: 'Network relays',
                  onTap: () => Routes.pushToWip(context),
                ),
                _SettingsTile(
                  svgPath: 'assets/svgs/settings.svg',
                  label: 'App settings',
                  onTap: () => Routes.pushToWip(context),
                ),
                _SettingsTile(
                  svgPath: 'assets/svgs/favorite.svg',
                  label: 'Donate to White Noise',
                  onTap: () => Routes.pushToDonate(context),
                ),
                _SettingsTile(
                  svgPath: 'assets/svgs/development.svg',
                  label: 'Developer settings',
                  onTap: () => Routes.pushToDeveloperSettings(context),
                ),
                _SettingsTile(
                  svgPath: 'assets/svgs/logout.svg',
                  label: 'Sign out',
                  onTap: () => _logout(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) {
      Routes.goToHome(context);
    }
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.svgPath,
    required this.label,
    required this.onTap,
  });

  final String svgPath;
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
            SvgPicture.asset(
              svgPath,
              width: 24.w,
              height: 24.w,
              colorFilter: ColorFilter.mode(
                colors.foregroundPrimary,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: colors.foregroundPrimary,
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
