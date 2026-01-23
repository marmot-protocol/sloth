import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

class WnScreenHeader extends StatelessWidget {
  const WnScreenHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: colors.backgroundContentPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          key: const Key('close_button'),
          onPressed: () => Routes.goBack(context),
          icon: WnIcon(
            WnIcons.closeLarge,
            color: colors.backgroundContentPrimary,
          ),
        ),
      ],
    );
  }
}
