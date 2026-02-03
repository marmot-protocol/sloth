import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';

enum WnListItemType {
  neutral,
  success,
  warning,
  error,
}

class WnListItemAction {
  const WnListItemAction({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
}

class WnListItem extends StatefulWidget {
  const WnListItem({
    super.key,
    required this.title,
    this.type = WnListItemType.neutral,
    this.showIcon = false,
    this.onTap,
    this.actions,
  });

  final String title;
  final WnListItemType type;
  final bool showIcon;
  final VoidCallback? onTap;
  final List<WnListItemAction>? actions;

  @override
  State<WnListItem> createState() => _WnListItemState();
}

class _WnListItemState extends State<WnListItem> {
  bool _isExpanded = false;
  bool _isPressed = false;

  Color _getBackgroundColor(SemanticColors colors) {
    if (_isExpanded) {
      return colors.fillSecondaryActive;
    }
    if (_isPressed) {
      return colors.fillSecondaryHover;
    }
    return colors.fillSecondary;
  }

  Widget? _buildLeadingIcon(SemanticColors colors) {
    if (!widget.showIcon) return null;

    final (IconData icon, Color color) = switch (widget.type) {
      WnListItemType.neutral => (Icons.circle_outlined, colors.fillContentTertiary),
      WnListItemType.success => (Icons.check_circle, colors.intentionSuccessContent),
      WnListItemType.warning => (Icons.warning, colors.intentionWarningContent),
      WnListItemType.error => (Icons.error, colors.intentionErrorContent),
    };

    return Icon(
      icon,
      key: const Key('list_item_type_icon'),
      size: 20.w,
      color: color,
    );
  }

  Widget _buildExpandedActions(SemanticColors colors) {
    final actions = widget.actions ?? [];
    return Row(
      key: const Key('list_item_expanded_actions'),
      mainAxisSize: MainAxisSize.min,
      spacing: 4.w,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () {
            action.onTap();
            setState(() => _isExpanded = false);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 32.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: action.isDestructive ? colors.fillDestructive : colors.fillPrimary,
              borderRadius: BorderRadius.circular(6.r),
            ),
            alignment: Alignment.center,
            child: Text(
              action.label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: action.isDestructive
                    ? colors.fillContentDestructive
                    : colors.fillContentPrimary,
                height: 18 / 14,
                letterSpacing: 0.4.sp,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final leadingIcon = _buildLeadingIcon(colors);
    final hasActions = widget.actions != null && widget.actions!.isNotEmpty;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: _getBackgroundColor(colors),
          borderRadius: BorderRadius.circular(8.r),
        ),
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.only(left: 14.w, right: 6.w),
        child: Row(
          children: [
            if (leadingIcon != null)
              Padding(
                key: const Key('list_item_leading'),
                padding: EdgeInsets.only(right: 8.w),
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: leadingIcon,
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.fillContentSecondary,
                    height: 18 / 14,
                    letterSpacing: 0.4.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (_isExpanded && hasActions)
              _buildExpandedActions(colors)
            else if (hasActions)
              GestureDetector(
                key: const Key('list_item_menu_button'),
                onTap: () => setState(() => _isExpanded = true),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: Icon(
                      Icons.more_vert,
                      key: const Key('list_item_menu_icon'),
                      size: 18.w,
                      color: colors.fillContentTertiary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
