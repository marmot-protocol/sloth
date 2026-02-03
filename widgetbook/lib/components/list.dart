import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_list.dart';
import 'package:sloth/widgets/wn_list_item.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class WnListStory extends StatelessWidget {
  const WnListStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'List', type: WnListStory)
Widget wnListShowcase(BuildContext context) {
  return Scaffold(
    backgroundColor: context.colors.backgroundPrimary,
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Playground',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: context.colors.backgroundContentPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Use the knobs panel to customize this list.',
          style: TextStyle(
            fontSize: 14,
            color: context.colors.backgroundContentSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 375),
            child: _InteractiveList(context: context),
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
        _buildSection(context, 'Basic List', 'Simple list with titles only.', [
          _ListExample(
            label: 'Titles Only',
            child: WnList(
              children: const [
                WnListItem(title: 'First Item'),
                WnListItem(title: 'Second Item'),
                WnListItem(title: 'Third Item'),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'With Icons',
          'List items can have leading and trailing widgets.',
          [
            _ListExample(
              label: 'Leading Icons',
              child: WnList(
                children: [
                  WnListItem(
                    title: 'Profile',
                    leading: WnIcon(
                      WnIcons.user,
                      color: context.colors.fillContentSecondary,
                    ),
                  ),
                  WnListItem(
                    title: 'Settings',
                    leading: WnIcon(
                      WnIcons.settings,
                      color: context.colors.fillContentSecondary,
                    ),
                  ),
                  WnListItem(
                    title: 'Help',
                    leading: WnIcon(
                      WnIcons.information,
                      color: context.colors.fillContentSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _ListExample(
              label: 'Trailing Icons',
              child: WnList(
                children: [
                  WnListItem(
                    title: 'Account',
                    trailing: WnIcon(
                      WnIcons.more,
                      color: context.colors.fillContentSecondary,
                    ),
                  ),
                  WnListItem(
                    title: 'Security',
                    trailing: WnIcon(
                      WnIcons.more,
                      color: context.colors.fillContentSecondary,
                    ),
                  ),
                  WnListItem(
                    title: 'About',
                    trailing: WnIcon(
                      WnIcons.more,
                      color: context.colors.fillContentSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _ListExample(
              label: 'Both Icons',
              child: WnList(
                children: [
                  WnListItem(
                    title: 'Edit Profile',
                    leading: WnIcon(
                      WnIcons.user,
                      color: context.colors.fillContentSecondary,
                    ),
                    trailing: WnIcon(
                      WnIcons.more,
                      color: context.colors.fillContentSecondary,
                    ),
                  ),
                  WnListItem(
                    title: 'Preferences',
                    leading: WnIcon(
                      WnIcons.settings,
                      color: context.colors.fillContentSecondary,
                    ),
                    trailing: WnIcon(
                      WnIcons.more,
                      color: context.colors.fillContentSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildSection(
  BuildContext context,
  String title,
  String description,
  List<Widget> children,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.colors.backgroundContentPrimary,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        description,
        style: TextStyle(
          fontSize: 13,
          color: context.colors.backgroundContentSecondary,
        ),
      ),
      const SizedBox(height: 16),
      Wrap(spacing: 24, runSpacing: 24, children: children),
    ],
  );
}

class _ListExample extends StatelessWidget {
  const _ListExample({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 368,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.backgroundContentSecondary,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _InteractiveList extends StatelessWidget {
  const _InteractiveList({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final itemCount = this.context.knobs.int.slider(
      label: 'Number of Items',
      initialValue: 3,
      min: 1,
      max: 10,
    );

    final showLeading = this.context.knobs.boolean(
      label: 'Show Leading Icons',
      initialValue: true,
    );

    final showTrailing = this.context.knobs.boolean(
      label: 'Show Trailing Icons',
      initialValue: true,
    );

    final children = List.generate(itemCount, (index) {
      return WnListItem(
        title: 'List Item ${index + 1}',
        leading: showLeading
            ? WnIcon(
                WnIcons.placeholder,
                color: context.colors.fillContentSecondary,
              )
            : null,
        trailing: showTrailing
            ? WnIcon(WnIcons.more, color: context.colors.fillContentSecondary)
            : null,
      );
    });

    return WnList(children: children);
  }
}
