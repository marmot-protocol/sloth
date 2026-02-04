import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sloth/hooks/use_follow_actions.dart';
import 'package:sloth/hooks/use_user_has_key_package.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/src/rust/api/groups.dart' as groups_api;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';
import 'package:sloth/widgets/wn_system_notice.dart';
import 'package:sloth/widgets/wn_user_profile_card.dart';

final _logger = Logger('StartChatScreen');

class StartChatScreen extends HookConsumerWidget {
  const StartChatScreen({super.key, required this.userPubkey});

  final String userPubkey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typographyScaled;
    final accountPubkey = ref.watch(accountPubkeyProvider);

    final metadataSnapshot = useUserMetadata(context, userPubkey);
    final keyPackageSnapshot = useUserHasKeyPackage(userPubkey);
    final isStartingChat = useState(false);
    final noticeMessage = useState<String?>(null);

    void showCopiedNotice(String message) {
      noticeMessage.value = message;
    }

    void dismissNotice() {
      noticeMessage.value = null;
    }

    final followState = useFollowActions(
      accountPubkey: accountPubkey,
      userPubkey: userPubkey,
    );

    final metadata = metadataSnapshot.data;
    final isLoading =
        metadataSnapshot.connectionState == ConnectionState.waiting ||
        keyPackageSnapshot.connectionState == ConnectionState.waiting ||
        followState.isLoading;
    final isFollowing = followState.isFollowing;
    final hasKeyPackage = keyPackageSnapshot.data ?? false;

    Future<void> startChat() async {
      isStartingChat.value = true;

      try {
        final group = await groups_api.createGroup(
          creatorPubkey: accountPubkey,
          memberPubkeys: [userPubkey],
          adminPubkeys: [accountPubkey],
          groupName: '',
          groupDescription: '',
          groupType: groups_api.GroupType.directMessage,
        );

        if (context.mounted) {
          Routes.goToChat(context, group.mlsGroupId);
        }
      } catch (e) {
        _logger.severe('Failed to start chat: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.failedToStartChat)),
          );
        }
      } finally {
        if (context.mounted) {
          isStartingChat.value = false;
        }
      }
    }

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
      body: GestureDetector(
        key: const Key('start_chat_background'),
        onTap: () => Routes.goBack(context),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              WnSlate(
                header: WnSlateNavigationHeader(
                  title: context.l10n.startNewChat,
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isLoading)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: CircularProgressIndicator(
                              color: colors.backgroundContentPrimary,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        )
                      else ...[
                        WnUserProfileCard(
                          userPubkey: userPubkey,
                          metadata: metadata,
                          onPublicKeyCopied: () => showCopiedNotice(context.l10n.publicKeyCopied),
                        ),
                        Gap(24.h),
                        if (hasKeyPackage) ...[
                          SizedBox(
                            width: double.infinity,
                            child: WnButton(
                              key: const Key('follow_button'),
                              text: isFollowing ? context.l10n.unfollow : context.l10n.follow,
                              type: WnButtonType.outline,
                              loading: followState.isActionLoading,
                              onPressed: handleFollowAction,
                            ),
                          ),
                          Gap(8.h),
                          SizedBox(
                            width: double.infinity,
                            child: WnButton(
                              key: const Key('start_chat_button'),
                              text: context.l10n.startChat,
                              loading: isStartingChat.value,
                              onPressed: startChat,
                            ),
                          ),
                        ] else
                          Text(
                            key: const Key('user_not_on_whitenoise'),
                            context.l10n.userNotOnWhiteNoise,
                            style: typography.medium14.copyWith(
                              color: colors.backgroundContentSecondary,
                            ),
                            textAlign: TextAlign.center,
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
    );
  }
}
