import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sloth/extensions/build_context.dart';

class WnTextFormField extends StatelessWidget {
  const WnTextFormField({
    super.key,
    required this.label,
    required this.placeholder,
    this.controller,
    this.autofocus = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.errorText,
    this.onChanged,
    this.textInputAction,
    this.readOnly = false,
    this.suffixIcon,
  });

  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final bool autofocus;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = errorText != null;

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
        TextFormField(
          controller: controller,
          autofocus: autofocus,
          readOnly: readOnly,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          onChanged: onChanged,
          textInputAction: textInputAction,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: hasError ? colors.error : colors.foregroundPrimary,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: colors.foregroundTertiary,
            ),
            filled: true,
            fillColor: colors.backgroundPrimary,
            contentPadding: EdgeInsets.symmetric(
              vertical: 15.h,
              horizontal: 14.w,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: hasError ? colors.error : colors.foregroundTertiary,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: colors.foregroundTertiary.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: hasError ? colors.error : colors.foregroundTertiary,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
          obscureText: obscureText,
          obscuringCharacter: '●',
        ),
        if (hasError) ...[
          Gap(6.h),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                key: const Key('error_icon'),
                size: 14.sp,
                color: colors.error,
              ),
              Gap(4.w),
              Expanded(
                child: Text(
                  errorText!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
