import 'package:flutter/material.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_carousel_indicator.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class WnCarouselIndicatorStory extends StatelessWidget {
  const WnCarouselIndicatorStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Carousel Indicator', type: WnCarouselIndicatorStory)
Widget wnCarouselIndicatorShowcase(BuildContext context) {
  return Scaffold(
    backgroundColor: context.colors.backgroundPrimary,
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Animation Demo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: context.colors.backgroundContentPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Use the arrow buttons to navigate and see the animation in action.',
          style: TextStyle(
            fontSize: 14,
            color: context.colors.backgroundContentSecondary,
          ),
        ),
        const SizedBox(height: 16),
        const _AnimatedCarouselDemo(),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
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
          'Use the knobs panel to customize this carousel indicator.',
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
            child: const _InteractiveCarouselIndicator(),
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Item Count Variants',
          'WnCarouselIndicator can display any number of items. The active item is displayed wider than inactive items.',
          [
            _CarouselIndicatorExample(
              label: '3 Items',
              description: 'Typical usage',
              child: const WnCarouselIndicator(itemCount: 3, activeIndex: 1),
            ),
            _CarouselIndicatorExample(
              label: '5 Items',
              description: 'Medium carousel',
              child: const WnCarouselIndicator(itemCount: 5, activeIndex: 2),
            ),
            _CarouselIndicatorExample(
              label: '7 Items',
              description: 'Larger carousel',
              child: const WnCarouselIndicator(itemCount: 7, activeIndex: 3),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Active Index Variants',
          'The active index indicates the current position in the carousel.',
          [
            _CarouselIndicatorExample(
              label: 'First Active',
              description: 'activeIndex: 0',
              child: const WnCarouselIndicator(itemCount: 5, activeIndex: 0),
            ),
            _CarouselIndicatorExample(
              label: 'Middle Active',
              description: 'activeIndex: 2',
              child: const WnCarouselIndicator(itemCount: 5, activeIndex: 2),
            ),
            _CarouselIndicatorExample(
              label: 'Last Active',
              description: 'activeIndex: 4',
              child: const WnCarouselIndicator(itemCount: 5, activeIndex: 4),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Usage Context',
          'Carousel indicators are typically placed below carousel content to show the current slide position.',
          [
            _CarouselContextExample(
              label: 'Below Content',
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 120,
                    decoration: BoxDecoration(
                      color: context.colors.fillSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Slide Content',
                      style: TextStyle(
                        color: context.colors.backgroundContentSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const WnCarouselIndicator(itemCount: 5, activeIndex: 2),
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

class _AnimatedCarouselDemo extends StatefulWidget {
  const _AnimatedCarouselDemo();

  @override
  State<_AnimatedCarouselDemo> createState() => _AnimatedCarouselDemoState();
}

class _AnimatedCarouselDemoState extends State<_AnimatedCarouselDemo> {
  static const int _itemCount = 5;
  int _activeIndex = 0;

  void _goToPrevious() {
    setState(() {
      _activeIndex = (_activeIndex - 1).clamp(0, _itemCount - 1);
    });
  }

  void _goToNext() {
    setState(() {
      _activeIndex = (_activeIndex + 1).clamp(0, _itemCount - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canGoPrevious = _activeIndex > 0;
    final canGoNext = _activeIndex < _itemCount - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.backgroundPrimary,
        border: Border.all(color: colors.borderTertiary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: colors.backgroundPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              'Slide ${_activeIndex + 1} of $_itemCount',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: colors.backgroundContentPrimary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavigationButton(
                icon: Icons.chevron_left,
                onPressed: canGoPrevious ? _goToPrevious : null,
              ),
              const SizedBox(width: 16),
              WnCarouselIndicator(
                itemCount: _itemCount,
                activeIndex: _activeIndex,
              ),
              const SizedBox(width: 16),
              _NavigationButton(
                icon: Icons.chevron_right,
                onPressed: canGoNext ? _goToNext : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Animation: 600ms with elasticOut curve',
            style: TextStyle(
              fontSize: 12,
              color: colors.backgroundContentSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = onPressed != null;

    return Material(
      color: isEnabled ? colors.fillPrimary : colors.fillSecondary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: isEnabled
                ? colors.fillContentPrimary
                : colors.backgroundContentTertiary,
          ),
        ),
      ),
    );
  }
}

class _CarouselIndicatorExample extends StatelessWidget {
  const _CarouselIndicatorExample({
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
      width: 180,
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
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _CarouselContextExample extends StatelessWidget {
  const _CarouselContextExample({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
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

class _InteractiveCarouselIndicator extends StatelessWidget {
  const _InteractiveCarouselIndicator();

  @override
  Widget build(BuildContext context) {
    final itemCount = context.knobs.int.slider(
      label: 'Item Count',
      min: 1,
      max: 10,
      initialValue: 5,
    );
    final activeIndex = context.knobs.int.slider(
      label: 'Active Index',
      min: 0,
      max: itemCount - 1,
      initialValue: 0,
    );

    return WnCarouselIndicator(itemCount: itemCount, activeIndex: activeIndex);
  }
}
