import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_slate_header_action.dart';

enum WnSlateHeaderType { defaultType, close, back }

class WnSlateHeader extends StatelessWidget {
  const WnSlateHeader({
    super.key,
    this.type = WnSlateHeaderType.defaultType,
    this.title,
    this.avatarUrl,
    this.onAvatarTap,
    this.onNewChatTap,
    this.onCloseTap,
    this.onBackTap,
  });

  final WnSlateHeaderType type;
  final String? title;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNewChatTap;
  final VoidCallback? onCloseTap;
  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.h,
      child: switch (type) {
        WnSlateHeaderType.defaultType => _DefaultHeader(
          avatarUrl: avatarUrl,
          onAvatarTap: onAvatarTap,
          onNewChatTap: onNewChatTap,
        ),
        WnSlateHeaderType.close => _TitleHeader(
          title: title ?? '',
          actionType: WnSlateHeaderActionType.close,
          onActionTap: onCloseTap,
        ),
        WnSlateHeaderType.back => _TitleHeader(
          title: title ?? '',
          actionType: WnSlateHeaderActionType.back,
          onActionTap: onBackTap,
        ),
      },
    );
  }
}

class _DefaultHeader extends StatelessWidget {
  const _DefaultHeader({
    this.avatarUrl,
    this.onAvatarTap,
    this.onNewChatTap,
  });

  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNewChatTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _AvatarContainer(
          avatarUrl: avatarUrl,
          onTap: onAvatarTap,
        ),
        if (onNewChatTap != null)
          WnSlateHeaderAction(
            type: WnSlateHeaderActionType.newChat,
            onPressed: onNewChatTap!,
          ),
      ],
    );
  }
}

class _AvatarContainer extends StatelessWidget {
  const _AvatarContainer({
    this.avatarUrl,
    this.onTap,
  });

  final String? avatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 80.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        alignment: Alignment.center,
        child: WnAvatar(
          pictureUrl: avatarUrl,
          size: 48.w,
        ),
      ),
    );
  }
}

class _TitleHeader extends StatelessWidget {
  const _TitleHeader({
    required this.title,
    required this.actionType,
    this.onActionTap,
  });

  final String title;
  final WnSlateHeaderActionType actionType;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isBack = actionType == WnSlateHeaderActionType.back;
    final hasAction = onActionTap != null;
    final hasLeadingAction = isBack && hasAction;
    final hasTrailingAction = !isBack && hasAction;

    return Row(
      children: [
        if (hasLeadingAction)
          WnSlateHeaderAction(
            type: actionType,
            onPressed: onActionTap!,
          ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: hasTrailingAction ? 80.w : 0,
              right: hasLeadingAction ? 80.w : 0,
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  height: 22 / 16,
                  letterSpacing: 0.2.sp,
                  color: colors.backgroundContentPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        if (hasTrailingAction)
          WnSlateHeaderAction(
            type: actionType,
            onPressed: onActionTap!,
          ),
      ],
    );
  }
}
