import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sloth/src/rust/api/relays.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

class WnRelayTile extends StatelessWidget {
  const WnRelayTile({
    super.key,
    required this.relay,
    this.status,
    this.showOptions = true,
    this.onDelete,
  });

  final Relay relay;
  final String? status;
  final bool showOptions;
  final VoidCallback? onDelete;

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final colors = context.colors;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: colors.backgroundPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remove Relay?',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.backgroundContentPrimary,
                    ),
                  ),
                  GestureDetector(
                    key: const Key('close_delete_dialog'),
                    onTap: () => Navigator.of(context).pop(false),
                    child: WnIcon(
                      WnIcons.closeLarge,
                      color: colors.backgroundContentPrimary,
                    ),
                  ),
                ],
              ),
              Gap(16.h),
              Text(
                'Are you sure you want to remove this relay? This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colors.backgroundContentTertiary,
                ),
              ),
              Gap(24.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('cancel_delete_button'),
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.borderSecondary),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.backgroundContentPrimary,
                    ),
                  ),
                ),
              ),
              Gap(12.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('confirm_delete_button'),
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.fillDestructive,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.fillContentPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isConnected = status?.toLowerCase() == 'connected';

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.borderTertiary),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: status == null
                  ? colors.backgroundContentTertiary
                  : isConnected
                  ? colors.intentionSuccessContent
                  : colors.fillDestructive,
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  relay.url,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.backgroundContentPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (status != null) ...[
                  Gap(2.h),
                  Text(
                    status!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: colors.backgroundContentTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showOptions && onDelete != null)
            IconButton(
              key: Key('delete_relay_${relay.url}'),
              onPressed: () => _showDeleteConfirmation(context),
              icon: WnIcon(
                WnIcons.removeCircle,
                size: 20.w,
                color: colors.fillDestructive,
              ),
            ),
        ],
      ),
    );
  }
}
