import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_filter_chip.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class WnFilterChipStory extends StatelessWidget {
  const WnFilterChipStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Filter Chip', type: WnFilterChipStory)
Widget wnFilterChipShowcase(BuildContext context) {
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
          'Use the knobs panel to customize this filter chip.',
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
            child: _InteractiveFilterChip(context: context),
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Variants',
          'WnFilterChip comes in 2 variants: Standard (sits in the flow) and Elevated (used in sticky filter bars with shadow).',
          [
            _FilterChipExample(
              label: 'Standard',
              child: _FilterChipGroup(variant: WnFilterChipVariant.standard),
            ),
            _FilterChipExample(
              label: 'Elevated',
              child: _FilterChipGroup(variant: WnFilterChipVariant.elevated),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'States',
          'Filter chips have 3 states: Default, Hover, and Active (selected).',
          [
            _FilterChipExample(
              label: 'Default',
              child: WnFilterChip(
                label: 'Filter',
                selected: false,
                onSelected: (_) {},
              ),
            ),
            _FilterChipExample(
              label: 'Active (Selected)',
              child: WnFilterChip(
                label: 'Filter',
                selected: true,
                onSelected: (_) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Usage Examples',
          'Filter chips are commonly used for filtering chat lists.',
          [
            _FilterChipExample(
              label: 'Chat Filters',
              child: _ChatFiltersExample(),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Elevated Variant with Scrolling Content',
          'The elevated variant is used when chips sit in a sticky filter bar and overlay scrolled content.',
          [
            _FilterChipExample(
              label: 'Sticky Filter Bar',
              child: _StickyFilterBarExample(),
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

class _FilterChipExample extends StatelessWidget {
  const _FilterChipExample({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
    );
  }
}

class _InteractiveFilterChip extends StatefulWidget {
  const _InteractiveFilterChip({required this.context});

  final BuildContext context;

  @override
  State<_InteractiveFilterChip> createState() => _InteractiveFilterChipState();
}

class _InteractiveFilterChipState extends State<_InteractiveFilterChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final variant = widget.context.knobs.object.dropdown<WnFilterChipVariant>(
      label: 'Variant',
      options: WnFilterChipVariant.values,
      initialOption: WnFilterChipVariant.standard,
      labelBuilder: (value) => value.name,
    );

    return WnFilterChip(
      label: widget.context.knobs.string(
        label: 'Label',
        initialValue: 'Filter',
      ),
      selected: _selected,
      onSelected: (value) => setState(() => _selected = value),
      variant: variant,
    );
  }
}

class _FilterChipGroup extends StatefulWidget {
  const _FilterChipGroup({required this.variant});

  final WnFilterChipVariant variant;

  @override
  State<_FilterChipGroup> createState() => _FilterChipGroupState();
}

class _FilterChipGroupState extends State<_FilterChipGroup> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final labels = ['All', 'Unread', 'Favorites'];

    return Wrap(
      spacing: 8,
      children: List.generate(labels.length, (index) {
        return WnFilterChip(
          label: labels[index],
          selected: _selectedIndex == index,
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedIndex = index);
            }
          },
          variant: widget.variant,
        );
      }),
    );
  }
}

class _ChatFiltersExample extends StatefulWidget {
  @override
  State<_ChatFiltersExample> createState() => _ChatFiltersExampleState();
}

class _ChatFiltersExampleState extends State<_ChatFiltersExample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final labels = ['All', 'Unread', 'Archived', 'Favorites', 'Groups'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(labels.length, (index) {
        return WnFilterChip(
          label: labels[index],
          selected: _selectedIndex == index,
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedIndex = index);
            }
          },
        );
      }),
    );
  }
}

class _StickyFilterBarExample extends StatefulWidget {
  @override
  State<_StickyFilterBarExample> createState() =>
      _StickyFilterBarExampleState();
}

class _StickyFilterBarExampleState extends State<_StickyFilterBarExample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final labels = ['All', 'Unread', 'Archived'];

    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.borderTertiary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.backgroundPrimary,
              border: Border(
                bottom: BorderSide(color: context.colors.borderTertiary),
              ),
            ),
            child: Row(
              children: List.generate(labels.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < labels.length - 1 ? 8 : 0,
                  ),
                  child: WnFilterChip(
                    label: labels[index],
                    selected: _selectedIndex == index,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedIndex = index);
                      }
                    },
                    variant: WnFilterChipVariant.elevated,
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: Container(
              color: context.colors.backgroundSecondary,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.backgroundPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Chat item ${index + 1}',
                      style: TextStyle(
                        color: context.colors.backgroundContentPrimary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension WnFilterChipVariantExtension on WnFilterChipVariant {
  String get name => toString().split('.').last;
}
