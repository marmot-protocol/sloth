import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

enum WnInputSize {
  size44(44),
  size56(56);

  const WnInputSize(this.height);
  final int height;
}

class WnInput extends StatelessWidget {
  const WnInput({
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
    this.inlineAction,
    this.trailingAction,
    this.focusNode,
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
  final Widget? inlineAction;
  final Widget? trailingAction;
  final FocusNode? focusNode;

  bool get _hasError => errorText != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) _buildLabel(colors),
        _buildInputRow(colors),
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
              child: Padding(
                padding: EdgeInsets.all(0.w),
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
            ),
        ],
      ),
    );
  }

  Widget _buildInputRow(SemanticColors colors) {
    return Row(
      children: [
        Expanded(child: _buildInputField(colors)),
        if (trailingAction != null) ...[
          Gap(6.w),
          trailingAction!,
        ],
      ],
    );
  }

  Widget _buildInputField(SemanticColors colors) {
    final fieldHeight = size.height.h;
    final inlineActionSize = size == WnInputSize.size44 ? 36.w : 48.w;

    final borderColor = _hasError ? colors.borderDestructivePrimary : colors.borderTertiary;

    return Container(
      height: fieldHeight,
      decoration: BoxDecoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: TextField(
                key: const Key('input_field'),
                controller: controller,
                focusNode: focusNode,
                autofocus: autofocus,
                enabled: enabled,
                readOnly: readOnly,
                onChanged: onChanged,
                textInputAction: textInputAction,
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
          ),
          if (inlineAction != null)
            SizedBox(
              width: inlineActionSize,
              height: inlineActionSize,
              child: inlineAction,
            ),
          if (inlineAction != null) Gap(4.w),
        ],
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

class WnInputFieldButton extends StatelessWidget {
  const WnInputFieldButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = WnInputSize.size56,
  });

  final WnIcons icon;
  final VoidCallback onPressed;
  final WnInputSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final buttonSize = size == WnInputSize.size44 ? 36.w : 48.w;
    final iconSize = 16.w;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: colors.fillTertiary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: WnIcon(
            icon,
            size: iconSize,
            color: colors.backgroundContentPrimary,
          ),
        ),
      ),
    );
  }
}

class WnInputTrailingButton extends StatelessWidget {
  const WnInputTrailingButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = WnInputSize.size56,
  });

  final WnIcons icon;
  final VoidCallback onPressed;
  final WnInputSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final buttonSize = size.height.h;
    final iconSize = 18.w;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: colors.fillSecondary,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: colors.borderTertiary),
        ),
        child: Center(
          child: WnIcon(
            icon,
            size: iconSize,
            color: colors.backgroundContentPrimary,
          ),
        ),
      ),
    );
  }
}
