import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/theme.dart';

class WnMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isOwnMessage;
  final VoidCallback? onLongPress;

  const WnMessageBubble({
    super.key,
    required this.message,
    required this.isOwnMessage,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;

    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isOwnMessage ? colors.fillPrimary : colors.fillSecondary,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              color: isOwnMessage ? colors.fillContentPrimary : colors.fillContentSecondary,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}
