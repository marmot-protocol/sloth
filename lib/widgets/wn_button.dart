import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

enum WnButtonType { primary, outline, ghost, overlay, destructive }

enum WnButtonSize {
  large(56),
  medium(44),
  small(32);

  const WnButtonSize(this.height);
  final double height;
}

class WnButton extends StatelessWidget {
  const WnButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = WnButtonType.primary,
    this.size = WnButtonSize.large,
    this.loading = false,
    this.disabled = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String text;
  final VoidCallback? onPressed;
  final WnButtonType type;
  final WnButtonSize size;
  final bool loading;
  final bool disabled;
  final WnIcons? leadingIcon;
  final WnIcons? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return switch (type) {
      WnButtonType.primary => _buildPrimaryButton(colors),
      WnButtonType.outline => _buildOutlineButton(colors),
      WnButtonType.ghost => _buildGhostButton(colors),
      WnButtonType.overlay => _buildOverlayButton(colors),
      WnButtonType.destructive => _buildDestructiveButton(colors),
    };
  }

  Widget _buildPrimaryButton(SemanticColors colors) {
    final bgColor = disabled ? colors.fillPrimary.withValues(alpha: 0.25) : colors.fillPrimary;
    final contentColor = disabled
        ? colors.fillContentPrimary.withValues(alpha: 0.25)
        : colors.fillContentPrimary;

    return _buildButton(
      backgroundColor: bgColor,
      overlayColor: colors.fillPrimaryHover,
      contentColor: contentColor,
      borderSide: BorderSide.none,
    );
  }

  Widget _buildOutlineButton(SemanticColors colors) {
    final borderColor = disabled
        ? colors.borderTertiary.withValues(alpha: 0.25)
        : colors.borderTertiary;
    final bgColor = disabled ? colors.fillSecondary.withValues(alpha: 0.25) : colors.fillSecondary;
    final contentColor = disabled
        ? colors.fillContentSecondary.withValues(alpha: 0.25)
        : colors.fillContentSecondary;

    return _buildButton(
      backgroundColor: bgColor,
      overlayColor: colors.fillSecondaryHover,
      contentColor: contentColor,
      borderSide: BorderSide(color: borderColor),
    );
  }

  Widget _buildGhostButton(SemanticColors colors) {
    final contentColor = disabled
        ? colors.fillContentSecondary.withValues(alpha: 0.25)
        : colors.fillContentSecondary;

    return _buildButton(
      backgroundColor: colors.fillTertiary,
      overlayColor: colors.fillTertiaryHover,
      contentColor: contentColor,
      borderSide: BorderSide.none,
    );
  }

  Widget _buildOverlayButton(SemanticColors colors) {
    final bgColor = disabled
        ? colors.fillQuaternary.withValues(alpha: 0.25)
        : colors.fillQuaternary;
    final contentColor = disabled
        ? colors.backgroundContentPrimary.withValues(alpha: 0.25)
        : colors.backgroundContentPrimary;

    return _buildButton(
      backgroundColor: bgColor,
      overlayColor: colors.fillQuaternaryHover,
      contentColor: contentColor,
      borderSide: BorderSide.none,
    );
  }

  Widget _buildDestructiveButton(SemanticColors colors) {
    final borderColor = disabled
        ? colors.borderDestructivePrimary.withValues(alpha: 0.25)
        : colors.borderDestructivePrimary;
    final bgColor = disabled
        ? colors.fillDestructive.withValues(alpha: 0.25)
        : colors.fillDestructive;
    final contentColor = disabled
        ? colors.fillContentDestructive.withValues(alpha: 0.25)
        : colors.fillContentDestructive;

    return _buildButton(
      backgroundColor: bgColor,
      overlayColor: colors.fillDestructiveHover,
      contentColor: contentColor,
      borderSide: BorderSide(color: borderColor),
    );
  }

  Widget _buildButton({
    required Color backgroundColor,
    required Color overlayColor,
    required Color contentColor,
    required BorderSide borderSide,
  }) {
    final verticalPadding = _getVerticalPadding();
    final iconSize = _getIconSize();
    final fontSize = _getFontSize();
    final iconPadding = size == WnButtonSize.small ? 4.w : 8.w;

    return FilledButton(
      onPressed: (loading || disabled) ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 8.w),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
          side: borderSide,
        ),
        overlayColor: overlayColor,
      ),
      child: loading
          ? _buildLoadingIndicator(contentColor)
          : _buildContent(contentColor, iconSize, fontSize, iconPadding),
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    final indicatorSize = size == WnButtonSize.small ? 14.w : 18.w;
    return SizedBox.square(
      dimension: indicatorSize,
      child: CircularProgressIndicator(
        key: const Key('loading_indicator'),
        strokeWidth: 2.w,
        strokeCap: StrokeCap.round,
        color: color,
      ),
    );
  }

  Widget _buildContent(Color contentColor, double iconSize, double fontSize, double iconPadding) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isBounded = constraints.maxWidth.isFinite;
        final textWidget = Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: fontSize,
            color: contentColor,
            letterSpacing: 0.4,
            height: 20 / 14,
          ),
          overflow: TextOverflow.ellipsis,
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              WnIcon(
                leadingIcon!,
                size: iconSize,
                color: contentColor,
                key: const Key('leading_icon'),
              ),
              SizedBox(width: iconPadding),
            ],
            if (isBounded) Flexible(child: textWidget) else textWidget,
            if (trailingIcon != null) ...[
              SizedBox(width: iconPadding),
              WnIcon(
                trailingIcon!,
                size: iconSize,
                color: contentColor,
                key: const Key('trailing_icon'),
              ),
            ],
          ],
        );
      },
    );
  }

  double _getVerticalPadding() {
    return switch (size) {
      WnButtonSize.large => 18.h,
      WnButtonSize.medium => 12.h,
      WnButtonSize.small => 6.h,
    };
  }

  double _getIconSize() {
    return switch (size) {
      WnButtonSize.large => 18.w,
      WnButtonSize.medium => 18.w,
      WnButtonSize.small => 16.w,
    };
  }

  double _getFontSize() {
    return switch (size) {
      WnButtonSize.large => 14.sp,
      WnButtonSize.medium => 14.sp,
      WnButtonSize.small => 12.sp,
    };
  }
}
