import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_list.dart';
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
              items: const [
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
          'With Subtitles',
          'List items can have subtitles.',
          [
            _ListExample(
              label: 'With Subtitles',
              child: WnList(
                items: const [
                  WnListItem(title: 'Messages', subtitle: 'View your messages'),
                  WnListItem(
                    title: 'Notifications',
                    subtitle: 'Manage notification settings',
                  ),
                  WnListItem(
                    title: 'Privacy',
                    subtitle: 'Control your privacy options',
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'With Icons',
          'List items can have leading and trailing widgets.',
          [
            _ListExample(
              label: 'Leading Icons',
              child: WnList(
                items: [
                  WnListItem(
                    title: 'Profile',
                    leading: WnIcon(
                      WnIcons.user,
                      color: context.colors.backgroundContentPrimary,
                    ),
                  ),
                  WnListItem(
                    title: 'Settings',
                    leading: WnIcon(
                      WnIcons.settings,
                      color: context.colors.backgroundContentPrimary,
                    ),
                  ),
                  WnListItem(
                    title: 'Help',
                    leading: WnIcon(
                      WnIcons.information,
                      color: context.colors.backgroundContentPrimary,
                    ),
                  ),
                ],
              ),
            ),
            _ListExample(
              label: 'Trailing Icons',
              child: WnList(
                items: [
                  WnListItem(
                    title: 'Account',
                    trailing: WnIcon(
                      WnIcons.chevronRight,
                      color: context.colors.backgroundContentPrimary,
                    ),
                  ),
                  WnListItem(
                    title: 'Security',
                    trailing: WnIcon(
                      WnIcons.chevronRight,
                      color: context.colors.backgroundContentPrimary,
                    ),
                  ),
                  WnListItem(
                    title: 'About',
                    trailing: WnIcon(
                      WnIcons.chevronRight,
                      color: context.colors.backgroundContentPrimary,
                    ),
                  ),
                ],
              ),
            ),
            _ListExample(
              label: 'Both Icons',
              child: WnList(
                items: [
                  WnListItem(
                    title: 'Edit Profile',
                    subtitle: 'Update your information',
                    leading: WnIcon(
                      WnIcons.user,
                      color: context.colors.backgroundContentPrimary,
                    ),
                    trailing: WnIcon(
                      WnIcons.chevronRight,
                      color: context.colors.backgroundContentPrimary,
                    ),
                  ),
                  WnListItem(
                    title: 'Preferences',
                    subtitle: 'Customize your experience',
                    leading: WnIcon(
                      WnIcons.settings,
                      color: context.colors.backgroundContentPrimary,
                    ),
                    trailing: WnIcon(
                      WnIcons.chevronRight,
                      color: context.colors.backgroundContentPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Separators',
          'Lists can show or hide separators between items.',
          [
            _ListExample(
              label: 'With Separators',
              child: WnList(
                items: const [
                  WnListItem(title: 'Item One'),
                  WnListItem(title: 'Item Two'),
                  WnListItem(title: 'Item Three'),
                ],
              ),
            ),
            _ListExample(
              label: 'Without Separators',
              child: WnList(
                showSeparators: false,
                items: const [
                  WnListItem(title: 'Item One'),
                  WnListItem(title: 'Item Two'),
                  WnListItem(title: 'Item Three'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Selection State',
          'List items can show selection state.',
          [
            _ListExample(
              label: 'Selected Item',
              child: WnList(
                items: [
                  const WnListItem(title: 'Not Selected'),
                  const WnListItem(title: 'Selected', isSelected: true),
                  const WnListItem(title: 'Not Selected'),
                ],
              ),
            ),
            _ListExample(
              label: 'With Checkmarks',
              child: WnList(
                items: [
                  WnListItem(
                    title: 'Option A',
                    trailing: WnIcon(
                      WnIcons.checkmarkFilled,
                      color: context.colors.intentionSuccessContent,
                    ),
                    isSelected: true,
                  ),
                  const WnListItem(title: 'Option B'),
                  const WnListItem(title: 'Option C'),
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
      width: 320,
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
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.borderTertiary),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
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
    final showSeparators = this.context.knobs.boolean(
      label: 'Show Separators',
      initialValue: true,
    );

    final itemCount = this.context.knobs.int.slider(
      label: 'Number of Items',
      initialValue: 3,
      min: 1,
      max: 10,
    );

    final showSubtitles = this.context.knobs.boolean(
      label: 'Show Subtitles',
      initialValue: false,
    );

    final showLeading = this.context.knobs.boolean(
      label: 'Show Leading Icons',
      initialValue: false,
    );

    final showTrailing = this.context.knobs.boolean(
      label: 'Show Trailing Icons',
      initialValue: false,
    );

    final showSelection = this.context.knobs.boolean(
      label: 'Show Selection (first item)',
      initialValue: false,
    );

    final items = List.generate(itemCount, (index) {
      return WnListItem(
        title: 'Item ${index + 1}',
        subtitle: showSubtitles ? 'Subtitle for item ${index + 1}' : null,
        leading: showLeading
            ? WnIcon(
                WnIcons.user,
                color: context.colors.backgroundContentPrimary,
              )
            : null,
        trailing: showTrailing
            ? WnIcon(
                WnIcons.chevronRight,
                color: context.colors.backgroundContentPrimary,
              )
            : null,
        isSelected: showSelection && index == 0,
      );
    });

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.borderTertiary),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: WnList(items: items, showSeparators: showSeparators),
    );
  }
}
