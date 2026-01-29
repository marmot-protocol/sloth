import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_input.dart';

class WnInputTextArea extends StatelessWidget {
  const WnInputTextArea({
    super.key,
    required this.placeholder,
    this.label,
    this.labelHelpIcon,
    this.helperText,
    this.errorText,
    this.controller,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.size = WnInputSize.size56,
    this.onChanged,
    this.textInputAction,
    this.focusNode,
    this.maxLines,
  });

  final String placeholder;
  final String? label;
  final VoidCallback? labelHelpIcon;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final WnInputSize size;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final int? maxLines;

  bool get _hasError => errorText != null;

  double get _minHeight {
    return size == WnInputSize.size44 ? 102.h : 182.h;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) _buildLabel(colors),
        _buildTextArea(colors),
        if (_hasError)
          _buildErrorText(colors)
        else if (helperText != null)
          _buildHelperText(colors),
      ],
    );
  }

  Widget _buildLabel(SemanticColors colors) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: colors.backgroundContentPrimary,
                height: 20 / 14,
                letterSpacing: 0.4.sp,
              ),
            ),
          ),
          if (labelHelpIcon != null)
            GestureDetector(
              key: const Key('label_help_icon'),
              onTap: labelHelpIcon,
              child: SizedBox(
                width: 18.w,
                height: 18.w,
                child: Center(
                  child: WnIcon(
                    WnIcons.help,
                    size: 14.w,
                    color: colors.backgroundContentPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextArea(SemanticColors colors) {
    final borderColor = _hasError ? colors.borderDestructivePrimary : colors.borderTertiary;

    return Container(
      constraints: BoxConstraints(minHeight: _minHeight),
      decoration: BoxDecoration(
        color: enabled ? colors.backgroundPrimary : colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        child: TextField(
          key: const Key('text_area_field'),
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          onChanged: onChanged,
          textInputAction: textInputAction,
          keyboardType: TextInputType.multiline,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: enabled
                ? (_hasError ? colors.fillDestructive : colors.backgroundContentPrimary)
                : colors.backgroundContentTertiary,
            height: 20 / 14,
            letterSpacing: 0.4.sp,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: colors.backgroundContentSecondary,
              height: 20 / 14,
              letterSpacing: 0.4.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _buildHelperText(SemanticColors colors) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, top: 4.h),
      child: Text(
        helperText!,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: colors.backgroundContentSecondary,
          height: 20 / 14,
          letterSpacing: 0.4.sp,
        ),
      ),
    );
  }

  Widget _buildErrorText(SemanticColors colors) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, top: 4.h),
      child: Text(
        errorText!,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: colors.fillDestructive,
          height: 20 / 14,
          letterSpacing: 0.4.sp,
        ),
      ),
    );
  }
}
