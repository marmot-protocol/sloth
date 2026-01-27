import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_user_search.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/src/rust/api/users.dart' show User;
import 'package:sloth/theme.dart';
import 'package:sloth/utils/formatting.dart' show formatPublicKey, npubFromHex;
import 'package:sloth/utils/metadata.dart' show presentName;
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_fade_overlay.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_search_field.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class UserSearchScreen extends HookConsumerWidget {
  const UserSearchScreen({super.key});

  static void _handleUserTap(BuildContext context, String pubkey) {
    Routes.pushToWip(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final accountPubkey = ref.watch(accountPubkeyProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    final state = useUserSearch(accountPubkey, searchQuery.value);

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
                WnScreenHeader(title: context.l10n.startNewChat),
                Gap(16.h),
                WnSearchField(
                  placeholder: 'npub1...',
                  controller: searchController,
                  onChanged: (value) => searchQuery.value = value,
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
                            style: TextStyle(color: colors.backgroundContentTertiary),
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
                                  onTap: () => _handleUserTap(context, user.pubkey),
                                );
                              },
                            ),
                            WnFadeOverlay.top(color: colors.backgroundTertiary),
                            WnFadeOverlay.bottom(color: colors.backgroundTertiary),
                          ],
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
    final displayName = presentName(user.metadata);
    final hasDisplayName = displayName != null;
    final formattedPubKey = formatPublicKey(npubFromHex(user.pubkey) ?? user.pubkey);

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: WnAvatar(
        pictureUrl: user.metadata.picture,
        displayName: displayName,
        animated: true,
      ),
      title: hasDisplayName
          ? Text(
              displayName,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: colors.backgroundContentPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            )
          : Text(
              formattedPubKey,
              style: TextStyle(
                fontSize: 12.sp,
                color: colors.backgroundContentTertiary,
              ),
            ),
      subtitle: hasDisplayName
          ? Text(
              formattedPubKey,
              style: TextStyle(
                fontSize: 14.sp,
                color: colors.backgroundContentTertiary,
                fontWeight: FontWeight.w500,
              ),
            )
          : null,
    );
  }
}
