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
        if (label != null) _buildLabel(context, colors),
        _buildTextArea(context, colors),
        if (_hasError)
          _buildErrorText(context, colors)
        else if (helperText != null)
          _buildHelperText(context, colors),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, SemanticColors colors) {
    final typography = context.typographyScaled;
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              label!,
              style: typography.medium14.copyWith(color: colors.backgroundContentPrimary),
            ),
          ),
          if (labelHelpIcon != null)
            GestureDetector(
              key: const Key('label_help_icon'),
              onTap: labelHelpIcon,
              child: SizedBox(
                width: 18.w,
                height: 18.h,
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

  Widget _buildTextArea(BuildContext context, SemanticColors colors) {
    final typography = context.typographyScaled;
    final borderColor = _hasError ? colors.borderDestructivePrimary : colors.borderTertiary;

    return Container(
      key: const Key('text_area_container'),
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
          style: typography.medium14.copyWith(
            color: enabled
                ? (_hasError
                      ? colors.backgroundContentDestructive
                      : colors.backgroundContentPrimary)
                : colors.backgroundContentTertiary,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: typography.medium14.copyWith(color: colors.backgroundContentSecondary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _buildHelperText(BuildContext context, SemanticColors colors) {
    final typography = context.typographyScaled;
    return Padding(
      padding: EdgeInsets.only(left: 2.w, top: 4.h),
      child: Text(
        helperText!,
        style: typography.medium14.copyWith(color: colors.backgroundContentSecondary),
      ),
    );
  }

  Widget _buildErrorText(BuildContext context, SemanticColors colors) {
    final typography = context.typographyScaled;
    return Padding(
      padding: EdgeInsets.only(left: 2.w, top: 4.h),
      child: Text(
        errorText!,
        style: typography.medium14.copyWith(color: colors.backgroundContentDestructive),
      ),
    );
  }
}
