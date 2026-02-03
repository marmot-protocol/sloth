import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whitenoise/widgets/wn_list_item.dart';

class WnList extends StatelessWidget {
  const WnList({
    super.key,
    required this.children,
    this.spacing,
  });

  final List<WnListItem> children;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing ?? 4.h,
      children: children,
    );
  }
}
