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
              height: currentHeight + 2, // +2 for border (1px top + 1px bottom)
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
                            child: WnIcon(
                              isOpen.value ? WnIcons.closeLarge : WnIcons.chevronDown,
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
      // Check initial state after first frame
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
          // Top fade indicator
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
          // Bottom fade indicator
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

    final backgroundColor = isSelected ? colors.fillSecondary : colors.backgroundPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        color: backgroundColor,
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
                  ? WnIcon(
                      WnIcons.checkmark,
                      key: const Key('checkmark_icon'),
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
