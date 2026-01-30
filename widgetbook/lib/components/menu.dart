import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_menu.dart';
import 'package:sloth/widgets/wn_menu_item.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class WnMenuItemStory extends StatelessWidget {
  const WnMenuItemStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Menu Item', type: WnMenuItemStory)
Widget wnMenuItemShowcase(BuildContext context) {
  return Scaffold(
    backgroundColor: context.colors.backgroundPrimary,
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSection(
          'Menu Item Types',
          'Menu items come in three types: primary (default), secondary, and destructive.',
          [
            _MenuItemExample(
              label: 'Primary',
              child: _StaticMenuItem(
                menuLabel: 'Profile',
                icon: WnIcons.user,
                type: WnMenuItemType.primary,
              ),
            ),
            _MenuItemExample(
              label: 'Secondary',
              child: _StaticMenuItem(
                menuLabel: 'Settings',
                icon: WnIcons.settings,
                type: WnMenuItemType.secondary,
              ),
            ),
            _MenuItemExample(
              label: 'Destructive',
              child: _StaticMenuItem(
                menuLabel: 'Logout',
                icon: WnIcons.logout,
                type: WnMenuItemType.destructive,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          'With/Without Icon',
          'Menu items can be displayed with or without an icon.',
          [
            _MenuItemExample(
              label: 'With Icon',
              child: _StaticMenuItem(
                menuLabel: 'Settings',
                icon: WnIcons.settings,
                type: WnMenuItemType.primary,
              ),
            ),
            _MenuItemExample(
              label: 'Without Icon',
              child: _StaticMenuItem(
                menuLabel: 'Settings',
                icon: null,
                type: WnMenuItemType.primary,
              ),
            ),
            _MenuItemExample(
              label: 'Destructive With Icon',
              child: _StaticMenuItem(
                menuLabel: 'Delete Account',
                icon: WnIcons.logout,
                type: WnMenuItemType.destructive,
              ),
            ),
            _MenuItemExample(
              label: 'Destructive Without Icon',
              child: _StaticMenuItem(
                menuLabel: 'Delete Account',
                icon: null,
                type: WnMenuItemType.destructive,
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        const Divider(),
        const SizedBox(height: 24),
        const Text(
          'Interactive Playground',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Use the knobs panel to customize this menu item.',
          style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
        ),
        const SizedBox(height: 16),
        _InteractiveMenuItem(context: context),
      ],
    ),
  );
}

class WnMenuStory extends StatelessWidget {
  const WnMenuStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Menu Container', type: WnMenuStory)
Widget wnMenuShowcase(BuildContext context) {
  return Scaffold(
    backgroundColor: context.colors.backgroundPrimary,
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSection(
          'Menu Examples',
          'Menu containers group multiple menu items together.',
          [
            _MenuExample(
              label: 'Basic Menu',
              child: _StaticMenu(
                items: const [
                  _MenuItemConfig(label: 'Profile', icon: WnIcons.user),
                  _MenuItemConfig(label: 'Settings', icon: WnIcons.settings),
                ],
              ),
            ),
            _MenuExample(
              label: 'With Destructive Action',
              child: _StaticMenu(
                items: const [
                  _MenuItemConfig(label: 'Profile', icon: WnIcons.user),
                  _MenuItemConfig(label: 'Settings', icon: WnIcons.settings),
                  _MenuItemConfig(
                    label: 'Logout',
                    icon: WnIcons.logout,
                    type: WnMenuItemType.destructive,
                  ),
                ],
              ),
            ),
            _MenuExample(
              label: 'Mixed Types',
              child: _StaticMenu(
                items: const [
                  _MenuItemConfig(
                    label: 'Primary Action',
                    icon: WnIcons.user,
                    type: WnMenuItemType.primary,
                  ),
                  _MenuItemConfig(
                    label: 'Secondary Action',
                    icon: WnIcons.settings,
                    type: WnMenuItemType.secondary,
                  ),
                  _MenuItemConfig(
                    label: 'Destructive Action',
                    icon: WnIcons.logout,
                    type: WnMenuItemType.destructive,
                  ),
                ],
              ),
            ),
            _MenuExample(
              label: 'Without Icons',
              child: _StaticMenu(
                items: const [
                  _MenuItemConfig(label: 'Edit Profile'),
                  _MenuItemConfig(label: 'Preferences'),
                  _MenuItemConfig(
                    label: 'Sign Out',
                    type: WnMenuItemType.destructive,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        const Divider(),
        const SizedBox(height: 24),
        const Text(
          'Interactive Playground',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Use the knobs panel to customize this menu.',
          style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
        ),
        const SizedBox(height: 16),
        _InteractiveMenu(context: context),
      ],
    ),
  );
}

Widget _buildSection(String title, String description, List<Widget> children) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(
        description,
        style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
      ),
      const SizedBox(height: 16),
      Wrap(spacing: 24, runSpacing: 24, children: children),
    ],
  );
}

class _MenuItemExample extends StatelessWidget {
  const _MenuItemExample({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _MenuExample extends StatelessWidget {
  const _MenuExample({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 8),
          Container(
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
            child: child,
          ),
        ],
      ),
    );
  }
}

class _StaticMenuItem extends StatelessWidget {
  const _StaticMenuItem({
    required this.menuLabel,
    this.icon,
    this.type = WnMenuItemType.primary,
  });

  final String menuLabel;
  final WnIcons? icon;
  final WnMenuItemType type;

  @override
  Widget build(BuildContext context) {
    return WnMenuItem(label: menuLabel, icon: icon, type: type, onTap: () {});
  }
}

class _MenuItemConfig {
  const _MenuItemConfig({
    required this.label,
    this.icon,
    this.type = WnMenuItemType.primary,
  });

  final String label;
  final WnIcons? icon;
  final WnMenuItemType type;
}

class _StaticMenu extends StatelessWidget {
  const _StaticMenu({required this.items});

  final List<_MenuItemConfig> items;

  @override
  Widget build(BuildContext context) {
    return WnMenu(
      children: items
          .map(
            (item) => WnMenuItem(
              label: item.label,
              icon: item.icon,
              type: item.type,
              onTap: () {},
            ),
          )
          .toList(),
    );
  }
}

class _InteractiveMenuItem extends StatelessWidget {
  const _InteractiveMenuItem({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final icon = this.context.knobs.boolean(
      label: 'Show Icon',
      initialValue: true,
    );

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: WnMenuItem(
        label: this.context.knobs.string(
          label: 'Label',
          initialValue: 'Menu Item',
        ),
        icon: icon
            ? this.context.knobs.object.dropdown<WnIcons>(
                label: 'Icon',
                options: [WnIcons.settings, WnIcons.user, WnIcons.logout],
                initialOption: WnIcons.settings,
                labelBuilder: (value) => value.name,
              )
            : null,
        type: this.context.knobs.object.dropdown<WnMenuItemType>(
          label: 'Type',
          options: WnMenuItemType.values,
          initialOption: WnMenuItemType.primary,
          labelBuilder: (value) => value.name,
        ),
        onTap: () {},
      ),
    );
  }
}

class _InteractiveMenu extends StatelessWidget {
  const _InteractiveMenu({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final itemCount = this.context.knobs.int.slider(
      label: 'Item Count',
      initialValue: 3,
      min: 1,
      max: 6,
    );

    final showIcons = this.context.knobs.boolean(
      label: 'Show Icons',
      initialValue: true,
    );

    final includeDestructive = this.context.knobs.boolean(
      label: 'Include Destructive Item',
      initialValue: true,
    );

    final icons = [
      WnIcons.user,
      WnIcons.settings,
      WnIcons.copy,
      WnIcons.forward,
      WnIcons.edit,
      WnIcons.logout,
    ];

    final labels = ['Profile', 'Settings', 'Copy', 'Forward', 'Edit', 'Logout'];

    return Container(
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
        children: List.generate(itemCount, (index) {
          final isLast = index == itemCount - 1;
          final isDestructive = isLast && includeDestructive;

          return WnMenuItem(
            label: labels[index % labels.length],
            icon: showIcons ? icons[index % icons.length] : null,
            type: isDestructive
                ? WnMenuItemType.destructive
                : WnMenuItemType.primary,
            onTap: () {},
          );
        }),
      ),
    );
  }
}

extension on WnIcons {
  String get name => toString().split('.').last;
}

extension on WnMenuItemType {
  String get name => toString().split('.').last;
}
