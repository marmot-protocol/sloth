import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/src/rust/api/messages.dart';

class WnMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isOwnMessage;

  const WnMessageBubble({
    super.key,
    required this.message,
    required this.isOwnMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary.withValues(alpha: isOwnMessage ? 0.9 : 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isOwnMessage ? colors.foregroundSecondary : colors.foregroundPrimary,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
