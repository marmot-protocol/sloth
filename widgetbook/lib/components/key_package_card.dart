import 'package:flutter/material.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_key_package_card.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class WnKeyPackageCardStory extends StatelessWidget {
  const WnKeyPackageCardStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Key Package Card', type: WnKeyPackageCardStory)
Widget wnKeyPackageCardShowcase(BuildContext context) {
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
          'Use the knobs panel to customize this key package card.',
          style: TextStyle(
            fontSize: 14,
            color: context.colors.backgroundContentSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 368),
            child: _InteractiveCard(context: context),
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Multiple Cards',
          'How cards look when displayed in a list.',
          [
            SizedBox(
              width: 368,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WnKeyPackageCard(
                    title: 'Key Package #1',
                    packageId:
                        '7fbc6a4207913cf327b00bc66718886b009206a4c56c677bf5f2f08a6ff4e3ed',
                    createdAt: '2026-01-28T21:00:42.000Z',
                    onDelete: () {},
                    deleteLabel: 'Delete',
                  ),
                  const SizedBox(height: 8),
                  WnKeyPackageCard(
                    title: 'Key Package #2',
                    packageId:
                        'abc123def456abc123def456abc123def456abc123def456abc123def456abcd',
                    createdAt: '2026-01-15T10:30:00.000Z',
                    onDelete: () {},
                    deleteLabel: 'Delete',
                  ),
                  const SizedBox(height: 8),
                  WnKeyPackageCard(
                    title: 'Key Package #3',
                    packageId:
                        'deadbeef1234567890abcdef1234567890abcdef1234567890abcdef12345678',
                    createdAt: '2026-01-01T00:00:00.000Z',
                    onDelete: () {},
                    deleteLabel: 'Delete',
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

class _InteractiveCard extends StatelessWidget {
  const _InteractiveCard({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return WnKeyPackageCard(
      title: this.context.knobs.string(
        label: 'Title',
        initialValue: 'Key Package #1',
      ),
      packageId: this.context.knobs.string(
        label: 'Package ID',
        initialValue:
            '7fbc6a4207913cf327b00bc66718886b009206a4c56c677bf5f2f08a6ff4e3ed',
      ),
      createdAt: this.context.knobs.string(
        label: 'Created At',
        initialValue: '2026-01-28T21:00:42.000Z',
      ),
      onDelete: () {},
      deleteLabel: 'Delete',
    );
  }
}
