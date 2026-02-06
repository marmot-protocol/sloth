import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_icon.dart';

class WnSearchField extends StatelessWidget {
  const WnSearchField({
    super.key,
    required this.placeholder,
    this.controller,
    this.onChanged,
    this.autofocus = false,
    this.onScan,
  });

  final String placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typographyScaled;

    return TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      style: typography.medium14.copyWith(color: colors.backgroundContentPrimary),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: typography.medium14.copyWith(color: colors.backgroundContentTertiary),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 14.w, right: 10.w),
          child: WnIcon(
            WnIcons.search,
            key: const Key('search_icon'),
            size: 20.sp,
            color: colors.backgroundContentTertiary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(),
        suffixIcon: onScan != null
            ? GestureDetector(
                key: const Key('scan_button'),
                onTap: onScan,
                child: Padding(
                  padding: EdgeInsets.only(right: 14.w),
                  child: WnIcon(
                    WnIcons.scan,
                    size: 20.sp,
                    color: colors.backgroundContentTertiary,
                  ),
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(),
        filled: true,
        fillColor: colors.backgroundPrimary,
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
