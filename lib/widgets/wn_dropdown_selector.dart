import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

class WnDropdownOption<T> {
  const WnDropdownOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

enum WnDropdownSize {
  small,
  large,
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
    final isPressed = useState(false);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 120),
    );

    final expandAnimation = useMemoized(
      () => CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      [animationController],
    );

    useEffect(() {
      if (isDisabled && isOpen.value) {
        isOpen.value = false;
        animationController.reverse();
      }
      return null;
    }, [isDisabled]);

    final selectedOption = useMemoized(() {
      final selected = options.where((o) => o.value == value);
      return selected.isNotEmpty ? selected.first : null;
    }, [options, value]);

    final hasSelection = selectedOption != null;

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
        ? colors.borderTertiary
        : isError
        ? colors.borderDestructivePrimary
        : isPressed.value
        ? colors.borderSecondary
        : isOpen.value
        ? colors.borderPrimary
        : colors.borderTertiary;

    final textColor = isDisabled
        ? colors.backgroundContentTertiary
        : hasSelection
        ? colors.backgroundContentPrimary
        : colors.backgroundContentSecondary;

    final iconColor = isDisabled
        ? colors.backgroundContentTertiary
        : colors.backgroundContentPrimary;

    final labelColor = isDisabled
        ? colors.backgroundContentTertiary
        : colors.backgroundContentPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: labelColor,
              fontWeight: FontWeight.w500,
              fontFamily: 'Manrope',
              letterSpacing: 0.4.sp,
              height: 20 / 14,
            ),
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
                borderRadius: isOpen.value
                    ? BorderRadius.only(
                        topLeft: Radius.circular(8.r),
                        topRight: Radius.circular(8.r),
                        bottomLeft: Radius.circular(8.r),
                        bottomRight: Radius.circular(8.r),
                      )
                    : BorderRadius.circular(8.r),
                border: Border.all(color: borderColor),
                color: isDisabled ? colors.backgroundSecondary : colors.backgroundPrimary,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: toggleDropdown,
                    onTapDown: (_) {
                      if (!isDisabled) isPressed.value = true;
                    },
                    onTapUp: (_) => isPressed.value = false,
                    onTapCancel: () => isPressed.value = false,
                    child: Container(
                      height: dropdownHeight,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Text(
                                hasSelection ? selectedOption.label : 'Select',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                  fontFamily: 'Manrope',
                                  letterSpacing: 0.4.sp,
                                  height: 20 / 14,
                                ),
                              ),
                            ),
                          ),
                          _DropdownIconButton(
                            isOpen: isOpen.value,
                            iconColor: iconColor,
                            size: size,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (expandAnimation.value > 0)
                    Expanded(
                      child: _ScrollableDropdownList(
                        options: options,
                        value: value,
                        itemHeight: itemHeight,
                        onSelect: selectOption,
                        showScrollIndicators: options.length > maxVisibleItems,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        if (helperText != null) ...[
          Gap(4.h),
          Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: Text(
              helperText!,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Manrope',
                letterSpacing: 0.4.sp,
                height: 20 / 14,
                color: isError
                    ? colors.backgroundContentDestructive
                    : colors.backgroundContentSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DropdownIconButton extends StatelessWidget {
  const _DropdownIconButton({
    required this.isOpen,
    required this.iconColor,
    required this.size,
  });

  final bool isOpen;
  final Color iconColor;
  final WnDropdownSize size;

  @override
  Widget build(BuildContext context) {
    final wrapperSize = size == WnDropdownSize.large ? 48.w : 36.w;

    return SizedBox(
      width: wrapperSize,
      height: wrapperSize,
      child: Center(
        child: WnIcon(
          isOpen ? WnIcons.closeLarge : WnIcons.chevronDown,
          key: const Key('dropdown_icon'),
          color: iconColor,
          size: 16.sp,
        ),
      ),
    );
  }
}

class _ScrollableDropdownList<T> extends HookWidget {
  const _ScrollableDropdownList({
    required this.options,
    required this.value,
    required this.itemHeight,
    required this.onSelect,
    required this.showScrollIndicators,
  });

  final List<WnDropdownOption<T>> options;
  final T value;
  final double itemHeight;
  final ValueChanged<T> onSelect;
  final bool showScrollIndicators;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scrollController = useScrollController();
    final showTopFade = useState(false);
    final showBottomFade = useState(showScrollIndicators);

    useEffect(() {
      void onScroll() {
        final position = scrollController.position;
        showTopFade.value = position.pixels > 0;
        showBottomFade.value = position.pixels < position.maxScrollExtent;
      }

      scrollController.addListener(onScroll);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          onScroll();
        }
      });
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(7.r),
        bottomRight: Radius.circular(7.r),
      ),
      child: Stack(
        children: [
          ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option.value == value;
              return _DropdownItem(
                label: option.label,
                isSelected: isSelected,
                height: itemHeight,
                onTap: () => onSelect(option.value),
              );
            },
          ),
          if (showScrollIndicators)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: showTopFade.value ? 1.0 : 0.0,
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.backgroundPrimary,
                          colors.backgroundPrimary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (showScrollIndicators)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: showBottomFade.value ? 1.0 : 0.0,
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(7.r),
                        bottomRight: Radius.circular(7.r),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          colors.backgroundPrimary,
                          colors.backgroundPrimary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DropdownItem extends StatelessWidget {
  const _DropdownItem({
    required this.label,
    required this.isSelected,
    required this.height,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final backgroundColor = isSelected ? colors.backgroundTertiary : colors.backgroundPrimary;
    final textColor = isSelected
        ? colors.backgroundContentPrimary
        : colors.backgroundContentSecondary;
    final checkmarkColor = colors.backgroundContentSecondary;
    final iconWrapperSize = 36.w;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        padding: EdgeInsets.only(left: 12.w, right: 4.w),
        color: backgroundColor,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    fontFamily: 'Manrope',
                    letterSpacing: 0.4.sp,
                    height: 20 / 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(
              width: iconWrapperSize,
              height: iconWrapperSize,
              child: isSelected
                  ? Center(
                      child: WnIcon(
                        WnIcons.checkmark,
                        key: const Key('checkmark_icon'),
                        color: checkmarkColor,
                        size: 16.sp,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
