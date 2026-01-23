import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_icon.dart';
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnIcons enum', () {
    test('generates correct asset path', () {
      expect(WnIcons.closeLarge.path, 'assets/svgs/close_large.svg');
      expect(WnIcons.warning.path, 'assets/svgs/warning.svg');
      expect(WnIcons.qrCode.path, 'assets/svgs/qr_code.svg');
    });

    test('all icons have unique filenames', () {
      final filenames = WnIcons.values.map((e) => e.filename).toList();
      final uniqueFilenames = filenames.toSet();
      expect(filenames.length, uniqueFilenames.length);
    });
  });

  group('WnIcon widget', () {
    testWidgets('renders SvgPicture', (tester) async {
      await mountWidget(
        const WnIcon(WnIcons.warning),
        tester,
      );
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('uses correct asset path', (tester) async {
      await mountWidget(
        const WnIcon(WnIcons.closeLarge),
        tester,
      );
      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      final bytesLoader = svgPicture.bytesLoader as SvgAssetLoader;
      expect(bytesLoader.assetName, 'assets/svgs/close_large.svg');
    });

    testWidgets('applies custom size', (tester) async {
      await mountWidget(
        const WnIcon(WnIcons.warning, size: 32),
        tester,
      );
      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, 32);
      expect(svgPicture.height, 32);
    });

    testWidgets('applies color filter when color is provided', (tester) async {
      const testColor = Color(0xFFFF0000);
      await mountWidget(
        const WnIcon(WnIcons.warning, color: testColor),
        tester,
      );
      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.colorFilter, isNotNull);
      expect(
        svgPicture.colorFilter,
        const ColorFilter.mode(testColor, BlendMode.srcIn),
      );
    });

    testWidgets('falls back to IconTheme color when color is null', (tester) async {
      const themeColor = Color(0xFF00FF00);
      await mountWidget(
        const IconTheme(
          data: IconThemeData(color: themeColor),
          child: WnIcon(WnIcons.warning),
        ),
        tester,
      );
      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.colorFilter, isNotNull);
      expect(
        svgPicture.colorFilter,
        const ColorFilter.mode(themeColor, BlendMode.srcIn),
      );
    });

    testWidgets('explicit color overrides IconTheme color', (tester) async {
      const themeColor = Color(0xFF00FF00);
      const explicitColor = Color(0xFFFF0000);
      await mountWidget(
        const IconTheme(
          data: IconThemeData(color: themeColor),
          child: WnIcon(WnIcons.warning, color: explicitColor),
        ),
        tester,
      );
      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        svgPicture.colorFilter,
        const ColorFilter.mode(explicitColor, BlendMode.srcIn),
      );
    });

    testWidgets('renders when neither color nor IconTheme is set', (tester) async {
      await mountWidget(
        const WnIcon(WnIcons.warning),
        tester,
      );
      // IconTheme.of(context).color may return a default, so just verify widget renders
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('can be found by type', (tester) async {
      await mountWidget(
        const WnIcon(WnIcons.search),
        tester,
      );
      expect(find.byType(WnIcon), findsOneWidget);
    });

    testWidgets('exposes icon property for testing', (tester) async {
      await mountWidget(
        const WnIcon(WnIcons.heart),
        tester,
      );
      final wnIcon = tester.widget<WnIcon>(find.byType(WnIcon));
      expect(wnIcon.icon, WnIcons.heart);
    });

    testWidgets('handles very small size', (tester) async {
      await mountWidget(
        const WnIcon(WnIcons.warning, size: 1),
        tester,
      );
      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, 1);
      expect(svgPicture.height, 1);
    });

    testWidgets('handles large size', (tester) async {
      await mountWidget(
        const WnIcon(WnIcons.warning, size: 256),
        tester,
      );
      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, 256);
      expect(svgPicture.height, 256);
    });

    testWidgets('handles fractional size', (tester) async {
      await mountWidget(
        const WnIcon(WnIcons.warning, size: 12.5),
        tester,
      );
      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, 12.5);
      expect(svgPicture.height, 12.5);
    });

    testWidgets('handles transparent color', (tester) async {
      const transparentColor = Color(0x00FFFFFF);
      await mountWidget(
        const WnIcon(WnIcons.warning, color: transparentColor),
        tester,
      );
      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        svgPicture.colorFilter,
        const ColorFilter.mode(transparentColor, BlendMode.srcIn),
      );
    });

    testWidgets('handles semi-transparent color', (tester) async {
      const semiTransparentColor = Color(0x80FF0000);
      await mountWidget(
        const WnIcon(WnIcons.warning, color: semiTransparentColor),
        tester,
      );
      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        svgPicture.colorFilter,
        const ColorFilter.mode(semiTransparentColor, BlendMode.srcIn),
      );
    });

    testWidgets('nested IconTheme overrides parent', (tester) async {
      const parentColor = Color(0xFF0000FF);
      const childColor = Color(0xFFFF0000);

      await mountWidget(
        const IconTheme(
          data: IconThemeData(color: parentColor),
          child: Column(
            children: [
              WnIcon(WnIcons.warning, key: Key('parent_icon')),
              IconTheme(
                data: IconThemeData(color: childColor),
                child: WnIcon(WnIcons.search, key: Key('child_icon')),
              ),
            ],
          ),
        ),
        tester,
      );

      final parentIcon = tester.widget<WnIcon>(find.byKey(const Key('parent_icon')));
      final childIcon = tester.widget<WnIcon>(find.byKey(const Key('child_icon')));

      // Find SVG pictures by their parent WnIcon keys
      final parentSvg = tester.widget<SvgPicture>(
        find.descendant(
          of: find.byKey(const Key('parent_icon')),
          matching: find.byType(SvgPicture),
        ),
      );
      final childSvg = tester.widget<SvgPicture>(
        find.descendant(
          of: find.byKey(const Key('child_icon')),
          matching: find.byType(SvgPicture),
        ),
      );

      expect(parentIcon.icon, WnIcons.warning);
      expect(childIcon.icon, WnIcons.search);
      expect(
        parentSvg.colorFilter,
        const ColorFilter.mode(parentColor, BlendMode.srcIn),
      );
      expect(
        childSvg.colorFilter,
        const ColorFilter.mode(childColor, BlendMode.srcIn),
      );
    });
  });

  group('WnIcons validation', () {
    test('all icons have non-empty filenames', () {
      for (final icon in WnIcons.values) {
        expect(icon.filename, isNotEmpty, reason: 'Icon ${icon.name} has empty filename');
      }
    });

    test('all icon paths start with assets/svgs/', () {
      for (final icon in WnIcons.values) {
        expect(icon.path, startsWith('assets/svgs/'));
      }
    });

    test('all icon paths end with .svg', () {
      for (final icon in WnIcons.values) {
        expect(icon.path, endsWith('.svg'));
      }
    });
  });
}
