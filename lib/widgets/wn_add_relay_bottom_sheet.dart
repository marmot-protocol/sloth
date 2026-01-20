import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sloth/hooks/use_add_relay.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_filled_button.dart';

class WnAddRelayBottomSheet extends HookWidget {
  final Future<void> Function(String) onRelayAdded;

  const WnAddRelayBottomSheet({
    super.key,
    required this.onRelayAdded,
  });

  static Future<void> show({
    required BuildContext context,
    required Future<void> Function(String) onRelayAdded,
  }) async {
    final colors = context.colors;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.backgroundTertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: WnAddRelayBottomSheet(onRelayAdded: onRelayAdded),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (:controller, :isValid, :validationError, :paste) = useAddRelay();

    Future<void> addRelay() async {
      final relayUrl = controller.text.trim();
      if (relayUrl.isEmpty) return;

      Navigator.of(context).pop();
      await onRelayAdded(relayUrl);
    }

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
              'Add Relay',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colors.backgroundContentPrimary,
              ),
            ),
            Gap(16.h),
            Text(
              'Enter relay address',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: colors.backgroundContentPrimary,
              ),
            ),
            Gap(8.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.backgroundContentPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'wss://relay.example.com',
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
                        borderSide: BorderSide(color: colors.borderSecondary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: colors.borderSecondary),
                      ),
                    ),
                  ),
                ),
                Gap(8.w),
                GestureDetector(
                  key: const Key('paste_button'),
                  onTap: paste,
                  child: Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: colors.backgroundPrimary,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: colors.borderSecondary),
                    ),
                    child: Icon(
                      Icons.content_paste,
                      size: 20.w,
                      color: colors.backgroundContentPrimary,
                    ),
                  ),
                ),
              ],
            ),
            Gap(16.h),
            if (validationError != null) ...[
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: colors.fillDestructive.withValues(alpha: 0.1),
                  border: Border.all(color: colors.borderDestructivePrimary),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16.w,
                          color: colors.fillDestructive,
                        ),
                        Gap(8.w),
                        Text(
                          'Relay not supported',
                          style: TextStyle(
                            color: colors.backgroundContentPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    Gap(8.h),
                    Text(
                      validationError,
                      style: TextStyle(
                        color: colors.backgroundContentPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(12.h),
            ],
            SizedBox(
              width: double.infinity,
              child: WnFilledButton(
                key: const Key('add_relay_submit_button'),
                onPressed: isValid ? addRelay : null,
                text: 'Add Relay',
                disabled: !isValid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
