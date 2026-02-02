import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_follows.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';
import 'package:sloth/widgets/wn_system_notice.dart';
import 'package:sloth/widgets/wn_user_profile_card.dart';

class ChatInfoScreen extends HookConsumerWidget {
  const ChatInfoScreen({super.key, required this.userPubkey});

  final String userPubkey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final accountPubkey = ref.watch(accountPubkeyProvider);

    final metadataSnapshot = useUserMetadata(context, userPubkey);
    final followsState = useFollows(accountPubkey);

    final noticeMessage = useState<String?>(null);

    void showCopiedNotice(String message) {
      noticeMessage.value = message;
    }

    void dismissNotice() {
      noticeMessage.value = null;
    }

    final metadata = metadataSnapshot.data;
    final isLoading = metadataSnapshot.connectionState == ConnectionState.waiting;
    final isFollowing = followsState.isFollowing(userPubkey);
    final isOwnProfile = userPubkey == accountPubkey;

    Future<void> handleFollowAction() async {
      try {
        if (isFollowing) {
          await followsState.unfollow(userPubkey);
        } else {
          await followsState.follow(userPubkey);
        }
      } catch (_) {
        if (context.mounted) {
          noticeMessage.value = context.l10n.failedToUpdateFollow;
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
              onNavigate: () => Routes.goBack(context),
            ),
            systemNotice: noticeMessage.value != null
                ? WnSystemNotice(
                    key: ValueKey(noticeMessage.value),
                    title: noticeMessage.value!,
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
                                  showCopiedNotice(context.l10n.publicKeyCopied),
                            ),
                            if (!isOwnProfile) ...[
                              Gap(24.h),
                              SizedBox(
                                width: double.infinity,
                                child: WnButton(
                                  key: const Key('follow_button'),
                                  text: isFollowing ? context.l10n.unfollow : context.l10n.follow,
                                  type: isFollowing ? WnButtonType.outline : WnButtonType.primary,
                                  loading: followsState.isActionLoading,
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
