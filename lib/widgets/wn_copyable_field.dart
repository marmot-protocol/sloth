import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_input.dart';

class WnCopyableField extends HookWidget {
  const WnCopyableField({
    super.key,
    required this.label,
    required this.value,
    this.obscurable = false,
    this.obscured = true,
    this.onToggleVisibility,
    this.copiedMessage,
  });

  final String label;
  final String value;
  final bool obscurable;
  final bool obscured;
  final VoidCallback? onToggleVisibility;
  final String? copiedMessage;

  void _handleCopy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (copiedMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(copiedMessage!),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getDisplayValue() {
    if (!obscurable || !obscured) {
      return value;
    }
    final maskedLength = value.length.clamp(8, 24).toInt();
    return '●' * maskedLength;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = useTextEditingController(text: _getDisplayValue());

    useEffect(() {
      controller.text = _getDisplayValue();
      return null;
    }, [value, obscured]);

    return WnInput(
      label: label,
      placeholder: '',
      controller: controller,
      readOnly: true,
      size: WnInputSize.size44,
      inlineAction: obscurable
          ? GestureDetector(
              key: const Key('visibility_toggle'),
              onTap: onToggleVisibility,
              child: Container(
                width: 36.w,
                height: 36.w,
                color: Colors.transparent,
                child: Center(
                  child: WnIcon(
                    obscured ? WnIcons.view : WnIcons.viewOff,
                    size: 16.w,
                    color: colors.backgroundContentPrimary,
                  ),
                ),
              ),
            )
          : null,
      trailingAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Gap(2.w),
          WnInputTrailingButton(
            key: const Key('copy_button'),
            icon: WnIcons.copy,
            onPressed: () => _handleCopy(context, value),
            size: WnInputSize.size44,
          ),
        ],
      ),
    );
  }
}
