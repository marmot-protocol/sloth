import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_separator.dart';

class WnListItem {
  const WnListItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.isSelected = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isSelected;
}

class WnList extends StatelessWidget {
  const WnList({
    super.key,
    required this.items,
    this.showSeparators = true,
  });

  final List<WnListItem> items;
  final bool showSeparators;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _buildItems(context),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    final widgets = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      widgets.add(_WnListItemWidget(item: items[i], index: i));

      if (showSeparators && i < items.length - 1) {
        widgets.add(const WnSeparator());
      }
    }

    return widgets;
  }
}

class _WnListItemWidget extends StatelessWidget {
  const _WnListItemWidget({
    required this.item,
    required this.index,
  });

  final WnListItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          if (item.leading != null)
            Padding(
              key: Key('list_item_leading_$index'),
              padding: EdgeInsets.only(right: 12.w),
              child: item.leading,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.backgroundContentPrimary,
                    height: 22 / 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      item.subtitle!,
                      key: Key('list_item_subtitle_$index'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: colors.backgroundContentSecondary,
                        height: 20 / 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          if (item.trailing != null)
            Padding(
              key: Key('list_item_trailing_$index'),
              padding: EdgeInsets.only(left: 12.w),
              child: item.trailing,
            ),
        ],
      ),
    );

    if (item.isSelected) {
      content = Container(
        key: Key('list_item_selected_$index'),
        decoration: BoxDecoration(
          color: colors.fillSecondary,
        ),
        child: content,
      );
    }

    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}
