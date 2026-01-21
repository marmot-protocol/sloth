import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sloth/theme.dart';

class WnDropdownOption<T> {
  const WnDropdownOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

enum WnDropdownSize {
  small, // 44px dropdown, 44px items
  large, // 56px dropdown, 48px items
}

class WnDropdownSelector<T> extends StatefulWidget {
  const WnDropdownSelector({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.size = WnDropdownSize.small,
    this.helperText,
    this.isError = false,
    this.isDisabled = false,
  });

  final String label;
  final List<WnDropdownOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final WnDropdownSize size;
  final String? helperText;
  final bool isError;
  final bool isDisabled;

  @override
  State<WnDropdownSelector<T>> createState() => _WnDropdownSelectorState<T>();
}

class _WnDropdownSelectorState<T> extends State<WnDropdownSelector<T>>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  double get _dropdownHeight => widget.size == WnDropdownSize.small ? 44.h : 56.h;
  double get _itemHeight => widget.size == WnDropdownSize.small ? 44.h : 48.h;
  static const int _maxVisibleItems = 5;

  String get _selectedLabel {
    final selected = widget.options.where((o) => o.value == widget.value);
    return selected.isNotEmpty ? selected.first.label : '';
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WnDropdownSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Close dropdown if it becomes disabled while open
    if (!oldWidget.isDisabled && widget.isDisabled && _isOpen) {
      setState(() {
        _isOpen = false;
        _isHovered = false;
      });
      _animationController.reverse();
    }
  }

  void _toggleDropdown() {
    if (widget.isDisabled) return;

    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _selectOption(T value) {
    if (widget.isDisabled) return;

    setState(() {
      _isOpen = false;
      _animationController.reverse();
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final borderColor = widget.isDisabled
        ? colors.borderSecondary
        : widget.isError
        ? colors.borderDestructivePrimary
        : (_isHovered || _isOpen)
        ? colors.borderPrimary
        : colors.borderSecondary;

    final textColor = widget.isDisabled
        ? colors.backgroundContentTertiary
        : colors.backgroundContentPrimary;

    final iconColor = widget.isDisabled
        ? colors.backgroundContentTertiary
        : colors.backgroundContentPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14.sp,
            color: widget.isDisabled
                ? colors.backgroundContentTertiary
                : colors.backgroundContentPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap(4.h),
        MouseRegion(
          onEnter: (_) {
            if (!widget.isDisabled) setState(() => _isHovered = true);
          },
          onExit: (_) {
            if (!widget.isDisabled) setState(() => _isHovered = false);
          },
          child: AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              final totalOptionsHeight = widget.options.length * _itemHeight;
              final maxOptionsHeight = _maxVisibleItems * _itemHeight;
              final constrainedOptionsHeight = totalOptionsHeight < maxOptionsHeight
                  ? totalOptionsHeight
                  : maxOptionsHeight;
              final animatedOptionsHeight = constrainedOptionsHeight * _expandAnimation.value;
              final currentHeight = _dropdownHeight + animatedOptionsHeight;

              return Container(
                // Add 2 for border (1px top + 1px bottom)
                height: currentHeight + 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: borderColor),
                  color: widget.isDisabled ? colors.backgroundSecondary : colors.backgroundPrimary,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Header / Field
                    GestureDetector(
                      onTap: _toggleDropdown,
                      child: Container(
                        height: _dropdownHeight,
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedLabel,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 24.sp,
                              child: Icon(
                                _isOpen ? Icons.close : Icons.keyboard_arrow_down,
                                key: const Key('dropdown_icon'),
                                color: iconColor,
                                size: 24.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Options
                    if (_expandAnimation.value > 0)
                      SizedBox(
                        height: animatedOptionsHeight,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          itemCount: widget.options.length,
                          itemBuilder: (context, index) {
                            final option = widget.options[index];
                            final isSelected = option.value == widget.value;
                            final isLast = index == widget.options.length - 1;
                            return _DropdownItem(
                              label: option.label,
                              isSelected: isSelected,
                              isDisabled: widget.isDisabled,
                              height: _itemHeight,
                              onTap: () => _selectOption(option.value),
                              isLast: isLast,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        if (widget.helperText != null) ...[
          Gap(4.h),
          Text(
            widget.helperText!,
            style: TextStyle(
              fontSize: 12.sp,
              color: widget.isError
                  ? colors.backgroundContentDestructive
                  : colors.backgroundContentSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _DropdownItem extends StatefulWidget {
  const _DropdownItem({
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.height,
    required this.onTap,
    this.isLast = false,
  });

  final String label;
  final bool isSelected;
  final bool isDisabled;
  final double height;
  final VoidCallback onTap;
  final bool isLast;

  @override
  State<_DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<_DropdownItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Selected items get a background highlight
    final backgroundColor = widget.isSelected ? colors.fillSecondary : colors.backgroundPrimary;

    // Show checkmark for selected or hovered items (not when disabled)
    final showCheckmark = !widget.isDisabled && (widget.isSelected || _isHovered);

    return MouseRegion(
      onEnter: (_) {
        if (!widget.isDisabled) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (!widget.isDisabled) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTap: widget.isDisabled ? null : widget.onTap,
        child: Container(
          height: widget.height,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: widget.isLast
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(7.r),
                    bottomRight: Radius.circular(7.r),
                  )
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.backgroundContentPrimary,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
              SizedBox(
                width: 24.sp,
                child: showCheckmark
                    ? Icon(
                        Icons.check,
                        color: colors.backgroundContentPrimary,
                        size: 24.sp,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
