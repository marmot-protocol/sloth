import 'package:flutter/material.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_overlay.dart';
import 'package:whitenoise/widgets/wn_scroll_edge_effect.dart';
import 'package:whitenoise/widgets/wn_separator.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class WnSeparatorStory extends StatelessWidget {
  const WnSeparatorStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Separator', type: WnSeparatorStory)
Widget wnSeparatorShowcase(BuildContext context) {
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
          'Use the knobs panel to customize this separator.',
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
            child: _InteractiveSeparator(context: context),
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Orientation',
          'Separators can be horizontal or vertical.',
          [
            _SeparatorExample(
              label: 'Horizontal (Default)',
              child: Container(
                width: 200,
                height: 60,
                color: context.colors.backgroundSecondary,
                child: const Center(child: WnSeparator()),
              ),
            ),
            _SeparatorExample(
              label: 'Vertical',
              child: Container(
                width: 200,
                height: 60,
                color: context.colors.backgroundSecondary,
                child: const Center(
                  child: SizedBox(
                    height: 40,
                    child: WnSeparator(
                      orientation: WnSeparatorOrientation.vertical,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'With Indents',
          'Separators can have start indent, end indent, or both.',
          [
            _SeparatorExample(
              label: 'No Indent',
              child: Container(
                width: 200,
                height: 40,
                color: context.colors.backgroundSecondary,
                child: const Center(child: WnSeparator()),
              ),
            ),
            _SeparatorExample(
              label: 'Start Indent (16px)',
              child: Container(
                width: 200,
                height: 40,
                color: context.colors.backgroundSecondary,
                child: const Center(child: WnSeparator(indent: 16)),
              ),
            ),
            _SeparatorExample(
              label: 'End Indent (16px)',
              child: Container(
                width: 200,
                height: 40,
                color: context.colors.backgroundSecondary,
                child: const Center(child: WnSeparator(endIndent: 16)),
              ),
            ),
            _SeparatorExample(
              label: 'Both Indents (16px)',
              child: Container(
                width: 200,
                height: 40,
                color: context.colors.backgroundSecondary,
                child: const Center(
                  child: WnSeparator(indent: 16, endIndent: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SeparatorExample extends StatelessWidget {
  const _SeparatorExample({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
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

class _InteractiveSeparator extends StatelessWidget {
  const _InteractiveSeparator({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final orientation = this.context.knobs.object
        .dropdown<WnSeparatorOrientation>(
          label: 'Orientation',
          options: WnSeparatorOrientation.values,
          initialOption: WnSeparatorOrientation.horizontal,
          labelBuilder: (value) => value.name,
        );

    final indent = this.context.knobs.double.slider(
      label: 'Indent',
      initialValue: 0,
      min: 0,
      max: 100,
    );

    final endIndent = this.context.knobs.double.slider(
      label: 'End Indent',
      initialValue: 0,
      min: 0,
      max: 100,
    );

    final isHorizontal = orientation == WnSeparatorOrientation.horizontal;

    return Container(
      width: isHorizontal ? 300 : 100,
      height: isHorizontal ? 60 : 200,
      color: context.colors.backgroundSecondary,
      child: Center(
        child: SizedBox(
          height: isHorizontal ? null : 180,
          child: WnSeparator(
            orientation: orientation,
            indent: indent,
            endIndent: endIndent,
          ),
        ),
      ),
    );
  }
}

class WnOverlayStory extends StatelessWidget {
  const WnOverlayStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Overlay', type: WnOverlayStory)
Widget wnOverlayShowcase(BuildContext context) {
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
          'Use the knobs panel to customize this overlay.',
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
            child: _InteractiveOverlay(context: context),
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Blur Variants',
          'Overlay blur can be adjusted with sigmaX and sigmaY values.',
          [
            _OverlayExample(
              label: 'Light Blur (5, 5)',
              child: _StaticOverlay(sigmaX: 5, sigmaY: 5),
            ),
            _OverlayExample(
              label: 'Medium Blur (25, 25)',
              child: _StaticOverlay(sigmaX: 25, sigmaY: 25),
            ),
            _OverlayExample(
              label: 'Heavy Blur (50, 50)',
              child: _StaticOverlay(sigmaX: 50, sigmaY: 50),
            ),
            _OverlayExample(
              label: 'Directional X (50, 5)',
              child: _StaticOverlay(sigmaX: 50, sigmaY: 5),
            ),
            _OverlayExample(
              label: 'Directional Y (5, 50)',
              child: _StaticOverlay(sigmaX: 5, sigmaY: 50),
            ),
          ],
        ),
      ],
    ),
  );
}

class _OverlayExample extends StatelessWidget {
  const _OverlayExample({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
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

class _StaticOverlay extends StatelessWidget {
  const _StaticOverlay({required this.sigmaX, required this.sigmaY});

  final double sigmaX;
  final double sigmaY;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 120,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          WnOverlay(sigmaX: sigmaX, sigmaY: sigmaY),
        ],
      ),
    );
  }
}

class _InteractiveOverlay extends StatelessWidget {
  const _InteractiveOverlay({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final sigmaX = this.context.knobs.double.slider(
      label: 'Sigma X',
      initialValue: 50,
      min: 0,
      max: 100,
    );

    final sigmaY = this.context.knobs.double.slider(
      label: 'Sigma Y',
      initialValue: 50,
      min: 0,
      max: 100,
    );

    return SizedBox(
      width: 300,
      height: 200,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'Background Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          WnOverlay(sigmaX: sigmaX, sigmaY: sigmaY),
        ],
      ),
    );
  }
}

class WnScrollEdgeEffectStory extends StatelessWidget {
  const WnScrollEdgeEffectStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Scroll Edge Effect', type: WnScrollEdgeEffectStory)
Widget wnScrollEdgeEffectShowcase(BuildContext context) {
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
          'Use the knobs panel to customize this scroll edge effect.',
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
            child: _InteractiveScrollEdgeEffect(context: context),
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Effect Types',
          'Different edge effect types for various UI contexts.',
          [
            _ScrollEdgeExample(
              label: 'Canvas (48px)',
              child: _StaticScrollEdgeEffect(
                type: ScrollEdgeEffectType.canvas,
                position: ScrollEdgePosition.top,
                height: 48,
              ),
            ),
            _ScrollEdgeExample(
              label: 'Slate (80px)',
              child: _StaticScrollEdgeEffect(
                type: ScrollEdgeEffectType.slate,
                position: ScrollEdgePosition.top,
                height: 80,
              ),
            ),
            _ScrollEdgeExample(
              label: 'Dropdown (40px)',
              child: _StaticScrollEdgeEffect(
                type: ScrollEdgeEffectType.dropdown,
                position: ScrollEdgePosition.top,
                height: 40,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Positions',
          'Effects can be positioned at top or bottom of scrollable areas.',
          [
            _ScrollEdgeExample(
              label: 'Canvas Top',
              child: _StaticScrollEdgeEffect(
                type: ScrollEdgeEffectType.canvas,
                position: ScrollEdgePosition.top,
                height: 48,
              ),
            ),
            _ScrollEdgeExample(
              label: 'Canvas Bottom',
              child: _StaticScrollEdgeEffect(
                type: ScrollEdgeEffectType.canvas,
                position: ScrollEdgePosition.bottom,
                height: 48,
              ),
            ),
            _ScrollEdgeExample(
              label: 'Slate Top',
              child: _StaticScrollEdgeEffect(
                type: ScrollEdgeEffectType.slate,
                position: ScrollEdgePosition.top,
                height: 80,
              ),
            ),
            _ScrollEdgeExample(
              label: 'Slate Bottom',
              child: _StaticScrollEdgeEffect(
                type: ScrollEdgeEffectType.slate,
                position: ScrollEdgePosition.bottom,
                height: 80,
              ),
            ),
            _ScrollEdgeExample(
              label: 'Dropdown Top',
              child: _StaticScrollEdgeEffect(
                type: ScrollEdgeEffectType.dropdown,
                position: ScrollEdgePosition.top,
                height: 40,
              ),
            ),
            _ScrollEdgeExample(
              label: 'Dropdown Bottom',
              child: _StaticScrollEdgeEffect(
                type: ScrollEdgeEffectType.dropdown,
                position: ScrollEdgePosition.bottom,
                height: 40,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ScrollEdgeExample extends StatelessWidget {
  const _ScrollEdgeExample({required this.label, required this.child});

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

class _StaticScrollEdgeEffect extends StatelessWidget {
  const _StaticScrollEdgeEffect({
    required this.type,
    required this.position,
    required this.height,
  });

  final ScrollEdgeEffectType type;
  final ScrollEdgePosition position;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.backgroundPrimary;

    final Widget edgeEffect = switch (type) {
      ScrollEdgeEffectType.canvas =>
        position == ScrollEdgePosition.top
            ? WnScrollEdgeEffect.canvasTop(color: color, height: height)
            : WnScrollEdgeEffect.canvasBottom(color: color, height: height),
      ScrollEdgeEffectType.slate =>
        position == ScrollEdgePosition.top
            ? WnScrollEdgeEffect.slateTop(color: color, height: height)
            : WnScrollEdgeEffect.slateBottom(color: color, height: height),
      ScrollEdgeEffectType.dropdown =>
        position == ScrollEdgePosition.top
            ? WnScrollEdgeEffect.dropdownTop(color: color, height: height)
            : WnScrollEdgeEffect.dropdownBottom(color: color, height: height),
    };

    return SizedBox(
      width: 180,
      height: 150,
      child: Stack(
        children: [
          Container(color: context.colors.backgroundSecondary),
          ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => Container(
              height: 30,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Item $index',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.backgroundContentPrimary,
                ),
              ),
            ),
          ),
          edgeEffect,
        ],
      ),
    );
  }
}

class _InteractiveScrollEdgeEffect extends StatelessWidget {
  const _InteractiveScrollEdgeEffect({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final type = this.context.knobs.object.dropdown<ScrollEdgeEffectType>(
      label: 'Type',
      options: ScrollEdgeEffectType.values,
      initialOption: ScrollEdgeEffectType.canvas,
      labelBuilder: (value) => value.name,
    );

    final position = this.context.knobs.object.dropdown<ScrollEdgePosition>(
      label: 'Position',
      options: ScrollEdgePosition.values,
      initialOption: ScrollEdgePosition.top,
      labelBuilder: (value) => value.name,
    );

    final height = this.context.knobs.double.slider(
      label: 'Height',
      initialValue: 48,
      min: 20,
      max: 100,
    );

    final color = context.colors.backgroundPrimary;

    final Widget edgeEffect = switch (type) {
      ScrollEdgeEffectType.canvas =>
        position == ScrollEdgePosition.top
            ? WnScrollEdgeEffect.canvasTop(color: color, height: height)
            : WnScrollEdgeEffect.canvasBottom(color: color, height: height),
      ScrollEdgeEffectType.slate =>
        position == ScrollEdgePosition.top
            ? WnScrollEdgeEffect.slateTop(color: color, height: height)
            : WnScrollEdgeEffect.slateBottom(color: color, height: height),
      ScrollEdgeEffectType.dropdown =>
        position == ScrollEdgePosition.top
            ? WnScrollEdgeEffect.dropdownTop(color: color, height: height)
            : WnScrollEdgeEffect.dropdownBottom(color: color, height: height),
    };

    return SizedBox(
      width: 300,
      height: 250,
      child: Stack(
        children: [
          Container(color: context.colors.backgroundSecondary),
          ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                'Item $index',
                style: TextStyle(
                  color: context.colors.backgroundContentPrimary,
                ),
              ),
            ),
          ),
          edgeEffect,
        ],
      ),
    );
  }
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

extension on WnSeparatorOrientation {
  String get name => toString().split('.').last;
}

extension on ScrollEdgeEffectType {
  String get name => toString().split('.').last;
}

extension on ScrollEdgePosition {
  String get name => toString().split('.').last;
}
