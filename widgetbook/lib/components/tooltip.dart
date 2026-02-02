import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_tooltip.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class WnTooltipStory extends StatelessWidget {
  const WnTooltipStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Tooltip', type: WnTooltipStory)
Widget wnTooltipShowcase(BuildContext context) {
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
          'Hover or long-press the button to see the tooltip.',
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: _InteractiveTooltip(context: context),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Positions',
          'Tooltips can appear in 4 positions: top, bottom, left, right.',
          [
            _TooltipExample(
              label: 'Top',
              child: WnTooltip(
                message: 'Tooltip on top',
                position: WnTooltipPosition.top,
                child: WnButton(text: 'Top', onPressed: () {}),
              ),
            ),
            _TooltipExample(
              label: 'Bottom',
              child: WnTooltip(
                message: 'Tooltip on bottom',
                position: WnTooltipPosition.bottom,
                child: WnButton(text: 'Bottom', onPressed: () {}),
              ),
            ),
            _TooltipExample(
              label: 'Left',
              child: WnTooltip(
                message: 'Tooltip on left',
                position: WnTooltipPosition.left,
                child: WnButton(text: 'Left', onPressed: () {}),
              ),
            ),
            _TooltipExample(
              label: 'Right',
              child: WnTooltip(
                message: 'Tooltip on right',
                position: WnTooltipPosition.right,
                child: WnButton(text: 'Right', onPressed: () {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Arrow',
          'Tooltips can show or hide the arrow.',
          [
            _TooltipExample(
              label: 'With Arrow',
              child: WnTooltip(
                message: 'Has an arrow',
                showArrow: true,
                child: WnButton(text: 'With Arrow', onPressed: () {}),
              ),
            ),
            _TooltipExample(
              label: 'Without Arrow',
              child: WnTooltip(
                message: 'No arrow',
                showArrow: false,
                child: WnButton(text: 'Without Arrow', onPressed: () {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Content',
          'Tooltips display text messages of varying lengths.',
          [
            _TooltipExample(
              label: 'Short Message',
              child: WnTooltip(
                message: 'Hi!',
                child: WnButton(text: 'Short', onPressed: () {}),
              ),
            ),
            _TooltipExample(
              label: 'Medium Message',
              child: WnTooltip(
                message: 'Click to perform action',
                child: WnButton(text: 'Medium', onPressed: () {}),
              ),
            ),
            _TooltipExample(
              label: 'Long Message',
              child: WnTooltip(
                message:
                    'This is a longer tooltip message that provides more context',
                child: WnButton(text: 'Long', onPressed: () {}),
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

class _TooltipExample extends StatelessWidget {
  const _TooltipExample({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
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

class _InteractiveTooltip extends StatelessWidget {
  const _InteractiveTooltip({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final position = this.context.knobs.object.dropdown<WnTooltipPosition>(
      label: 'Position',
      options: WnTooltipPosition.values,
      initialOption: WnTooltipPosition.top,
      labelBuilder: (value) => value.name,
    );

    final message = this.context.knobs.string(
      label: 'Message',
      initialValue: 'Tooltip message',
    );

    final showArrow = this.context.knobs.boolean(
      label: 'Show Arrow',
      initialValue: true,
    );

    return WnTooltip(
      message: message,
      position: position,
      showArrow: showArrow,
      child: WnButton(text: 'Hover me', onPressed: () {}),
    );
  }
}

extension WnTooltipPositionExtension on WnTooltipPosition {
  String get name => toString().split('.').last;
}
