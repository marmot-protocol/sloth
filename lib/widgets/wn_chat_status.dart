import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

enum ChatStatusType { sent, delivered, read, failed, request, unreadCount }

class WnChatStatus extends HookWidget {
  const WnChatStatus({
    super.key,
    required this.status,
    this.unreadCount,
  });

  final ChatStatusType status;
  final int? unreadCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final icon = useMemoized(() {
      return switch (status) {
        ChatStatusType.sent => WnIcons.checkmarkDashed,
        ChatStatusType.delivered => WnIcons.checkmarkOutline,
        ChatStatusType.read => WnIcons.checkmarkFilled,
        ChatStatusType.failed => WnIcons.error,
        ChatStatusType.request => WnIcons.addFilled,
        ChatStatusType.unreadCount => null,
      };
    }, [status]);

    if (status == ChatStatusType.unreadCount) {
      return _UnreadCountBadge(
        key: const Key('chat_status_unread_badge'),
        count: unreadCount ?? 0,
        colors: colors,
      );
    }

    return SizedBox(
      key: const Key('chat_status_icon'),
      width: 18.w,
      height: 18.h,
      child: Center(
        child: WnIcon(
          icon!,
          key: const Key('chat_status_wn_icon'),
          size: 18.r,
          color: colors.backgroundContentSecondary,
        ),
      ),
    );
  }
}

class _UnreadCountBadge extends StatelessWidget {
  const _UnreadCountBadge({
    super.key,
    required this.count,
    required this.colors,
  });

  final int count;
  final SemanticColors colors;

  @override
  Widget build(BuildContext context) {
    final displayText = count > 99 ? '99+' : count.toString();
    final digitCount = displayText.length;

    final width = switch (digitCount) {
      1 => 18.w,
      2 => 28.w,
      _ => 35.w,
    };

    return Container(
      key: const Key('unread_count_container'),
      width: width,
      height: 18.h,
      decoration: BoxDecoration(
        color: colors.fillPrimary,
        borderRadius: BorderRadius.circular(999.r),
      ),
      alignment: Alignment.center,
      child: Text(
        displayText,
        key: const Key('unread_count_text'),
        style: context.typographyScaled.semiBold12.copyWith(
          color: colors.fillContentPrimary,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
      ),
    );
  }
}
