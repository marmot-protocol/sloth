import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sloth/src/rust/api/messages.dart' show ChatMessage;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_message_bubble.dart';
import 'package:sloth/widgets/wn_outlined_button.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class WnMessageMenu extends StatelessWidget {
  const WnMessageMenu({
    super.key,
    required this.message,
    required this.isOwnMessage,
    required this.onClose,
    this.onDelete,
  });

  final ChatMessage message;
  final bool isOwnMessage;
  final VoidCallback onClose;
  final VoidCallback? onDelete;

  static const List<String> reactions = [
    '❤️',
    '👍️',
    '👎️',
    '😂️',
    '🚀',
    '😢',
    '🔥',
  ];

  static Future<void> show(
    BuildContext context, {
    required ChatMessage message,
    required String pubkey,
    Future<void> Function()? onDelete,
  }) {
    final colors = context.colors;
    final isOwnMessage = message.pubkey == pubkey;

    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: colors.backgroundPrimary.withValues(alpha: 0.8),
        pageBuilder: (menuContext, _, _) {
          Future<void> handleDelete() async {
            try {
              await onDelete?.call();
            } catch (_) {
              if (menuContext.mounted) {
                ScaffoldMessenger.of(menuContext).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete message. Please try again.'),
                  ),
                );
              }
            }
            if (menuContext.mounted) Navigator.of(menuContext).pop();
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WnMessageMenu(
                    message: message,
                    isOwnMessage: isOwnMessage,
                    onClose: () => Navigator.of(menuContext).pop(),
                    onDelete: isOwnMessage ? handleDelete : null,
                  ),
                ],
              ),
            ),
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
    final colors = context.colors;

    return WnSlateContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MessageMenuHeader(colors: colors, onClose: onClose),
          SizedBox(height: 12.h),
          WnMessageBubble(
            message: message,
            isOwnMessage: isOwnMessage,
          ),
          SizedBox(height: 16.h),
          _ReactionsRow(colors: colors, reactions: reactions, onTap: onClose),
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

class _MessageMenuHeader extends StatelessWidget {
  const _MessageMenuHeader({
    required this.colors,
    required this.onClose,
  });

  final SemanticColors colors;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: Icon(
            Icons.close,
            color: colors.backgroundContentPrimary,
            size: 24.w,
          ),
        ),
      ],
    );
  }
}

class _ReactionsRow extends StatelessWidget {
  const _ReactionsRow({
    required this.colors,
    required this.reactions,
    required this.onTap,
  });

  final SemanticColors colors;
  final List<String> reactions;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...reactions.map(
          (emoji) => _ReactionButton(colors: colors, emoji: emoji, onTap: onTap),
        ),
        _EmojiPickerButton(colors: colors, onTap: onTap),
      ],
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.colors,
    required this.emoji,
    required this.onTap,
  });

  final SemanticColors colors;
  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('reaction_$emoji'),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        child: Text(
          emoji,
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    );
  }
}

class _EmojiPickerButton extends StatelessWidget {
  const _EmojiPickerButton({
    required this.colors,
    required this.onTap,
  });

  final SemanticColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('emoji_picker_button'),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        child: Icon(
          Icons.add_reaction_outlined,
          color: colors.backgroundContentPrimary,
          size: 20.sp,
        ),
      ),
    );
  }
}
