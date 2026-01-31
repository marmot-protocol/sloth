import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_follow_actions.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';
import 'package:sloth/widgets/wn_user_profile_card.dart';

class ChatInfoScreen extends HookConsumerWidget {
  const ChatInfoScreen({super.key, required this.userPubkey});

  final String userPubkey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final accountPubkey = ref.watch(accountPubkeyProvider);

    final metadataSnapshot = useUserMetadata(context, userPubkey);
    final followState = useFollowActions(
      accountPubkey: accountPubkey,
      userPubkey: userPubkey,
    );

    final metadata = metadataSnapshot.data;
    final isLoading =
        metadataSnapshot.connectionState == ConnectionState.waiting || followState.isLoading;
    final isFollowing = followState.isFollowing;
    final isOwnProfile = userPubkey == accountPubkey;

    Future<void> handleFollowAction() async {
      try {
        await followState.toggleFollow();
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.failedToUpdateFollow)),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlateContainer(
            padding: EdgeInsets.only(left: 14.w, right: 14.w, top: 14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WnScreenHeader(title: context.l10n.profile),
                Gap(24.h),
                if (isLoading)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colors.backgroundContentPrimary,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          WnUserProfileCard(
                            userPubkey: userPubkey,
                            metadata: metadata,
                          ),
                          if (!isOwnProfile) ...[
                            Gap(24.h),
                            SizedBox(
                              width: double.infinity,
                              child: WnButton(
                                key: const Key('follow_button'),
                                text: isFollowing ? context.l10n.unfollow : context.l10n.follow,
                                type: isFollowing ? WnButtonType.outline : WnButtonType.primary,
                                loading: followState.isActionLoading,
                                onPressed: handleFollowAction,
                              ),
                            ),
                          ],
                        ],
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
