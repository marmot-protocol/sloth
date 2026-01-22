import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_accounts.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';

import 'package:sloth/theme.dart';
import 'package:sloth/utils/formatting.dart';
import 'package:sloth/utils/metadata.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_filled_button.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class SwitchProfileScreen extends HookConsumerWidget {
  const SwitchProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final currentPubkey = ref.watch(authProvider).value;
    final (:accounts, :state, :switchTo) = useAccounts(context, ref, currentPubkey);

    if (accounts.connectionState == ConnectionState.waiting) {
      return Scaffold(
        backgroundColor: colors.backgroundPrimary,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: WnSlateContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WnScreenHeader(title: 'Profiles'),
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colors.backgroundContentPrimary,
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

    final accountsList = accounts.data ?? [];

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlateContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WnScreenHeader(title: 'Profiles'),
                if (state.error != null) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      state.error!,
                      style: TextStyle(
                        color: colors.fillDestructive,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  Gap(12.h),
                ],
                Expanded(
                  child: accountsList.isEmpty
                      ? Center(
                          child: Text(
                            'No accounts available',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: colors.backgroundContentSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: accountsList.length,
                          itemBuilder: (context, index) {
                            final account = accountsList[index];
                            final isCurrentAccount = account.pubkey == currentPubkey;

                            return _AccountTile(
                              pubkey: account.pubkey,
                              isCurrent: isCurrentAccount,
                              isSwitching: state.isSwitching,
                              onTap: () => switchTo(account.pubkey),
                            );
                          },
                        ),
                ),
                Gap(16.h),
                SizedBox(
                  width: double.infinity,
                  child: WnFilledButton(
                    text: 'Connect Another Profile',
                    onPressed: () => Routes.pushToAddProfile(context),
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

class _AccountTile extends HookConsumerWidget {
  const _AccountTile({
    required this.pubkey,
    required this.isCurrent,
    required this.isSwitching,
    required this.onTap,
  });

  final String pubkey;
  final bool isCurrent;
  final bool isSwitching;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final metadataSnapshot = useUserMetadata(context, pubkey);
    final metadata = metadataSnapshot.data;
    final displayName = presentName(metadata);

    return GestureDetector(
      onTap: isSwitching ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            WnAvatar(
              pictureUrl: metadata?.picture,
              displayName: displayName,
              size: 48.w,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (displayName != null)
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.backgroundContentPrimary,
                      ),
                    ),
                  Text(
                    formatPublicKey(npubFromHex(pubkey) ?? pubkey),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: colors.backgroundContentSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isCurrent)
              Icon(
                Icons.check_circle,
                color: colors.backgroundContentPrimary,
                size: 24.w,
              ),
            if (isSwitching && !isCurrent)
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.backgroundContentPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
