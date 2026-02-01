import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class WnButtonStory extends StatelessWidget {
  const WnButtonStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Button', type: WnButtonStory)
Widget wnButtonShowcase(BuildContext context) {
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
          'Use the knobs panel to customize this button.',
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
            child: _InteractiveButton(context: context),
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Button Types',
          'WnButton comes in 5 types: primary, outline, ghost, overlay, and destructive.',
          [
            _ButtonExample(
              label: 'Primary',
              child: WnButton(
                text: 'Primary',
                type: WnButtonType.primary,
                onPressed: () {},
              ),
            ),
            _ButtonExample(
              label: 'Outline',
              child: WnButton(
                text: 'Outline',
                type: WnButtonType.outline,
                onPressed: () {},
              ),
            ),
            _ButtonExample(
              label: 'Ghost',
              child: WnButton(
                text: 'Ghost',
                type: WnButtonType.ghost,
                onPressed: () {},
              ),
            ),
            _ButtonExample(
              label: 'Overlay',
              child: WnButton(
                text: 'Overlay',
                type: WnButtonType.overlay,
                onPressed: () {},
              ),
            ),
            _ButtonExample(
              label: 'Destructive',
              child: WnButton(
                text: 'Destructive',
                type: WnButtonType.destructive,
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Size Variants',
          'Buttons come in 3 sizes: large (default), medium, and small.',
          [
            _ButtonExample(
              label: 'Large',
              child: WnButton(
                text: 'Large Button',
                size: WnButtonSize.large,
                onPressed: () {},
              ),
            ),
            _ButtonExample(
              label: 'Medium',
              child: WnButton(
                text: 'Medium Button',
                size: WnButtonSize.medium,
                onPressed: () {},
              ),
            ),
            _ButtonExample(
              label: 'Small',
              child: WnButton(
                text: 'Small Button',
                size: WnButtonSize.small,
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'States',
          'Buttons can be in normal, disabled, or loading state.',
          [
            _ButtonExample(
              label: 'Normal',
              child: WnButton(
                text: 'Normal',
                type: WnButtonType.primary,
                onPressed: () {},
              ),
            ),
            _ButtonExample(
              label: 'Disabled',
              child: WnButton(
                text: 'Disabled',
                type: WnButtonType.primary,
                disabled: true,
                onPressed: () {},
              ),
            ),
            _ButtonExample(
              label: 'Loading',
              child: WnButton(
                text: 'Loading',
                type: WnButtonType.primary,
                loading: true,
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'With Icons',
          'Buttons can have leading, trailing, or both icons.',
          [
            _ButtonExample(
              label: 'No Icons',
              child: WnButton(text: 'No Icons', onPressed: () {}),
            ),
            _ButtonExample(
              label: 'Leading Icon',
              child: WnButton(
                text: 'Leading',
                leadingIcon: WnIcons.addCircle,
                onPressed: () {},
              ),
            ),
            _ButtonExample(
              label: 'Trailing Icon',
              child: WnButton(
                text: 'Trailing',
                trailingIcon: WnIcons.arrowRight,
                onPressed: () {},
              ),
            ),
            _ButtonExample(
              label: 'Both Icons',
              child: WnButton(
                text: 'Both',
                leadingIcon: WnIcons.addCircle,
                trailingIcon: WnIcons.arrowRight,
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Complete Examples',
          'Combinations of type, size, state, and icons.',
          [
            _ButtonExample(
              label: 'Primary + Small + Icon',
              child: WnButton(
                text: 'Add Item',
                type: WnButtonType.primary,
                size: WnButtonSize.small,
                leadingIcon: WnIcons.addCircle,
                onPressed: () {},
              ),
            ),
            _ButtonExample(
              label: 'Outline + Medium + Icons',
              child: WnButton(
                text: 'Continue',
                type: WnButtonType.outline,
                size: WnButtonSize.medium,
                trailingIcon: WnIcons.arrowRight,
                onPressed: () {},
              ),
            ),
            _ButtonExample(
              label: 'Destructive + Large',
              child: WnButton(
                text: 'Delete Account',
                type: WnButtonType.destructive,
                size: WnButtonSize.large,
                leadingIcon: WnIcons.closeLarge,
                onPressed: () {},
              ),
            ),
            _ButtonExample(
              label: 'Ghost + Disabled',
              child: WnButton(
                text: 'Disabled Ghost',
                type: WnButtonType.ghost,
                disabled: true,
                onPressed: () {},
              ),
            ),
            _ButtonExample(
              label: 'Overlay + Loading',
              child: WnButton(
                text: 'Saving...',
                type: WnButtonType.overlay,
                loading: true,
                onPressed: () {},
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

class _ButtonExample extends StatelessWidget {
  const _ButtonExample({required this.label, required this.child});

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

class _InteractiveButton extends StatelessWidget {
  const _InteractiveButton({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final type = this.context.knobs.object.dropdown<WnButtonType>(
      label: 'Type',
      options: WnButtonType.values,
      initialOption: WnButtonType.primary,
      labelBuilder: (value) => value.name,
    );

    final size = this.context.knobs.object.dropdown<WnButtonSize>(
      label: 'Size',
      options: WnButtonSize.values,
      initialOption: WnButtonSize.large,
      labelBuilder: (value) => value.name,
    );

    final showLeadingIcon = this.context.knobs.boolean(
      label: 'Show Leading Icon',
      initialValue: false,
    );

    final showTrailingIcon = this.context.knobs.boolean(
      label: 'Show Trailing Icon',
      initialValue: false,
    );

    final leadingIconOption = showLeadingIcon
        ? this.context.knobs.object.dropdown<WnIcons>(
            label: 'Leading Icon',
            options: [
              WnIcons.addCircle,
              WnIcons.arrowLeft,
              WnIcons.checkmarkFilled,
              WnIcons.closeLarge,
            ],
            initialOption: WnIcons.addCircle,
            labelBuilder: (value) => value.name,
          )
        : null;

    final trailingIconOption = showTrailingIcon
        ? this.context.knobs.object.dropdown<WnIcons>(
            label: 'Trailing Icon',
            options: [
              WnIcons.arrowRight,
              WnIcons.chevronRight,
              WnIcons.information,
            ],
            initialOption: WnIcons.arrowRight,
            labelBuilder: (value) => value.name,
          )
        : null;

    return WnButton(
      text: this.context.knobs.string(label: 'Text', initialValue: 'Button'),
      type: type,
      size: size,
      loading: this.context.knobs.boolean(
        label: 'Loading',
        initialValue: false,
      ),
      disabled: this.context.knobs.boolean(
        label: 'Disabled',
        initialValue: false,
      ),
      leadingIcon: leadingIconOption,
      trailingIcon: trailingIconOption,
      onPressed: () {},
    );
  }
}

extension WnIconsExtension on WnIcons {
  String get name => toString().split('.').last;
}
