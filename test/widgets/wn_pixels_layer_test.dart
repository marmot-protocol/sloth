import 'package:flutter_svg/flutter_svg.dart' show SvgAssetLoader, SvgPicture;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_pixels_layer.dart' show WnPixelsLayer;
import '../test_helpers.dart' show mountStackedWidget;

void main() {
  group('WnPixelsLayer tests', () {
    testWidgets('renders svg', (WidgetTester tester) async {
      final widget = const WnPixelsLayer();
      await mountStackedWidget(widget, tester);

      expect(find.byType(SvgPicture), findsOneWidget);

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      final SvgAssetLoader loader = svgPicture.bytesLoader as SvgAssetLoader;
      expect(loader.assetName, 'assets/svgs/pixels.svg');
    });

    testWidgets('renders expected asset', (WidgetTester tester) async {
      final widget = const WnPixelsLayer();
      await mountStackedWidget(widget, tester);
      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      final SvgAssetLoader loader = svgPicture.bytesLoader as SvgAssetLoader;
      expect(loader.assetName, 'assets/svgs/pixels.svg');
    });
  });
}
