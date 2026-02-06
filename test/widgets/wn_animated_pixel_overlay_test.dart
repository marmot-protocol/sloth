import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_animated_pixel_overlay.dart';
import '../test_helpers.dart';

void main() {
  group('WnAnimatedPixelOverlay', () {
    testWidgets('renders WnAnimatedPixelOverlay widget', (tester) async {
      await mountStackedWidget(
        const WnAnimatedPixelOverlay(
          progress: 0.5,
          color: Colors.blue,
          width: 100,
          height: 100,
        ),
        tester,
      );

      expect(find.byType(WnAnimatedPixelOverlay), findsOneWidget);
    });

    testWidgets('renders with zero progress', (tester) async {
      await mountStackedWidget(
        const WnAnimatedPixelOverlay(
          progress: 0.0,
          color: Colors.red,
          width: 50,
          height: 50,
        ),
        tester,
      );

      expect(find.byType(WnAnimatedPixelOverlay), findsOneWidget);
    });

    testWidgets('renders with full progress', (tester) async {
      await mountStackedWidget(
        const WnAnimatedPixelOverlay(
          progress: 1.0,
          color: Colors.green,
          width: 200,
          height: 200,
        ),
        tester,
      );

      expect(find.byType(WnAnimatedPixelOverlay), findsOneWidget);
    });

    testWidgets('renders with custom pixel size', (tester) async {
      await mountStackedWidget(
        const WnAnimatedPixelOverlay(
          progress: 0.5,
          color: Colors.purple,
          width: 100,
          height: 100,
          pixelSize: 16.0,
        ),
        tester,
      );

      final widget = tester.widget<WnAnimatedPixelOverlay>(
        find.byType(WnAnimatedPixelOverlay),
      );
      expect(widget.pixelSize, 16.0);
    });

    testWidgets('renders with custom shouldDrawThreshold', (tester) async {
      await mountStackedWidget(
        const WnAnimatedPixelOverlay(
          progress: 0.5,
          color: Colors.orange,
          width: 100,
          height: 100,
          shouldDrawThreshold: 0.3,
        ),
        tester,
      );

      final widget = tester.widget<WnAnimatedPixelOverlay>(
        find.byType(WnAnimatedPixelOverlay),
      );
      expect(widget.shouldDrawThreshold, 0.3);
    });

    testWidgets('renders with custom seed', (tester) async {
      await mountStackedWidget(
        const WnAnimatedPixelOverlay(
          progress: 0.5,
          color: Colors.cyan,
          width: 100,
          height: 100,
          seed: 123,
        ),
        tester,
      );

      final widget = tester.widget<WnAnimatedPixelOverlay>(
        find.byType(WnAnimatedPixelOverlay),
      );
      expect(widget.seed, 123);
    });

    testWidgets('uses correct dimensions', (tester) async {
      const testWidth = 150.0;
      const testHeight = 75.0;

      await mountStackedWidget(
        const WnAnimatedPixelOverlay(
          progress: 0.5,
          color: Colors.blue,
          width: testWidth,
          height: testHeight,
        ),
        tester,
      );

      final widget = tester.widget<WnAnimatedPixelOverlay>(
        find.byType(WnAnimatedPixelOverlay),
      );
      expect(widget.width, testWidth);
      expect(widget.height, testHeight);
    });

    testWidgets('default values are applied correctly', (tester) async {
      await mountStackedWidget(
        const WnAnimatedPixelOverlay(
          progress: 0.5,
          color: Colors.blue,
          width: 100,
          height: 100,
        ),
        tester,
      );

      final widget = tester.widget<WnAnimatedPixelOverlay>(
        find.byType(WnAnimatedPixelOverlay),
      );

      expect(widget.pixelSize, 8.0);
      expect(widget.shouldDrawThreshold, 0.55);
      expect(widget.seed, 42);
    });

    testWidgets('stores color correctly', (tester) async {
      await mountStackedWidget(
        const WnAnimatedPixelOverlay(
          progress: 0.5,
          color: Colors.amber,
          width: 100,
          height: 100,
        ),
        tester,
      );

      final widget = tester.widget<WnAnimatedPixelOverlay>(
        find.byType(WnAnimatedPixelOverlay),
      );
      expect(widget.color, Colors.amber);
    });

    testWidgets('stores progress correctly', (tester) async {
      await mountStackedWidget(
        const WnAnimatedPixelOverlay(
          progress: 0.75,
          color: Colors.blue,
          width: 100,
          height: 100,
        ),
        tester,
      );

      final widget = tester.widget<WnAnimatedPixelOverlay>(
        find.byType(WnAnimatedPixelOverlay),
      );
      expect(widget.progress, 0.75);
    });
  });
}
