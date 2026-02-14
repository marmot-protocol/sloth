import 'package:flutter/material.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_reaction.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class WnReactionStory extends StatelessWidget {
  const WnReactionStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

const _counts = [1, 2, 21, 100];
const _countLabels = ['1', '2', '21', '100'];

@widgetbook.UseCase(name: 'Reaction', type: WnReactionStory)
Widget wnReactionShowcase(BuildContext context) {
  final colors = context.colors;
  final labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: colors.backgroundContentSecondary,
  );

  return Scaffold(
    backgroundColor: colors.backgroundPrimary,
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Playground',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.backgroundContentPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Use the knobs panel to customize this reaction.',
          style: TextStyle(
            fontSize: 14,
            color: colors.backgroundContentSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: _InteractiveReaction(context: context),
        ),
        const SizedBox(height: 32),
        Divider(color: colors.borderTertiary),
        const SizedBox(height: 24),
        Text(
          'All Variants',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.backgroundContentPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Columns show count variants. Rows show type and selection state. Hover to see hover colors.',
          style: TextStyle(
            fontSize: 13,
            color: colors.backgroundContentSecondary,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  const SizedBox.shrink(),
                  for (final label in _countLabels)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 12),
                      child: Text(label, style: labelStyle),
                    ),
                ],
              ),
              _buildRow(
                'Incoming Default',
                WnReactionType.incoming,
                false,
                labelStyle,
              ),
              _buildRow(
                'Incoming Selected',
                WnReactionType.incoming,
                true,
                labelStyle,
              ),
              _buildRow(
                'Outgoing Default',
                WnReactionType.outgoing,
                false,
                labelStyle,
              ),
              _buildRow(
                'Outgoing Selected',
                WnReactionType.outgoing,
                true,
                labelStyle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: colors.borderTertiary),
        const SizedBox(height: 24),
        Text(
          'Different Emojis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.backgroundContentPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Various emoji reactions.',
          style: TextStyle(
            fontSize: 13,
            color: colors.backgroundContentSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            WnReaction(
              emoji: '😀',
              count: 5,
              type: WnReactionType.incoming,
              onTap: () {},
            ),
            WnReaction(
              emoji: '❤️',
              count: 3,
              type: WnReactionType.incoming,
              onTap: () {},
            ),
            WnReaction(
              emoji: '😂',
              count: 2,
              type: WnReactionType.incoming,
              onTap: () {},
            ),
            WnReaction(
              emoji: '🔥',
              type: WnReactionType.incoming,
              onTap: () {},
            ),
          ],
        ),
      ],
    ),
  );
}

TableRow _buildRow(
  String label,
  WnReactionType type,
  bool isSelected,
  TextStyle labelStyle,
) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.only(right: 16, bottom: 8),
        child: Text(label, style: labelStyle),
      ),
      for (final count in _counts)
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: WnReaction(
            emoji: '😀',
            count: count,
            isSelected: isSelected,
            type: type,
            onTap: () {},
          ),
        ),
    ],
  );
}

class _InteractiveReaction extends StatelessWidget {
  const _InteractiveReaction({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final type = this.context.knobs.object.dropdown<WnReactionType>(
      label: 'Type',
      options: WnReactionType.values,
      initialOption: WnReactionType.incoming,
      labelBuilder: (value) => value.name,
    );

    final emoji = this.context.knobs.string(label: 'Emoji', initialValue: '😀');
    final count = this.context.knobs.int.input(label: 'Count', initialValue: 1);
    final isSelected = this.context.knobs.boolean(
      label: 'Is Selected',
      initialValue: false,
    );

    return WnReaction(
      emoji: emoji,
      count: count > 0 ? count : null,
      isSelected: isSelected,
      type: type,
      onTap: () {},
    );
  }
}
