import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_icon.dart';

class WnKeyPackageCard extends StatelessWidget {
  const WnKeyPackageCard({
    super.key,
    required this.title,
    required this.packageId,
    required this.createdAt,
    required this.onDelete,
    this.disabled = false,
    this.deleteButtonKey,
  });

  final String title;
  final String packageId;
  final String createdAt;
  final VoidCallback? onDelete;
  final bool disabled;
  final Key? deleteButtonKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 16.h),
      decoration: BoxDecoration(
        color: colors.fillSecondary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(colors),
          _buildContent(colors),
        ],
      ),
    );
  }

  Widget _buildTitleRow(SemanticColors colors) {
    return SizedBox(
      height: 44.h,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: WnIcon(
              WnIcons.key,
              size: 20.w,
              color: colors.backgroundContentSecondary,
              key: const Key('key_package_icon'),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.fillContentSecondary,
                  letterSpacing: 0.4,
                  height: 18 / 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SemanticColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildIdField(colors),
        _buildCreatedAtField(colors),
        SizedBox(
          height: 44.h,
          child: WnButton(
            key: deleteButtonKey ?? const Key('delete_button'),
            text: 'Delete',
            onPressed: onDelete,
            type: WnButtonType.destructive,
            size: WnButtonSize.medium,
            disabled: disabled,
            trailingIcon: WnIcons.trashCan,
          ),
        ),
      ],
    );
  }

  Widget _buildIdField(SemanticColors colors) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 4.h, 8.w, 13.h),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'ID: ',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: colors.backgroundContentSecondary,
                letterSpacing: 0.4,
                height: 18 / 14,
              ),
            ),
            TextSpan(
              text: packageId,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: colors.backgroundContentSecondary,
                letterSpacing: 0.4,
                height: 18 / 14,
              ),
            ),
          ],
        ),
        key: const Key('package_id_text'),
      ),
    );
  }

  Widget _buildCreatedAtField(SemanticColors colors) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 4.h, 8.w, 13.h),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Created at: ',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: colors.backgroundContentPrimary,
                letterSpacing: 0.4,
                height: 18 / 14,
              ),
            ),
            TextSpan(
              text: createdAt,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: colors.backgroundContentPrimary,
                letterSpacing: 0.4,
                height: 18 / 14,
              ),
            ),
          ],
        ),
        key: const Key('created_at_text'),
      ),
    );
  }
}
