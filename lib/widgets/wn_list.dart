import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/widgets/wn_list_item.dart';

class WnList extends StatelessWidget {
  const WnList({
    super.key,
    required this.children,
  });

  final List<WnListItem> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4.h,
      children: children,
    );
  }
}
