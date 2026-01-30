import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

extension on WnIcons {
  String get name => toString().split('.').last;
}

class WnIconStory extends StatelessWidget {
  const WnIconStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Icons', type: WnIconStory)
Widget wnIconShowcase(BuildContext context) {
  return Scaffold(
    backgroundColor: context.colors.backgroundPrimary,
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSection(
          'Icon Library',
          'All available icons in the design system. Each icon is displayed at 24px.',
          [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: WnIcons.values
                  .map((icon) => _IconTile(icon: icon))
                  .toList(),
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
          'Use the knobs panel to customize icon appearance.',
          style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
        ),
        const SizedBox(height: 16),
        _InteractiveIcon(context: context),
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
      ...children,
    ],
  );
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final WnIcons icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: WnIcon(icon, size: 24)),
          ),
          const SizedBox(height: 4),
          Text(
            icon.name,
            style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InteractiveIcon extends StatelessWidget {
  const _InteractiveIcon({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final selectedIcon = this.context.knobs.object.dropdown<WnIcons>(
      label: 'Icon',
      options: WnIcons.values,
      initialOption: WnIcons.placeholder,
      labelBuilder: (value) => value.name,
    );

    final size = this.context.knobs.double.slider(
      label: 'Size',
      initialValue: 24,
      min: 12,
      max: 64,
    );

    final color = this.context.knobs.color(
      label: 'Color',
      initialValue: Colors.black,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          WnIcon(selectedIcon, size: size, color: color),
          const SizedBox(height: 16),
          Text(
            selectedIcon.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            '${size.toInt()}px',
            style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }
}
