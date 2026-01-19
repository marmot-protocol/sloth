import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sloth/extensions/build_context.dart';

class WnDropdownOption<T> {
  const WnDropdownOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

class WnDropdownSelector<T> extends StatelessWidget {
  const WnDropdownSelector({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<WnDropdownOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: colors.foregroundPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap(4.h),
        DropdownButtonFormField<T>(
          initialValue: value,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: colors.foregroundPrimary,
          ),
          dropdownColor: colors.backgroundPrimary,
          borderRadius: BorderRadius.circular(8.r),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colors.foregroundPrimary,
            fontFamily: 'Manrope',
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: colors.foregroundTertiary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: colors.foregroundTertiary),
            ),
          ),
          items: options.map((option) {
            return DropdownMenuItem<T>(
              value: option.value,
              child: Text(option.label),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ],
    );
  }
}
