import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_profile_switcher_item.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class WnProfileSwitcherItemStory extends StatelessWidget {
  const WnProfileSwitcherItemStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

const _samplePubkeyA =
    'npub1zuuajd7u3sx8xu92yav9jwxpr839cs0kc3q6t56vd5u9q033xmhsk6c2uc';
const _samplePubkeyB =
    'npub180cvv07tjdrrgpa0j7j7tmnyl2yr6yr7l8j4s3evf6u64th6gkwsyjh6w6';
const _samplePubkeyC =
    'npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg';

@widgetbook.UseCase(
  name: 'Profile Switcher Item',
  type: WnProfileSwitcherItemStory,
)
Widget wnProfileSwitcherItemShowcase(BuildContext context) {
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
          'Use the knobs panel to customize this profile switcher item.',
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
            child: _InteractiveProfileSwitcherItem(context: context),
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'States',
          'Profile switcher item can be in different states: default or selected.',
          [
            _ProfileSwitcherItemExample(
              label: 'Default',
              child: WnProfileSwitcherItem(
                pubkey: _samplePubkeyA,
                displayName: 'Marina Hofmann',
                isSelected: false,
                onTap: () {},
              ),
            ),
            _ProfileSwitcherItemExample(
              label: 'Selected (Active)',
              child: WnProfileSwitcherItem(
                pubkey: _samplePubkeyA,
                displayName: 'Marina Hofmann',
                isSelected: true,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Content Variations',
          'Profile switcher item with different content configurations.',
          [
            _ProfileSwitcherItemExample(
              label: 'With Display Name',
              child: WnProfileSwitcherItem(
                pubkey: _samplePubkeyA,
                displayName: 'Marina Hofmann',
                onTap: () {},
              ),
            ),
            _ProfileSwitcherItemExample(
              label: 'Without Display Name',
              child: WnProfileSwitcherItem(
                pubkey: _samplePubkeyA,
                onTap: () {},
              ),
            ),
            _ProfileSwitcherItemExample(
              label: 'With Long Name',
              child: WnProfileSwitcherItem(
                pubkey: _samplePubkeyB,
                displayName:
                    'This Is A Very Long Display Name That Should Truncate',
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'List Example',
          'Multiple profile switcher items in a list layout.',
          [_ProfileListExample()],
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

class _ProfileSwitcherItemExample extends StatelessWidget {
  const _ProfileSwitcherItemExample({required this.label, required this.child});

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

class _ProfileListExample extends StatefulWidget {
  @override
  State<_ProfileListExample> createState() => _ProfileListExampleState();
}

class _ProfileListExampleState extends State<_ProfileListExample> {
  String _selectedPubkey = _samplePubkeyA;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 368,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selectable List',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.backgroundContentSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              WnProfileSwitcherItem(
                pubkey: _samplePubkeyA,
                displayName: 'Marina Hofmann',
                isSelected: _selectedPubkey == _samplePubkeyA,
                onTap: () => setState(() => _selectedPubkey = _samplePubkeyA),
              ),
              const SizedBox(height: 8),
              WnProfileSwitcherItem(
                pubkey: _samplePubkeyB,
                displayName: 'Bob Smith',
                isSelected: _selectedPubkey == _samplePubkeyB,
                onTap: () => setState(() => _selectedPubkey = _samplePubkeyB),
              ),
              const SizedBox(height: 8),
              WnProfileSwitcherItem(
                pubkey: _samplePubkeyC,
                displayName: 'Charlie Brown',
                isSelected: _selectedPubkey == _samplePubkeyC,
                onTap: () => setState(() => _selectedPubkey = _samplePubkeyC),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InteractiveProfileSwitcherItem extends StatefulWidget {
  const _InteractiveProfileSwitcherItem({required this.context});

  final BuildContext context;

  @override
  State<_InteractiveProfileSwitcherItem> createState() =>
      _InteractiveProfileSwitcherItemState();
}

class _InteractiveProfileSwitcherItemState
    extends State<_InteractiveProfileSwitcherItem> {
  @override
  Widget build(BuildContext context) {
    final displayName = widget.context.knobs.stringOrNull(
      label: 'Display Name',
      initialValue: 'Marina Hofmann',
    );
    final isSelected = widget.context.knobs.boolean(
      label: 'Selected',
      initialValue: false,
    );

    return WnProfileSwitcherItem(
      pubkey: _samplePubkeyA,
      displayName: displayName,
      isSelected: isSelected,
      onTap: () {},
    );
  }
}
