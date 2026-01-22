import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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

class WnDropdownSelector<T> extends HookWidget {
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
  Widget build(BuildContext context) {
    final colors = context.colors;

    final dropdownHeight = size == WnDropdownSize.small ? 44.h : 56.h;
    final itemHeight = size == WnDropdownSize.small ? 44.h : 48.h;
    const maxVisibleItems = 5;

    final isOpen = useState(false);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 120),
    );

    final expandAnimation = useMemoized(
      () => CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      [animationController],
    );

    // Close dropdown if it becomes disabled while open
    useEffect(() {
      if (isDisabled && isOpen.value) {
        isOpen.value = false;
        animationController.reverse();
      }
      return null;
    }, [isDisabled]);

    final selectedLabel = useMemoized(() {
      final selected = options.where((o) => o.value == value);
      return selected.isNotEmpty ? selected.first.label : '';
    }, [options, value]);

    void toggleDropdown() {
      if (isDisabled) return;

      isOpen.value = !isOpen.value;
      if (isOpen.value) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
    }

    void selectOption(T optionValue) {
      if (isDisabled) return;

      isOpen.value = false;
      animationController.reverse();
      onChanged(optionValue);
    }

    final borderColor = isDisabled
        ? colors.borderSecondary
        : isError
        ? colors.borderDestructivePrimary
        : isOpen.value
        ? colors.borderPrimary
        : colors.borderSecondary;

    final textColor = isDisabled
        ? colors.backgroundContentTertiary
        : colors.backgroundContentPrimary;

    final iconColor = isDisabled
        ? colors.backgroundContentTertiary
        : colors.backgroundContentPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: isDisabled ? colors.backgroundContentTertiary : colors.backgroundContentPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap(4.h),
        AnimatedBuilder(
          animation: expandAnimation,
          builder: (context, child) {
            final totalOptionsHeight = options.length * itemHeight;
            final maxOptionsHeight = maxVisibleItems * itemHeight;
            final constrainedOptionsHeight = totalOptionsHeight < maxOptionsHeight
                ? totalOptionsHeight
                : maxOptionsHeight;
            final animatedOptionsHeight = constrainedOptionsHeight * expandAnimation.value;
            final currentHeight = dropdownHeight + animatedOptionsHeight;

            return Container(
              height: currentHeight + 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: borderColor),
                color: isDisabled ? colors.backgroundSecondary : colors.backgroundPrimary,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: toggleDropdown,
                    child: Container(
                      height: dropdownHeight,
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedLabel,
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
                              isOpen.value ? Icons.close : Icons.keyboard_arrow_down,
                              key: const Key('dropdown_icon'),
                              color: iconColor,
                              size: 24.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (expandAnimation.value > 0)
                    SizedBox(
                      height: animatedOptionsHeight,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options[index];
                          final isSelected = option.value == value;
                          final isLast = index == options.length - 1;
                          return _DropdownItem(
                            label: option.label,
                            isSelected: isSelected,
                            height: itemHeight,
                            onTap: () => selectOption(option.value),
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
        if (helperText != null) ...[
          Gap(4.h),
          Text(
            helperText!,
            style: TextStyle(
              fontSize: 12.sp,
              color: isError
                  ? colors.backgroundContentDestructive
                  : colors.backgroundContentSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _DropdownItem extends StatelessWidget {
  const _DropdownItem({
    required this.label,
    required this.isSelected,
    required this.height,
    required this.onTap,
    this.isLast = false,
  });

  final String label;
  final bool isSelected;
  final double height;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final backgroundColor = isSelected ? colors.fillSecondary : colors.backgroundPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: isLast
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
                label,
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
              child: isSelected
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
    );
  }
}
