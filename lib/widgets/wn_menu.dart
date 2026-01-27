import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/widgets/wn_menu_item.dart';

class WnMenu extends StatelessWidget {
  const WnMenu({
    super.key,
    required this.children,
  });

  final List<WnMenuItem> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10.h,
      children: children,
    );
  }
}
