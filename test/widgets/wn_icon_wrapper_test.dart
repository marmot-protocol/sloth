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
      const wrapperKey = Key('wrapper_renders_test');
      await mountWidget(
        const WnIconWrapper(
          key: wrapperKey,
          icon: WnIcons.settings,
          accentColor: testAccentColor,
        ),
        tester,
      );

      final wrapperFinder = find.byKey(wrapperKey);
      expect(
        find.descendant(of: wrapperFinder, matching: find.byType(Container)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: wrapperFinder, matching: find.byType(WnIcon)),
        findsOneWidget,
      );
    });

    testWidgets('renders circular container with accent fill color', (tester) async {
      const wrapperKey = Key('wrapper_circular_test');
      await mountWidget(
        const WnIconWrapper(
          key: wrapperKey,
          icon: WnIcons.settings,
          accentColor: testAccentColor,
        ),
        tester,
      );

      final wrapperFinder = find.byKey(wrapperKey);
      final containerFinder = find.descendant(
        of: wrapperFinder,
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, testAccentColor.fill);
    });

    testWidgets('applies contentSecondary color to icon', (tester) async {
      const wrapperKey = Key('wrapper_icon_color_test');
      await mountWidget(
        const WnIconWrapper(
          key: wrapperKey,
          icon: WnIcons.settings,
          accentColor: testAccentColor,
        ),
        tester,
      );

      final wrapperFinder = find.byKey(wrapperKey);
      final svgFinder = find.descendant(
        of: wrapperFinder,
        matching: find.byType(SvgPicture),
      );
      final svgPicture = tester.widget<SvgPicture>(svgFinder);
      expect(
        svgPicture.colorFilter,
        ColorFilter.mode(testAccentColor.contentSecondary, BlendMode.srcIn),
      );
    });

    testWidgets('defaults to size20 and icon is square', (tester) async {
      const wrapperKey = Key('wrapper_default_size_test');
      await mountWidget(
        const WnIconWrapper(
          key: wrapperKey,
          icon: WnIcons.warning,
          accentColor: testAccentColor,
        ),
        tester,
      );

      final wrapperFinder = find.byKey(wrapperKey);
      final svgFinder = find.descendant(
        of: wrapperFinder,
        matching: find.byType(SvgPicture),
      );
      final svgPicture = tester.widget<SvgPicture>(svgFinder);
      expect(svgPicture.width, WnIconWrapperSize.size20.scaled);
      expect(svgPicture.width, svgPicture.height);
    });

    testWidgets('different sizes produce different icon dimensions', (tester) async {
      final iconSizes = <WnIconWrapperSize, double>{};

      for (final size in WnIconWrapperSize.values) {
        final wrapperKey = Key('wrapper_size_${size.name}');
        await mountWidget(
          WnIconWrapper(
            key: wrapperKey,
            icon: WnIcons.warning,
            accentColor: testAccentColor,
            size: size,
          ),
          tester,
        );

        final wrapperFinder = find.byKey(wrapperKey);
        final svgFinder = find.descendant(
          of: wrapperFinder,
          matching: find.byType(SvgPicture),
        );
        final svgPicture = tester.widget<SvgPicture>(svgFinder);
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
      const wrapper14Key = Key('wrapper_scale_14');
      await mountWidget(
        const WnIconWrapper(
          key: wrapper14Key,
          icon: WnIcons.warning,
          accentColor: testAccentColor,
          size: WnIconWrapperSize.size14,
        ),
        tester,
      );
      final svg14Finder = find.descendant(
        of: find.byKey(wrapper14Key),
        matching: find.byType(SvgPicture),
      );
      final size14Width = tester.widget<SvgPicture>(svg14Finder).width!;

      const wrapper32Key = Key('wrapper_scale_32');
      await mountWidget(
        const WnIconWrapper(
          key: wrapper32Key,
          icon: WnIcons.warning,
          accentColor: testAccentColor,
          size: WnIconWrapperSize.size32,
        ),
        tester,
      );
      final svg32Finder = find.descendant(
        of: find.byKey(wrapper32Key),
        matching: find.byType(SvgPicture),
      );
      final size32Width = tester.widget<SvgPicture>(svg32Finder).width!;

      final ratio = size32Width / size14Width;
      expect(ratio, closeTo(32 / 14, 0.01));
    });

    testWidgets('container has consistent size for all icon sizes', (tester) async {
      double? referenceWidth;

      for (final size in WnIconWrapperSize.values) {
        final wrapperKey = Key('wrapper_container_${size.name}');
        await mountWidget(
          WnIconWrapper(
            key: wrapperKey,
            icon: WnIcons.settings,
            accentColor: testAccentColor,
            size: size,
          ),
          tester,
        );

        final containerSize = tester.getSize(find.byKey(wrapperKey));

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
      const wrapperKey = Key('wrapper_correct_icon_test');
      await mountWidget(
        const WnIconWrapper(
          key: wrapperKey,
          icon: WnIcons.heart,
          accentColor: testAccentColor,
        ),
        tester,
      );

      final wrapperFinder = find.byKey(wrapperKey);
      final wnIconFinder = find.descendant(
        of: wrapperFinder,
        matching: find.byType(WnIcon),
      );
      final wnIcon = tester.widget<WnIcon>(wnIconFinder);
      expect(wnIcon.icon, WnIcons.heart);
    });

    testWidgets('centers the icon in container', (tester) async {
      const wrapperKey = Key('wrapper_centers_icon_test');
      await mountWidget(
        const WnIconWrapper(
          key: wrapperKey,
          icon: WnIcons.settings,
          accentColor: testAccentColor,
        ),
        tester,
      );

      final wrapperFinder = find.byKey(wrapperKey);
      expect(
        find.descendant(of: wrapperFinder, matching: find.byType(Center)),
        findsOneWidget,
      );
    });

    testWidgets('can be found by key', (tester) async {
      const wrapperKey = Key('wrapper_find_by_key_test');
      await mountWidget(
        const WnIconWrapper(
          key: wrapperKey,
          icon: WnIcons.settings,
          accentColor: testAccentColor,
        ),
        tester,
      );

      expect(find.byKey(wrapperKey), findsOneWidget);
    });
  });

  group('WnIconWrapper with semantic colors', () {
    testWidgets('works with blue accent from SemanticColors.light', (tester) async {
      const wrapperKey = Key('wrapper_blue_accent_test');
      final blueAccent = SemanticColors.light.accent.blue;
      await mountWidget(
        WnIconWrapper(
          key: wrapperKey,
          icon: WnIcons.information,
          accentColor: blueAccent,
        ),
        tester,
      );

      final wrapperFinder = find.byKey(wrapperKey);
      final containerFinder = find.descendant(
        of: wrapperFinder,
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, blueAccent.fill);

      final svgFinder = find.descendant(
        of: wrapperFinder,
        matching: find.byType(SvgPicture),
      );
      final svgPicture = tester.widget<SvgPicture>(svgFinder);
      expect(
        svgPicture.colorFilter,
        ColorFilter.mode(blueAccent.contentSecondary, BlendMode.srcIn),
      );
    });

    testWidgets('works with emerald accent from SemanticColors.dark', (tester) async {
      const wrapperKey = Key('wrapper_emerald_accent_test');
      final emeraldAccent = SemanticColors.dark.accent.emerald;
      await mountWidget(
        WnIconWrapper(
          key: wrapperKey,
          icon: WnIcons.checkmark,
          accentColor: emeraldAccent,
        ),
        tester,
      );

      final wrapperFinder = find.byKey(wrapperKey);
      final containerFinder = find.descendant(
        of: wrapperFinder,
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, emeraldAccent.fill);

      final svgFinder = find.descendant(
        of: wrapperFinder,
        matching: find.byType(SvgPicture),
      );
      final svgPicture = tester.widget<SvgPicture>(svgFinder);
      expect(
        svgPicture.colorFilter,
        ColorFilter.mode(emeraldAccent.contentSecondary, BlendMode.srcIn),
      );
    });

    testWidgets('works with all accent colors', (tester) async {
      final accentColors = [
        ('blue', SemanticColors.light.accent.blue),
        ('cyan', SemanticColors.light.accent.cyan),
        ('emerald', SemanticColors.light.accent.emerald),
        ('fuchsia', SemanticColors.light.accent.fuchsia),
        ('indigo', SemanticColors.light.accent.indigo),
        ('lime', SemanticColors.light.accent.lime),
        ('orange', SemanticColors.light.accent.orange),
        ('rose', SemanticColors.light.accent.rose),
        ('sky', SemanticColors.light.accent.sky),
        ('teal', SemanticColors.light.accent.teal),
        ('violet', SemanticColors.light.accent.violet),
        ('amber', SemanticColors.light.accent.amber),
      ];

      for (final (name, accent) in accentColors) {
        final wrapperKey = Key('wrapper_accent_$name');
        await mountWidget(
          WnIconWrapper(
            key: wrapperKey,
            icon: WnIcons.placeholder,
            accentColor: accent,
          ),
          tester,
        );

        final wrapperFinder = find.byKey(wrapperKey);
        final containerFinder = find.descendant(
          of: wrapperFinder,
          matching: find.byType(Container),
        );
        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, accent.fill);

        final svgFinder = find.descendant(
          of: wrapperFinder,
          matching: find.byType(SvgPicture),
        );
        final svgPicture = tester.widget<SvgPicture>(svgFinder);
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
      const wrapperKey = Key('wrapper_semantics_test');
      await mountWidget(
        Semantics(
          label: 'Settings icon',
          child: WnIconWrapper(
            key: wrapperKey,
            icon: WnIcons.settings,
            accentColor: testAccentColor,
          ),
        ),
        tester,
      );

      expect(find.bySemanticsLabel('Settings icon'), findsOneWidget);
    });

    testWidgets('can be excluded from semantics', (tester) async {
      const wrapperKey = Key('wrapper_exclude_semantics_test');
      await mountWidget(
        ExcludeSemantics(
          child: Semantics(
            label: 'Hidden icon',
            child: WnIconWrapper(
              key: wrapperKey,
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
