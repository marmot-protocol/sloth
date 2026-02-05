import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whitenoise/l10n/l10n.dart';
import 'package:whitenoise/models/reply_preview.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/utils/metadata.dart';
import 'package:whitenoise/widgets/wn_icon.dart';

class WnReplyPreview extends StatelessWidget {
  const WnReplyPreview({
    super.key,
    required this.data,
    this.currentUserPubkey,
    this.onCancel,
  });

  final ReplyPreview data;
  final String? currentUserPubkey;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typographyScaled;
    final l10n = context.l10n;

    final authorName = data.isNotFound
        ? l10n.unknownUser
        : (currentUserPubkey != null && data.authorPubkey == currentUserPubkey
              ? l10n.you
              : presentName(data.authorMetadata) ?? l10n.unknownUser);
    final content = data.isNotFound ? l10n.messageNotFound : data.content;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  authorName,
                  style: typography.semiBold12.copyWith(color: colors.backgroundContentPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  content,
                  style: typography.medium12.copyWith(color: colors.backgroundContentPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onCancel != null) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              key: const Key('cancel_reply_button'),
              onTap: onCancel,
              child: WnIcon(
                WnIcons.closeSmall,
                color: colors.backgroundContentPrimary,
                size: 16.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
