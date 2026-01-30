import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

enum WnSystemNoticeType {
  neutral,
  info,
  success,
  warning,
  error,
}

enum WnSystemNoticeVariant {
  temporary,
  dismissible,
  collapsed,
  expanded,
}

class WnSystemNotice extends StatelessWidget {
  const WnSystemNotice({
    super.key,
    required this.title,
    this.description,
    this.type = WnSystemNoticeType.success,
    this.variant = WnSystemNoticeVariant.temporary,
    this.primaryAction,
    this.secondaryAction,
    this.onDismiss,
    this.onToggle,
  });

  final String title;
  final String? description;
  final WnSystemNoticeType type;
  final WnSystemNoticeVariant variant;
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final VoidCallback? onDismiss;
  final VoidCallback? onToggle;

  bool get _isCollapsed => variant == WnSystemNoticeVariant.collapsed;
  bool get _isExpanded => variant == WnSystemNoticeVariant.expanded;
  bool get _isDismissible => variant == WnSystemNoticeVariant.dismissible;
  bool get _isTemporary => variant == WnSystemNoticeVariant.temporary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (bgColor, contentColor, icon) = _getStyle(colors);
    final descriptionColor = colors.backgroundContentQuaternary;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                WnIcon(
                  icon,
                  size: 20.w,
                  color: contentColor,
                ),
                Gap(8.w),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    height: 20 / 14,
                    letterSpacing: 0.4.sp,
                    color: contentColor,
                  ),
                ),
              ),
              if (_isDismissible || _isCollapsed || _isExpanded) ...[
                Gap(8.w),
                GestureDetector(
                  onTap: _isDismissible ? onDismiss : onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: WnIcon(
                    _getActionIcon(),
                    size: 20.w,
                    color: contentColor,
                  ),
                ),
              ],
            ],
          ),
          if (!_isCollapsed &&
              !_isTemporary &&
              (description != null || primaryAction != null || secondaryAction != null)) ...[
            if (description != null) ...[
              Gap(4.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  description!,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    height: 20 / 14,
                    letterSpacing: 0.4.sp,
                    color: descriptionColor,
                  ),
                ),
              ),
            ],
            if (primaryAction != null || secondaryAction != null) ...[
              Gap(8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (secondaryAction != null) ...[
                      secondaryAction!,
                      Gap(8.h),
                    ],
                    if (primaryAction != null) primaryAction!,
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  (Color, Color, WnIcons?) _getStyle(SemanticColors colors) {
    switch (type) {
      case WnSystemNoticeType.neutral:
        return (
          colors.backgroundTertiary,
          colors.backgroundContentPrimary,
          null,
        );
      case WnSystemNoticeType.info:
        return (
          colors.intentionInfoBackground,
          colors.intentionInfoContent,
          WnIcons.informationFilled,
        );
      case WnSystemNoticeType.success:
        return (
          colors.intentionSuccessBackground,
          colors.intentionSuccessContent,
          WnIcons.checkmarkFilled,
        );
      case WnSystemNoticeType.warning:
        return (
          colors.intentionWarningBackground,
          colors.intentionWarningContent,
          WnIcons.warningFilled,
        );
      case WnSystemNoticeType.error:
        return (
          colors.intentionErrorBackground,
          colors.intentionErrorContent,
          WnIcons.errorFilled,
        );
    }
  }

  WnIcons _getActionIcon() {
    if (_isDismissible) return WnIcons.closeLarge;
    if (_isCollapsed) return WnIcons.chevronDown;
    if (_isExpanded) return WnIcons.chevronUp;
    return WnIcons.closeLarge;
  }
}
