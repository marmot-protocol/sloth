import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:whitenoise/hooks/use_chat_list.dart';
import 'package:whitenoise/l10n/l10n.dart';
import 'package:whitenoise/providers/account_pubkey_provider.dart';
import 'package:whitenoise/src/rust/api/chat_list.dart' show ChatSummary;
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/chat_list_tile.dart';
import 'package:whitenoise/widgets/wn_account_bar.dart';
import 'package:whitenoise/widgets/wn_slate.dart';

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
            const WnSlate(header: WnAccountBar()),
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
    final typography = context.typographyScaled;

    if (isLoading && chatList.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: colors.backgroundContentPrimary),
      );
    }

    if (chatList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.noChatsYet,
              style: typography.medium18.copyWith(
                color: colors.backgroundContentPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.startConversation,
              style: typography.medium14.copyWith(
                color: colors.backgroundContentTertiary,
              ),
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
