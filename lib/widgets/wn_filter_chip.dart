import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';

enum WnFilterChipVariant { standard, elevated }

class WnFilterChip extends StatefulWidget {
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
  State<WnFilterChip> createState() => _WnFilterChipState();
}

class _WnFilterChipState extends State<WnFilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typographyScaled;

    final backgroundColor = _getBackgroundColor(colors);
    final borderColor = _getBorderColor(colors);
    final boxShadow = _getBoxShadow(colors);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onSelected(!widget.selected),
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
                widget.label,
                style: typography.medium14.copyWith(
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

  Color _getBackgroundColor(SemanticColors colors) {
    if (widget.selected || _isHovered) {
      return colors.fillTertiaryActive;
    }
    return colors.backgroundPrimary;
  }

  Color _getBorderColor(SemanticColors colors) {
    if (widget.selected) {
      return colors.borderSecondary;
    }
    return colors.borderTertiary;
  }

  List<BoxShadow>? _getBoxShadow(SemanticColors colors) {
    if (widget.variant == WnFilterChipVariant.elevated) {
      return [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, 1),
          blurRadius: 3,
        ),
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, 1),
          blurRadius: 2,
          spreadRadius: -1,
        ),
      ];
    }
    return null;
  }
}
