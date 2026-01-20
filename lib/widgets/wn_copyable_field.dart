import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_text_form_field.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = useTextEditingController(text: value);

    useEffect(() {
      controller.text = value;
      return null;
    }, [value]);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: WnTextFormField(
            label: label,
            placeholder: '',
            controller: controller,
            readOnly: true,
            obscureText: obscurable && obscured,
            suffixIcon: obscurable
                ? IconButton(
                    key: const Key('visibility_toggle'),
                    onPressed: onToggleVisibility,
                    icon: Icon(
                      obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20.w,
                      color: colors.backgroundContentPrimary,
                    ),
                  )
                : null,
          ),
        ),
        Gap(4.w),
        Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: IconButton(
            key: const Key('copy_button'),
            onPressed: () => _handleCopy(context, controller.text),
            icon: Icon(
              Icons.copy,
              color: colors.backgroundContentPrimary,
              size: 20.w,
            ),
            style: IconButton.styleFrom(
              backgroundColor: colors.backgroundPrimary,
              minimumSize: Size(44.w, 44.h),
              padding: EdgeInsets.all(14.w),
            ),
          ),
        ),
      ],
    );
  }
}
