import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

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
    this.onPaste,
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
  final VoidCallback? onPaste;

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
            color: colors.backgroundContentPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap(4.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
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
                  color: hasError ? colors.fillDestructive : colors.backgroundContentPrimary,
                ),
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.backgroundContentTertiary,
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
                      color: hasError ? colors.borderDestructivePrimary : colors.borderSecondary,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: colors.borderTertiary,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: hasError ? colors.borderDestructivePrimary : colors.borderSecondary,
                    ),
                  ),
                  suffixIcon: suffixIcon,
                ),
                obscureText: obscureText,
                obscuringCharacter: '●',
              ),
            ),
            if (onPaste != null) ...[
              Gap(8.w),
              GestureDetector(
                key: const Key('paste_button'),
                onTap: onPaste,
                child: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: colors.backgroundPrimary,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: colors.borderSecondary),
                  ),
                  child: Center(
                    child: WnIcon(
                      WnIcons.paste,
                      size: 20.w,
                      color: colors.backgroundContentPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (hasError) ...[
          Gap(6.h),
          Row(
            children: [
              WnIcon(
                WnIcons.error,
                key: const Key('error_icon'),
                size: 14.sp,
                color: colors.fillDestructive,
              ),
              Gap(4.w),
              Expanded(
                child: Text(
                  errorText!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.fillDestructive,
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
