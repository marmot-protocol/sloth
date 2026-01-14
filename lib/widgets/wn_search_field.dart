import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/extensions/build_context.dart';

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
        color: colors.foregroundPrimary,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: colors.foregroundTertiary,
        ),
        prefixIcon: Icon(
          Icons.search,
          key: const Key('search_icon'),
          size: 20.sp,
          color: colors.foregroundTertiary,
        ),
        filled: true,
        fillColor: colors.backgroundTertiary,
        contentPadding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 14.w,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.foregroundTertiary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.foregroundPrimary),
        ),
      ),
    );
  }
}
