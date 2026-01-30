import 'package:flutter/material.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_menu.dart';
import 'package:sloth/widgets/wn_menu_item.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: WnMenuItem)
Widget wnMenuItemUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: WnMenuItem(
          label: context.knobs.string(
            label: 'Label',
            initialValue: 'Menu Item',
          ),
          icon: context.knobs.objectOrNull.dropdown(
            label: 'Icon',
            options: [WnIcons.settings, WnIcons.user, WnIcons.logout],
            labelBuilder: (value) => value.name,
          ),
          type: context.knobs.object.dropdown(
            label: 'Type',
            options: WnMenuItemType.values,
            initialOption: WnMenuItemType.primary,
            labelBuilder: (value) => value.name,
          ),
          onTap: () {},
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Menu Container', type: WnMenu)
Widget wnMenuUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: WnMenu(
          children: [
            WnMenuItem(label: 'Profile', icon: WnIcons.user, onTap: () {}),
            WnMenuItem(label: 'Settings', icon: WnIcons.settings, onTap: () {}),
            WnMenuItem(
              label: 'Logout',
              icon: WnIcons.logout,
              type: WnMenuItemType.destructive,
              onTap: () {},
            ),
          ],
        ),
      ),
    ),
  );
}

extension on WnIcons {
  String get name => toString().split('.').last;
}

extension on WnMenuItemType {
  String get name => toString().split('.').last;
}
