import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:whitenoise/hooks/use_follow_actions.dart';
import 'package:whitenoise/hooks/use_system_notice.dart';
import 'package:whitenoise/hooks/use_user_metadata.dart';
import 'package:whitenoise/l10n/l10n.dart';
import 'package:whitenoise/providers/account_pubkey_provider.dart';
import 'package:whitenoise/routes.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_button.dart';
import 'package:whitenoise/widgets/wn_slate.dart';
import 'package:whitenoise/widgets/wn_slate_navigation_header.dart';
import 'package:whitenoise/widgets/wn_system_notice.dart' show WnSystemNotice;
import 'package:whitenoise/widgets/wn_user_profile_card.dart';

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
    final (:noticeMessage, :noticeType, :showErrorNotice, :showSuccessNotice, :dismissNotice) =
        useSystemNotice();

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
          showErrorNotice(context.l10n.failedToUpdateFollow);
        }
      }
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlate(
            header: WnSlateNavigationHeader(
              title: context.l10n.profile,
              type: WnSlateNavigationType.back,
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
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              onPublicKeyCopied: () =>
                                  showSuccessNotice(context.l10n.publicKeyCopied),
                              onPublicKeyCopyError: () =>
                                  showErrorNotice(context.l10n.publicKeyCopyError),
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
      ),
    );
  }
}
