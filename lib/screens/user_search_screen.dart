import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:whitenoise/hooks/use_user_search.dart';
import 'package:whitenoise/l10n/l10n.dart';
import 'package:whitenoise/providers/account_pubkey_provider.dart';
import 'package:whitenoise/routes.dart';
import 'package:whitenoise/src/rust/api/users.dart' show User;
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/utils/formatting.dart' show formatPublicKey, npubFromHex;
import 'package:whitenoise/utils/metadata.dart' show presentName;
import 'package:whitenoise/widgets/wn_avatar.dart';
import 'package:whitenoise/widgets/wn_fade_overlay.dart';
import 'package:whitenoise/widgets/wn_middle_ellipsis_text.dart';
import 'package:whitenoise/widgets/wn_search_field.dart';
import 'package:whitenoise/widgets/wn_slate.dart';
import 'package:whitenoise/widgets/wn_slate_navigation_header.dart';

class UserSearchScreen extends HookConsumerWidget {
  const UserSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typographyScaled;
    final accountPubkey = ref.watch(accountPubkeyProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    final state = useUserSearch(
      accountPubkey: accountPubkey,
      searchQuery: searchQuery.value,
    );

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlate(
            header: WnSlateNavigationHeader(
              title: context.l10n.startNewChat,
              onNavigate: () => Routes.goBack(context),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(16.h),
                  WnSearchField(
                    placeholder: context.l10n.searchByNameOrNpub,
                    controller: searchController,
                    onChanged: (value) => searchQuery.value = value,
                    onScan: () => Routes.pushToScanNpub(context),
                    isLoading: state.isSearching,
                  ),
                  Expanded(
                    child: state.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: colors.backgroundContentPrimary,
                              strokeCap: StrokeCap.round,
                            ),
                          )
                        : state.users.isEmpty
                        ? Center(
                            child: Text(
                              state.hasSearchQuery
                                  ? context.l10n.noResults
                                  : context.l10n.noFollowsYet,
                              style: typography.medium14.copyWith(
                                color: colors.backgroundContentTertiary,
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              ListView.builder(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                itemCount: state.users.length,
                                itemBuilder: (context, index) {
                                  final user = state.users[index];
                                  return _UserListTile(
                                    user: user,
                                    onTap: () => Routes.pushToStartChat(
                                      context,
                                      user.pubkey,
                                      metadata: user.metadata,
                                    ),
                                  );
                                },
                              ),
                              WnFadeOverlay.top(color: colors.backgroundSecondary),
                              WnFadeOverlay.bottom(color: colors.backgroundSecondary),
                            ],
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

class _UserListTile extends StatelessWidget {
  const _UserListTile({
    required this.user,
    required this.onTap,
  });

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typographyScaled;
    final displayName = presentName(user.metadata);
    final formattedPubKey = formatPublicKey(npubFromHex(user.pubkey) ?? user.pubkey);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            WnAvatar(
              size: WnAvatarSize.medium,
              pictureUrl: user.metadata.picture,
              displayName: displayName,
              color: AvatarColor.fromPubkey(user.pubkey),
            ),
            Gap(8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (displayName != null)
                    Text(
                      displayName,
                      style: typography.medium16.copyWith(
                        color: colors.backgroundContentPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  else
                    WnMiddleEllipsisText(
                      text: formattedPubKey,
                      style: typography.medium16.copyWith(
                        color: colors.backgroundContentPrimary,
                      ),
                    ),
                  Gap(4.h),
                  WnMiddleEllipsisText(
                    text: formattedPubKey,
                    style: typography.medium12.copyWith(
                      color: colors.backgroundContentSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
