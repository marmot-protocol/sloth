import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:whitenoise/l10n/l10n.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_button.dart';

class WnConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const WnConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText = '',
    this.isDestructive = false,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    String? cancelText,
    bool isDestructive = false,
  }) async {
    final colors = context.colors;

    return await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: colors.backgroundTertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => WnConfirmationBottomSheet(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText ?? context.l10n.cancel,
        onConfirm: () => Navigator.of(context).pop(true),
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.borderTertiary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Gap(16.h),
            Text(
              title,
              style: context.typographyScaled.semiBold18.copyWith(
                color: colors.backgroundContentPrimary,
              ),
            ),
            Gap(12.h),
            Text(
              message,
              style: context.typographyScaled.medium14.copyWith(
                color: colors.backgroundContentSecondary,
              ),
            ),
            Gap(24.h),
            Row(
              spacing: 12.w,
              children: [
                Expanded(
                  child: WnButton(
                    key: const Key('cancel_button'),
                    onPressed: () => Navigator.of(context).pop(false),
                    text: cancelText,
                    type: WnButtonType.outline,
                  ),
                ),
                Expanded(
                  child: WnButton(
                    key: const Key('confirm_button'),
                    onPressed: onConfirm,
                    text: confirmText,
                    type: isDestructive ? WnButtonType.destructive : WnButtonType.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
