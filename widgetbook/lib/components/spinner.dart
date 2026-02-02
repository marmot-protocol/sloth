import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_spinner.dart';
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
          child: _InteractiveSpinner(context: context),
        ),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Size Variants',
          'WnSpinner comes in 3 sizes: small, medium (default), and large.',
          [
            _SpinnerExample(
              label: 'Small',
              child: WnSpinner(size: WnSpinnerSize.small),
            ),
            _SpinnerExample(
              label: 'Medium',
              child: WnSpinner(size: WnSpinnerSize.medium),
            ),
            _SpinnerExample(
              label: 'Large',
              child: WnSpinner(size: WnSpinnerSize.large),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'With Label',
          'Spinners can have an optional label displayed below.',
          [
            _SpinnerExample(label: 'No Label', child: WnSpinner()),
            _SpinnerExample(
              label: 'With Label',
              child: WnSpinner(label: 'Loading...'),
            ),
            _SpinnerExample(
              label: 'Large + Label',
              child: WnSpinner(size: WnSpinnerSize.large, label: 'Please wait'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Custom Colors',
          'Spinners can use custom colors to match different contexts.',
          [
            _SpinnerExample(label: 'Default', child: WnSpinner()),
            _SpinnerExample(
              label: 'Info',
              child: WnSpinner(color: context.colors.intentionInfoContent),
            ),
            _SpinnerExample(
              label: 'Error',
              child: WnSpinner(color: context.colors.intentionErrorContent),
            ),
            _SpinnerExample(
              label: 'Success',
              child: WnSpinner(color: context.colors.intentionSuccessContent),
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
  const _SpinnerExample({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
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

class _InteractiveSpinner extends StatelessWidget {
  const _InteractiveSpinner({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final size = this.context.knobs.object.dropdown<WnSpinnerSize>(
      label: 'Size',
      options: WnSpinnerSize.values,
      initialOption: WnSpinnerSize.medium,
      labelBuilder: (value) => value.name,
    );

    final labelText = this.context.knobs.string(
      label: 'Label',
      initialValue: '',
    );

    final useCustomColor = this.context.knobs.boolean(
      label: 'Use Custom Color',
      initialValue: false,
    );

    final customColor = useCustomColor
        ? this.context.knobs.object.dropdown<_ColorOption>(
            label: 'Color',
            options: _ColorOption.values,
            initialOption: _ColorOption.info,
            labelBuilder: (value) => value.name,
          )
        : null;

    return WnSpinner(
      size: size,
      label: labelText.isEmpty ? null : labelText,
      color: customColor?.toColor(this.context),
    );
  }
}

enum _ColorOption {
  info,
  error,
  success,
  warning;

  Color toColor(BuildContext context) {
    return switch (this) {
      _ColorOption.info => context.colors.intentionInfoContent,
      _ColorOption.error => context.colors.intentionErrorContent,
      _ColorOption.success => context.colors.intentionSuccessContent,
      _ColorOption.warning => context.colors.intentionWarningContent,
    };
  }
}

extension on WnSpinnerSize {
  String get name => toString().split('.').last;
}

extension on _ColorOption {
  String get name => toString().split('.').last;
}
