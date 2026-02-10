import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:whitenoise/hooks/use_chat_list.dart';
import 'package:whitenoise/providers/account_pubkey_provider.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/chat_list_tile.dart';
import 'package:whitenoise/widgets/wn_account_bar.dart';
import 'package:whitenoise/widgets/wn_chat_list.dart';
import 'package:whitenoise/widgets/wn_search_and_filters.dart';
import 'package:whitenoise/widgets/wn_slate.dart';

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

    final chatList = chatListResult.chats;
    final isLoading = chatListResult.isLoading;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Stack(
        children: [
          WnChatList(
            itemCount: chatList.length,
            isLoading: isLoading,
            topPadding: safeAreaTop + _slateHeight.h,
            header: const WnSearchAndFilters(),
            headerHeight: _searchAndFiltersHeight.h,
            itemBuilder: (context, index) {
              final chatSummary = chatList[index];
              return ChatListTile(
                key: Key(chatSummary.mlsGroupId),
                chatSummary: chatSummary,
                onChatListChanged: chatListResult.refresh,
              );
            },
          ),
          const SafeArea(
            bottom: false,
            child: WnSlate(header: WnAccountBar()),
          ),
        ],
      ),
    );
  }
}
