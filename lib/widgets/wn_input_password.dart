import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_input.dart';

class WnInputPassword extends HookWidget {
  const WnInputPassword({
    super.key,
    required this.placeholder,
    this.label,
    this.labelHelpIcon,
    this.helperText,
    this.errorText,
    this.controller,
    this.autofocus = false,
    this.enabled = true,
    this.size = WnInputSize.size56,
    this.onChanged,
    this.textInputAction,
    this.onScan,
    this.onPaste,
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
  final WnInputSize size;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final VoidCallback? onScan;
  final VoidCallback? onPaste;
  final FocusNode? focusNode;

  bool get _hasError => errorText != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isVisible = useState(false);
    final internalController = useTextEditingController();
    final effectiveController = controller ?? internalController;
    final isEmpty = useListenableSelector(
      effectiveController,
      () => effectiveController.text.isEmpty,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) _buildLabel(colors),
        _buildInputRow(colors, isVisible, isEmpty, effectiveController),
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
              behavior: HitTestBehavior.opaque,
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

  Widget _buildInputRow(
    SemanticColors colors,
    ValueNotifier<bool> isVisible,
    bool isEmpty,
    TextEditingController effectiveController,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildInputField(colors, isVisible, isEmpty, effectiveController),
        ),
        Gap(6.w),
        _buildTrailingAction(colors, isEmpty, effectiveController),
      ],
    );
  }

  Widget _buildInputField(
    SemanticColors colors,
    ValueNotifier<bool> isVisible,
    bool isEmpty,
    TextEditingController effectiveController,
  ) {
    final fieldHeight = size.height.h;
    final inlineActionWidth = size == WnInputSize.size44 ? 36.w : 48.w;
    final inlineActionHeight = size == WnInputSize.size44 ? 36.h : 48.h;

    final borderColor = _hasError ? colors.borderDestructivePrimary : colors.borderTertiary;

    return Container(
      key: const Key('password_field_container'),
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
                key: const Key('password_field'),
                controller: effectiveController,
                focusNode: focusNode,
                autofocus: autofocus,
                enabled: enabled,
                obscureText: !isVisible.value,
                obscuringCharacter: '●',
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
          SizedBox(
            width: inlineActionWidth,
            height: inlineActionHeight,
            child: _buildInlineAction(colors, isVisible, isEmpty),
          ),
          Gap(4.w),
        ],
      ),
    );
  }

  Widget _buildInlineAction(
    SemanticColors colors,
    ValueNotifier<bool> isVisible,
    bool isEmpty,
  ) {
    final buttonWidth = size == WnInputSize.size44 ? 36.w : 48.w;
    final buttonHeight = size == WnInputSize.size44 ? 36.h : 48.h;
    final iconWrapperWidth = 36.w;
    final iconWrapperHeight = 36.h;
    final iconSize = 16.w;

    if (isEmpty && onScan != null) {
      return GestureDetector(
        key: const Key('scan_button'),
        onTap: enabled ? onScan : null,
        child: Container(
          width: buttonWidth,
          height: buttonHeight,
          color: Colors.transparent,
          child: Center(
            child: SizedBox(
              width: iconWrapperWidth,
              height: iconWrapperHeight,
              child: Center(
                child: WnIcon(
                  WnIcons.scan,
                  size: iconSize,
                  color: colors.backgroundContentPrimary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      key: const Key('visibility_toggle'),
      onTap: enabled ? () => isVisible.value = !isVisible.value : null,
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        color: Colors.transparent,
        child: Center(
          child: SizedBox(
            width: iconWrapperWidth,
            height: iconWrapperHeight,
            child: Center(
              child: WnIcon(
                isVisible.value ? WnIcons.viewOff : WnIcons.view,
                size: iconSize,
                color: colors.backgroundContentPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle get _baseInfoTextStyle => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.4.sp,
  );

  Widget _buildTrailingAction(
    SemanticColors colors,
    bool isEmpty,
    TextEditingController effectiveController,
  ) {
    final buttonWidth = size.height.w;
    final buttonHeight = size.height.h;
    final iconSize = 18.w;

    if (isEmpty && onPaste != null) {
      return GestureDetector(
        key: const Key('paste_button'),
        onTap: onPaste,
        child: Container(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: colors.fillSecondary,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: colors.borderTertiary),
          ),
          child: Center(
            child: WnIcon(
              WnIcons.paste,
              size: iconSize,
              color: colors.backgroundContentPrimary,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      key: const Key('clear_button'),
      onTap: () {
        effectiveController.clear();
        onChanged?.call('');
      },
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: colors.fillSecondary,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: colors.borderTertiary),
        ),
        child: Center(
          child: WnIcon(
            WnIcons.closeSmall,
            size: iconSize,
            color: colors.backgroundContentPrimary,
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
        style: _baseInfoTextStyle.copyWith(color: colors.backgroundContentSecondary),
      ),
    );
  }

  Widget _buildErrorText(SemanticColors colors) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, top: 4.h),
      child: Text(
        errorText!,
        style: _baseInfoTextStyle.copyWith(color: colors.fillDestructive),
      ),
    );
  }
}
