import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/routes.dart';

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
              color: colors.foregroundPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          key: const Key('close_button'),
          onPressed: () => Routes.goBack(context),
          icon: Icon(
            Icons.close,
            color: colors.foregroundPrimary,
          ),
          iconSize: 24.w,
        ),
      ],
    );
  }
}
