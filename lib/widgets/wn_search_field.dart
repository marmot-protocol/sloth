import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

class WnSearchField extends StatelessWidget {
  const WnSearchField({
    super.key,
    required this.placeholder,
    this.controller,
    this.onChanged,
    this.autofocus = false,
  });

  final String placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: colors.backgroundContentPrimary,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: colors.backgroundContentTertiary,
        ),
        prefixIcon: WnIcon(
          WnIcons.search,
          key: const Key('search_icon'),
          size: 20.sp,
          color: colors.backgroundContentTertiary,
        ),
        filled: true,
        fillColor: colors.backgroundTertiary,
        contentPadding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 14.w,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.borderTertiary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.borderPrimary),
        ),
      ),
    );
  }
}
