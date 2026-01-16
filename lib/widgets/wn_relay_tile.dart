import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/src/rust/api/relays.dart';

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
                      color: colors.foregroundPrimary,
                    ),
                  ),
                  GestureDetector(
                    key: const Key('close_delete_dialog'),
                    onTap: () => Navigator.of(context).pop(false),
                    child: Icon(
                      Icons.close,
                      size: 24.w,
                      color: colors.foregroundPrimary,
                    ),
                  ),
                ],
              ),
              Gap(16.h),
              Text(
                'Are you sure you want to remove this relay? This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colors.foregroundTertiary,
                ),
              ),
              Gap(24.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('cancel_delete_button'),
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.foregroundTertiary),
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
                      color: colors.foregroundPrimary,
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
                    backgroundColor: colors.error,
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
                      color: colors.foregroundSecondary,
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
        border: Border.all(color: colors.foregroundTertiary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: status == null
                  ? colors.foregroundTertiary
                  : isConnected
                  ? colors.success
                  : colors.error,
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
                    color: colors.foregroundPrimary,
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
                      color: colors.foregroundTertiary,
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
              icon: Icon(
                Icons.remove_circle_outline,
                color: colors.error,
              ),
              iconSize: 20.w,
            ),
        ],
      ),
    );
  }
}
