import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_icon_wrapper.dart';

import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnIconWrapperSize enum', () {
    test('has correct icon sizes', () {
      expect(WnIconWrapperSize.size14.iconSize, 14);
      expect(WnIconWrapperSize.size16.iconSize, 16);
      expect(WnIconWrapperSize.size18.iconSize, 18);
      expect(WnIconWrapperSize.size20.iconSize, 20);
      expect(WnIconWrapperSize.size24.iconSize, 24);
      expect(WnIconWrapperSize.size32.iconSize, 32);
    });

    test('has 6 size variants', () {
      expect(WnIconWrapperSize.values.length, 6);
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

    testWidgets('defaults to size20', (tester) async {
      await mountWidget(
        const WnIconWrapper(
          icon: WnIcons.warning,
          accentColor: testAccentColor,
        ),
        tester,
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, 20);
      expect(svgPicture.height, 20);
    });

    testWidgets('applies size14 correctly', (tester) async {
      await mountWidget(
        const WnIconWrapper(
          icon: WnIcons.warning,
          accentColor: testAccentColor,
          size: WnIconWrapperSize.size14,
        ),
        tester,
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, 14);
      expect(svgPicture.height, 14);
    });

    testWidgets('applies size16 correctly', (tester) async {
      await mountWidget(
        const WnIconWrapper(
          icon: WnIcons.warning,
          accentColor: testAccentColor,
          size: WnIconWrapperSize.size16,
        ),
        tester,
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, 16);
      expect(svgPicture.height, 16);
    });

    testWidgets('applies size18 correctly', (tester) async {
      await mountWidget(
        const WnIconWrapper(
          icon: WnIcons.warning,
          accentColor: testAccentColor,
          size: WnIconWrapperSize.size18,
        ),
        tester,
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, 18);
      expect(svgPicture.height, 18);
    });

    testWidgets('applies size24 correctly', (tester) async {
      await mountWidget(
        const WnIconWrapper(
          icon: WnIcons.warning,
          accentColor: testAccentColor,
          size: WnIconWrapperSize.size24,
        ),
        tester,
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, 24);
      expect(svgPicture.height, 24);
    });

    testWidgets('applies size32 correctly', (tester) async {
      await mountWidget(
        const WnIconWrapper(
          icon: WnIcons.warning,
          accentColor: testAccentColor,
          size: WnIconWrapperSize.size32,
        ),
        tester,
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, 32);
      expect(svgPicture.height, 32);
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

        final container = tester.widget<Container>(find.byType(Container));
        final width = container.constraints?.maxWidth;
        final height = container.constraints?.maxHeight;

        expect(width, isNotNull);
        expect(height, isNotNull);
        expect(width, height, reason: 'Container should be square for ${size.name}');

        if (referenceWidth == null) {
          referenceWidth = width;
        } else {
          expect(
            width,
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
