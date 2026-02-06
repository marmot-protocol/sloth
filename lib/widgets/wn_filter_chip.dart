import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whitenoise/theme.dart';

enum WnFilterChipVariant { standard, elevated }

class WnFilterChip extends HookWidget {
  const WnFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.variant = WnFilterChipVariant.standard,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final WnFilterChipVariant variant;

  @override
  Widget build(BuildContext context) {
    final hover = useState(false);
    final colors = context.colors;

    final backgroundColor = _getBackgroundColor(colors, selected, hover.value);
    final borderColor = _getBorderColor(colors, selected);
    final boxShadow = _getBoxShadow(colors, variant);

    return MouseRegion(
      onEnter: (_) => hover.value = true,
      onExit: (_) => hover.value = false,
      child: GestureDetector(
        onTap: () => onSelected(!selected),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 32.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: borderColor),
            boxShadow: boxShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: context.typographyScaled.medium14.copyWith(
                  color: colors.fillContentSecondary,
                  letterSpacing: 0.4.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(SemanticColors colors, bool selected, bool isHovered) {
    if (selected || isHovered) {
      return colors.fillTertiaryActive;
    }
    return colors.backgroundPrimary;
  }

  Color _getBorderColor(SemanticColors colors, bool selected) {
    if (selected) {
      return colors.borderSecondary;
    }
    return colors.borderTertiary;
  }

  List<BoxShadow>? _getBoxShadow(SemanticColors colors, WnFilterChipVariant variant) {
    if (variant == WnFilterChipVariant.elevated) {
      return [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, 1),
          blurRadius: 3.r,
        ),
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, 1),
          blurRadius: 2.r,
          spreadRadius: (-1).r,
        ),
      ];
    }
    return null;
  }
}
