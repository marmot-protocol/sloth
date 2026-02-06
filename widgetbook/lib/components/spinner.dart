import 'package:flutter/material.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_spinner.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class WnSpinnerStory extends StatelessWidget {
  const WnSpinnerStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Spinner', type: WnSpinnerStory)
Widget wnSpinnerShowcase(BuildContext context) {
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
          'Use the knobs panel to customize this spinner.',
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
            child: _InteractiveSpinner(context: context),
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Type Variants',
          'WnSpinner comes in 3 types: primary (on primary buttons), secondary (on outline buttons), and destructive (on destructive buttons).',
          [
            _SpinnerExample(
              label: 'Primary',
              description: 'Use on primary buttons',
              child: WnSpinner(type: WnSpinnerType.primary),
            ),
            _SpinnerExample(
              label: 'Secondary',
              description: 'Use on outline buttons',
              child: WnSpinner(type: WnSpinnerType.secondary),
            ),
            _SpinnerExample(
              label: 'Destructive',
              description: 'Use on destructive buttons',
              child: WnSpinner(type: WnSpinnerType.destructive),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Usage Context',
          'Spinners are designed to show loading state within buttons. Each type matches its corresponding button style.',
          [
            _SpinnerContextExample(
              label: 'Primary Button',
              backgroundColor: context.colors.fillPrimary,
              child: WnSpinner(type: WnSpinnerType.primary),
            ),
            _SpinnerContextExample(
              label: 'Outline Button',
              backgroundColor: context.colors.backgroundPrimary,
              borderColor: context.colors.borderPrimary,
              child: WnSpinner(type: WnSpinnerType.secondary),
            ),
            _SpinnerContextExample(
              label: 'Destructive Button',
              backgroundColor: context.colors.fillDestructive,
              child: WnSpinner(type: WnSpinnerType.destructive),
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

class _SpinnerExample extends StatelessWidget {
  const _SpinnerExample({
    required this.label,
    required this.description,
    required this.child,
  });

  final String label;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.backgroundContentPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
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

class _SpinnerContextExample extends StatelessWidget {
  const _SpinnerContextExample({
    required this.label,
    required this.backgroundColor,
    required this.child,
    this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color? borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: borderColor != null
                  ? Border.all(color: borderColor!)
                  : null,
            ),
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}

class _InteractiveSpinner extends StatelessWidget {
  const _InteractiveSpinner({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final type = this.context.knobs.object.dropdown<WnSpinnerType>(
      label: 'Type',
      options: WnSpinnerType.values,
      initialOption: WnSpinnerType.primary,
      labelBuilder: (value) => value.name,
    );

    return WnSpinner(type: type);
  }
}

extension on WnSpinnerType {
  String get name => toString().split('.').last;
}
