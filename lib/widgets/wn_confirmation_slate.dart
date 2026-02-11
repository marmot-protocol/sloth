import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_button.dart';
import 'package:whitenoise/widgets/wn_slate.dart';
import 'package:whitenoise/widgets/wn_slate_navigation_header.dart';

class WnConfirmationSlate extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isDestructive;

  const WnConfirmationSlate({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
    this.isDestructive = false,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    bool isDestructive = false,
  }) async {
    final colors = context.colors;

    return await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: colors.backgroundPrimary.withValues(alpha: 0.8),
        pageBuilder: (context, _, _) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
                WnConfirmationSlate(
                  title: title,
                  message: message,
                  confirmText: confirmText,
                  cancelText: cancelText,
                  onConfirm: () => Navigator.of(context).pop(true),
                  onCancel: () => Navigator.of(context).pop(false),
                  isDestructive: isDestructive,
                ),
              ],
            ),
          );
        },
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return WnSlate(
      header: WnSlateNavigationHeader(
        title: title,
        onNavigate: onCancel,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    onPressed: onCancel,
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
