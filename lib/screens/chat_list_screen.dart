import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:whitenoise/hooks/use_chat_list.dart';
import 'package:whitenoise/hooks/use_system_notice.dart';
import 'package:whitenoise/providers/account_pubkey_provider.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/utils/chat_search.dart';
import 'package:whitenoise/widgets/chat_list_tile.dart';
import 'package:whitenoise/widgets/wn_account_bar.dart';
import 'package:whitenoise/widgets/wn_chat_list.dart';
import 'package:whitenoise/widgets/wn_search_and_filters.dart';
import 'package:whitenoise/widgets/wn_slate.dart';
import 'package:whitenoise/widgets/wn_system_notice.dart';

const _slateHeight = 80;
const _searchAndFiltersHeight = 108;

class ChatListScreen extends HookConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final chatListResult = useChatList(pubkey);
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final notice = useSystemNotice();
    final searchQuery = useState('');

    final chatList = chatListResult.chats;
    final filteredChats = filterChatsBySearch(chatList, searchQuery.value);
    final isLoading = chatListResult.isLoading;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Stack(
        children: [
          WnChatList(
            itemCount: filteredChats.length,
            isLoading: isLoading,
            topPadding: safeAreaTop + _slateHeight.h,
            header: WnSearchAndFilters(
              onSearchChanged: (value) => searchQuery.value = value,
            ),
            headerHeight: _searchAndFiltersHeight.h,
            itemBuilder: (context, index) {
              final chatSummary = filteredChats[index];
              return ChatListTile(
                key: Key(chatSummary.mlsGroupId),
                chatSummary: chatSummary,
                onChatListChanged: chatListResult.refresh,
                onError: notice.showErrorNotice,
              );
            },
          ),
          const SafeArea(
            bottom: false,
            child: WnSlate(header: WnAccountBar()),
          ),
          if (notice.noticeMessage != null)
            SafeArea(
              bottom: false,
              child: WnSystemNotice(
                key: ValueKey(notice.noticeMessage),
                title: notice.noticeMessage!,
                type: notice.noticeType,
                onDismiss: notice.dismissNotice,
              ),
            ),
        ],
      ),
    );
  }
}
