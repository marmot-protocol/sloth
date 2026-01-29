import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_slate_header_action.dart';

enum WnSlateNavigationType { close, back }

class WnSlateNavigationHeader extends StatelessWidget {
  const WnSlateNavigationHeader({
    super.key,
    required this.title,
    this.type = WnSlateNavigationType.close,
    this.onNavigate,
  });

  final String title;
  final WnSlateNavigationType type;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isBack = type == WnSlateNavigationType.back;
    final hasAction = onNavigate != null;
    final hasLeadingAction = isBack && hasAction;
    final hasTrailingAction = !isBack && hasAction;

    return SizedBox(
      height: 80.h,
      child: Row(
        children: [
          if (hasLeadingAction)
            WnSlateHeaderAction(
              type: WnSlateHeaderActionType.back,
              onPressed: onNavigate!,
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: hasTrailingAction ? 80.w : 0,
                right: hasLeadingAction ? 80.w : 0,
              ),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    height: 22 / 16,
                    letterSpacing: 0.2.sp,
                    color: colors.backgroundContentPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (hasTrailingAction)
            WnSlateHeaderAction(
              type: WnSlateHeaderActionType.close,
              onPressed: onNavigate!,
            ),
        ],
      ),
    );
  }
}
