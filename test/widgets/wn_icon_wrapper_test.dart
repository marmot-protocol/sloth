import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_icon_wrapper.dart';

import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnIconWrapperSize enum', () {
    test('has 6 size variants', () {
      expect(WnIconWrapperSize.values.length, 6);
    });

    test('sizes are ordered from smallest to largest', () {
      final pixelValues = WnIconWrapperSize.values.map((s) => s.pixels).toList();
      expect(pixelValues, [14, 16, 18, 20, 24, 32]);
    });

    test('each size has correct pixel value', () {
      expect(WnIconWrapperSize.size14.pixels, 14);
      expect(WnIconWrapperSize.size16.pixels, 16);
      expect(WnIconWrapperSize.size18.pixels, 18);
      expect(WnIconWrapperSize.size20.pixels, 20);
      expect(WnIconWrapperSize.size24.pixels, 24);
      expect(WnIconWrapperSize.size32.pixels, 32);
    });
  });

  group('WnIconWrapper widget', () {
    const testAccentColor = AccentColorSet(
      fill: Color(0xFFEFF6FF),
      contentPrimary: Color(0xFF1E3A8A),
      contentSecondary: Color(0xFF3B82F6),
      border: Color(0xFFBFDBFE),
    );

    testWidgets('renders a Container with WnIcon', (tester) async {
      await mountWidget(
        const WnIconWrapper(
          icon: WnIcons.settings,
          accentColor: testAccentColor,
        ),
        tester,
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(WnIcon), findsOneWidget);
    });

    testWidgets('renders circular container with accent fill color', (tester) async {
      await mountWidget(
        const WnIconWrapper(
          icon: WnIcons.settings,
          accentColor: testAccentColor,
        ),
        tester,
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, testAccentColor.fill);
    });

    testWidgets('applies contentSecondary color to icon', (tester) async {
      await mountWidget(
        const WnIconWrapper(
          icon: WnIcons.settings,
          accentColor: testAccentColor,
        ),
        tester,
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        svgPicture.colorFilter,
        ColorFilter.mode(testAccentColor.contentSecondary, BlendMode.srcIn),
      );
    });

    testWidgets('defaults to size20 and icon is square', (tester) async {
      await mountWidget(
        const WnIconWrapper(
          icon: WnIcons.warning,
          accentColor: testAccentColor,
        ),
        tester,
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, isNotNull);
      expect(svgPicture.width, svgPicture.height);
    });

    testWidgets('different sizes produce different icon dimensions', (tester) async {
      final iconSizes = <WnIconWrapperSize, double>{};

      for (final size in WnIconWrapperSize.values) {
        await mountWidget(
          WnIconWrapper(
            key: Key('wrapper_${size.name}'),
            icon: WnIcons.warning,
            accentColor: testAccentColor,
            size: size,
          ),
          tester,
        );

        final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
        iconSizes[size] = svgPicture.width!;

        expect(
          svgPicture.width,
          svgPicture.height,
          reason: 'Icon should be square for ${size.name}',
        );
      }

      expect(iconSizes[WnIconWrapperSize.size14]!, lessThan(iconSizes[WnIconWrapperSize.size16]!));
      expect(iconSizes[WnIconWrapperSize.size16]!, lessThan(iconSizes[WnIconWrapperSize.size18]!));
      expect(iconSizes[WnIconWrapperSize.size18]!, lessThan(iconSizes[WnIconWrapperSize.size20]!));
      expect(iconSizes[WnIconWrapperSize.size20]!, lessThan(iconSizes[WnIconWrapperSize.size24]!));
      expect(iconSizes[WnIconWrapperSize.size24]!, lessThan(iconSizes[WnIconWrapperSize.size32]!));
    });

    testWidgets('icon sizes scale proportionally', (tester) async {
      await mountWidget(
        const WnIconWrapper(
          key: Key('size14'),
          icon: WnIcons.warning,
          accentColor: testAccentColor,
          size: WnIconWrapperSize.size14,
        ),
        tester,
      );
      final size14Icon = tester.widget<SvgPicture>(find.byType(SvgPicture));
      final size14Width = size14Icon.width!;

      await mountWidget(
        const WnIconWrapper(
          key: Key('size28_approx'),
          icon: WnIcons.warning,
          accentColor: testAccentColor,
          size: WnIconWrapperSize.size32,
        ),
        tester,
      );
      final size32Icon = tester.widget<SvgPicture>(find.byType(SvgPicture));
      final size32Width = size32Icon.width!;

      final ratio = size32Width / size14Width;
      expect(ratio, closeTo(32 / 14, 0.01));
    });

    testWidgets('container has consistent size for all icon sizes', (tester) async {
      double? referenceWidth;

      for (final size in WnIconWrapperSize.values) {
        await mountWidget(
          WnIconWrapper(
            key: Key('wrapper_${size.name}'),
            icon: WnIcons.settings,
            accentColor: testAccentColor,
            size: size,
          ),
          tester,
        );

        final containerSize = tester.getSize(find.byKey(Key('wrapper_${size.name}')));

        expect(containerSize.width, isNotNull);
        expect(containerSize.height, isNotNull);
        expect(
          containerSize.width,
          containerSize.height,
          reason: 'Container should be square for ${size.name}',
        );

        if (referenceWidth == null) {
          referenceWidth = containerSize.width;
        } else {
          expect(
            containerSize.width,
            referenceWidth,
            reason: 'Container width should be consistent across all sizes',
          );
        }
      }
    });

    testWidgets('renders correct icon', (tester) async {
      await mountWidget(
        const WnIconWrapper(
          icon: WnIcons.heart,
          accentColor: testAccentColor,
        ),
        tester,
      );

      final wnIcon = tester.widget<WnIcon>(find.byType(WnIcon));
      expect(wnIcon.icon, WnIcons.heart);
    });

    testWidgets('centers the icon in container', (tester) async {
      await mountWidget(
        const WnIconWrapper(
          icon: WnIcons.settings,
          accentColor: testAccentColor,
        ),
        tester,
      );

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('can be found by key', (tester) async {
      await mountWidget(
        const WnIconWrapper(
          key: Key('test_icon_wrapper'),
          icon: WnIcons.settings,
          accentColor: testAccentColor,
        ),
        tester,
      );

      expect(find.byKey(const Key('test_icon_wrapper')), findsOneWidget);
    });
  });

  group('WnIconWrapper with semantic colors', () {
    testWidgets('works with blue accent from SemanticColors.light', (tester) async {
      final blueAccent = SemanticColors.light.accent.blue;
      await mountWidget(
        WnIconWrapper(
          icon: WnIcons.information,
          accentColor: blueAccent,
        ),
        tester,
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, blueAccent.fill);

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        svgPicture.colorFilter,
        ColorFilter.mode(blueAccent.contentSecondary, BlendMode.srcIn),
      );
    });

    testWidgets('works with emerald accent from SemanticColors.dark', (tester) async {
      final emeraldAccent = SemanticColors.dark.accent.emerald;
      await mountWidget(
        WnIconWrapper(
          icon: WnIcons.checkmark,
          accentColor: emeraldAccent,
        ),
        tester,
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, emeraldAccent.fill);

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        svgPicture.colorFilter,
        ColorFilter.mode(emeraldAccent.contentSecondary, BlendMode.srcIn),
      );
    });

    testWidgets('works with all accent colors', (tester) async {
      final accentColors = [
        SemanticColors.light.accent.blue,
        SemanticColors.light.accent.cyan,
        SemanticColors.light.accent.emerald,
        SemanticColors.light.accent.fuchsia,
        SemanticColors.light.accent.indigo,
        SemanticColors.light.accent.lime,
        SemanticColors.light.accent.orange,
        SemanticColors.light.accent.rose,
        SemanticColors.light.accent.sky,
        SemanticColors.light.accent.teal,
        SemanticColors.light.accent.violet,
        SemanticColors.light.accent.amber,
      ];

      for (final accent in accentColors) {
        await mountWidget(
          WnIconWrapper(
            icon: WnIcons.placeholder,
            accentColor: accent,
          ),
          tester,
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, accent.fill);

        final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
        expect(
          svgPicture.colorFilter,
          ColorFilter.mode(accent.contentSecondary, BlendMode.srcIn),
        );
      }
    });
  });

  group('WnIconWrapper accessibility', () {
    final testAccentColor = SemanticColors.light.accent.blue;

    testWidgets('can be wrapped with Semantics', (tester) async {
      await mountWidget(
        Semantics(
          label: 'Settings icon',
          child: WnIconWrapper(
            icon: WnIcons.settings,
            accentColor: testAccentColor,
          ),
        ),
        tester,
      );

      expect(find.bySemanticsLabel('Settings icon'), findsOneWidget);
    });

    testWidgets('can be excluded from semantics', (tester) async {
      await mountWidget(
        ExcludeSemantics(
          child: Semantics(
            label: 'Hidden icon',
            child: WnIconWrapper(
              icon: WnIcons.settings,
              accentColor: testAccentColor,
            ),
          ),
        ),
        tester,
      );

      expect(find.bySemanticsLabel('Hidden icon'), findsNothing);
    });
  });
}
