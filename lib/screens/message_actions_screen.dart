import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sloth/src/rust/api/messages.dart' show ChatMessage;
import 'package:sloth/theme.dart';
import 'package:sloth/theme/semantic_colors.dart';
import 'package:sloth/widgets/wn_emoji_picker.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_message_bubble.dart';
import 'package:sloth/widgets/wn_outlined_button.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class MessageActionsScreen extends HookWidget {
  const MessageActionsScreen({
    super.key,
    required this.message,
    required this.pubkey,
    required this.onReaction,
    this.onDelete,
  });

  final ChatMessage message;
  final String pubkey;
  final Future<void> Function(String emoji) onReaction;
  final Future<void> Function()? onDelete;

  static Future<void> show(
    BuildContext context, {
    required ChatMessage message,
    required String pubkey,
    required Future<void> Function(String emoji) onReaction,
    Future<void> Function()? onDelete,
  }) {
    final colors = context.colors;

    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: colors.backgroundPrimary.withValues(alpha: 0.8),
        pageBuilder: (menuContext, _, _) {
          return MessageActionsScreen(
            message: message,
            pubkey: pubkey,
            onReaction: onReaction,
            onDelete: onDelete,
          );
        },
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showEmojiPicker = useState(false);

    final isOwnMessage = message.pubkey == pubkey;
    final selectedEmojis = message.reactions.userReactions
        .where((r) => r.user == pubkey)
        .map((r) => r.emoji)
        .toSet();

    Future<void> handleDelete() async {
      try {
        await onDelete?.call();
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete message. Please try again.'),
            ),
          );
        }
      }
      if (context.mounted) Navigator.of(context).pop();
    }

    Future<void> handleReaction(String emoji) async {
      try {
        await onReaction(emoji);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send reaction. Please try again.'),
            ),
          );
        }
      }
      if (context.mounted) Navigator.of(context).pop();
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                mainAxisAlignment: showEmojiPicker.value
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.center,
                children: [
                  MessageActionsModal(
                    message: message,
                    isOwnMessage: isOwnMessage,
                    onClose: () => Navigator.of(context).pop(),
                    currentUserPubkey: pubkey,
                    onDelete: (isOwnMessage && onDelete != null) ? handleDelete : null,
                    onReaction: handleReaction,
                    onEmojiPicker: () => showEmojiPicker.value = !showEmojiPicker.value,
                    selectedEmojis: selectedEmojis,
                  ),
                ],
              ),
            ),
          ),
          if (showEmojiPicker.value)
            WnEmojiPicker(
              onClose: () => showEmojiPicker.value = false,
              onEmojiSelected: handleReaction,
            ),
        ],
      ),
    );
  }
}

class MessageActionsModal extends StatelessWidget {
  const MessageActionsModal({
    super.key,
    required this.message,
    required this.isOwnMessage,
    required this.onClose,
    required this.onReaction,
    required this.onEmojiPicker,
    required this.currentUserPubkey,
    this.onDelete,
    this.selectedEmojis = const {},
  });

  final ChatMessage message;
  final bool isOwnMessage;
  final VoidCallback onClose;
  final void Function(String emoji) onReaction;
  final VoidCallback onEmojiPicker;
  final String currentUserPubkey;
  final VoidCallback? onDelete;
  final Set<String> selectedEmojis;

  static const List<String> reactions = [
    '❤',
    '👍',
    '👎',
    '😂',
    '🚀',
    '😢',
    '🔥',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return WnSlateContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Message actions',
                style: TextStyle(
                  color: colors.backgroundContentPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                key: const Key('close_button'),
                onTap: onClose,
                child: WnIcon(
                  WnIcons.closeLarge,
                  color: colors.backgroundContentPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          WnMessageBubble(
            message: message,
            isOwnMessage: isOwnMessage,
            currentUserPubkey: currentUserPubkey,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...reactions.map(
                (emoji) => _ReactionButton(
                  key: Key('reaction_$emoji'),
                  colors: colors,
                  emoji: emoji,
                  isSelected: selectedEmojis.contains(emoji),
                  onTap: () => onReaction(emoji),
                ),
              ),
              GestureDetector(
                key: const Key('emoji_picker_button'),
                onTap: onEmojiPicker,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  child: WnIcon(
                    WnIcons.addEmoji,
                    color: colors.backgroundContentPrimary,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          WnOutlinedButton(
            key: const Key('reply_button'),
            text: 'Reply',
            onPressed: onClose,
          ),
          if (onDelete != null) ...[
            Gap(8.h),
            WnOutlinedButton(
              key: const Key('delete_button'),
              text: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    super.key,
    required this.colors,
    required this.emoji,
    required this.onTap,
    this.isSelected = false,
  });

  final SemanticColors colors;
  final String emoji;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: isSelected
            ? BoxDecoration(
                color: colors.fillTertiaryActive,
                borderRadius: BorderRadius.circular(8.r),
              )
            : null,
        child: Text(
          emoji,
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    );
  }
}
