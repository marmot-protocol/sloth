import 'package:flutter/material.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_icon.dart';
import 'package:whitenoise/widgets/wn_list.dart';
import 'package:whitenoise/widgets/wn_list_item.dart';
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
          'With Type Icons',
          'List items can show different type icons.',
          [
            _ListExample(
              label: 'All Types',
              child: WnList(
                children: const [
                  WnListItem(
                    title: 'Neutral with custom icon',
                    type: WnListItemType.neutral,
                    leadingIcon: WnIcons.placeholder,
                  ),
                  WnListItem(
                    title: 'Success Item',
                    type: WnListItemType.success,
                  ),
                  WnListItem(
                    title: 'Warning Item',
                    type: WnListItemType.warning,
                  ),
                  WnListItem(title: 'Error Item', type: WnListItemType.error),
                ],
              ),
            ),
            _ListExample(
              label: 'Neutral without icon',
              child: WnList(
                children: const [
                  WnListItem(
                    title: 'Item without icon',
                    type: WnListItemType.neutral,
                  ),
                  WnListItem(
                    title: 'Another item without icon',
                    type: WnListItemType.neutral,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'With Actions',
          'List items can have expandable action buttons.',
          [
            _ListExample(
              label: 'With Actions Menu',
              child: WnList(
                children: [
                  WnListItem(
                    title: 'Editable Item',
                    type: WnListItemType.neutral,
                    leadingIcon: WnIcons.placeholder,
                    actions: [
                      WnListItemAction(label: 'Edit', onTap: () {}),
                      WnListItemAction(label: 'Duplicate', onTap: () {}),
                      WnListItemAction(
                        label: 'Delete',
                        onTap: () {},
                        isDestructive: true,
                      ),
                    ],
                  ),
                  WnListItem(
                    title: 'Another Item',
                    type: WnListItemType.success,
                    actions: [
                      WnListItemAction(label: 'Edit', onTap: () {}),
                      WnListItemAction(
                        label: 'Delete',
                        onTap: () {},
                        isDestructive: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Interactive States',
          'List items respond to tap/press interactions.',
          [
            _ListExample(
              label: 'Tap to see pressed state',
              child: WnList(
                children: [
                  const WnListItem(
                    title: 'Tap and hold me',
                    type: WnListItemType.success,
                  ),
                  WnListItem(
                    title: 'Tap the menu to expand',
                    type: WnListItemType.neutral,
                    leadingIcon: WnIcons.placeholder,
                    actions: [
                      WnListItemAction(label: 'Edit', onTap: () {}),
                      WnListItemAction(
                        label: 'Delete',
                        onTap: () {},
                        isDestructive: true,
                      ),
                    ],
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

    final typeIndex = this.context.knobs.int.slider(
      label: 'Item Type (0=neutral, 1=success, 2=warning, 3=error)',
      initialValue: 1,
      min: 0,
      max: 3,
    );

    final showLeadingIcon = this.context.knobs.boolean(
      label: 'Show Leading Icon (neutral type only)',
      initialValue: true,
    );

    final showActions = this.context.knobs.boolean(
      label: 'Show Actions Menu',
      initialValue: true,
    );

    final type = WnListItemType.values[typeIndex];

    final children = List.generate(itemCount, (index) {
      return WnListItem(
        title: 'List Item ${index + 1}',
        type: type,
        leadingIcon: (type == WnListItemType.neutral && showLeadingIcon)
            ? WnIcons.placeholder
            : null,
        actions: showActions
            ? [
                WnListItemAction(label: 'Edit', onTap: () {}),
                WnListItemAction(
                  label: 'Delete',
                  onTap: () {},
                  isDestructive: true,
                ),
              ]
            : null,
      );
    });

    return WnList(children: children);
  }
}
