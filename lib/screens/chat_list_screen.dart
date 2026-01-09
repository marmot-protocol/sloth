import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/hooks/use_chat_list.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/src/rust/api/chat_list.dart' show ChatSummary;
import 'package:sloth/widgets/chat_list_tile.dart';
import 'package:sloth/widgets/wn_account_bar.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class ChatListScreen extends HookConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final chatListResult = useChatList(pubkey);

    final chatList = chatListResult.chats;
    final isLoading = chatListResult.isLoading;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const WnSlateContainer(child: WnAccountBar()),
            Expanded(child: _buildContent(context, chatList, isLoading)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<ChatSummary> chatList,
    bool isLoading,
  ) {
    final colors = context.colors;

    if (isLoading && chatList.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: colors.foregroundPrimary),
      );
    }

    if (chatList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No chats yet',
              style: TextStyle(
                color: colors.foregroundPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation',
              style: TextStyle(color: colors.foregroundTertiary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        final chatSummary = chatList[index];
        return ChatListTile(
          key: Key(chatSummary.mlsGroupId),
          chatSummary: chatSummary,
        );
      },
    );
  }
}
