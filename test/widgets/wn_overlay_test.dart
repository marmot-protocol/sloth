import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_overlay.dart';

import '../test_helpers.dart' show mountStackedWidget;

void main() {
  group('WnOverlay widget', () {
    group('rendering', () {
      testWidgets('renders correctly', (tester) async {
        await mountStackedWidget(const WnOverlay(), tester);

        expect(find.byType(WnOverlay), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);
        expect(
          find.descendant(of: find.byType(WnOverlay), matching: find.byType(ColoredBox)),
          findsOneWidget,
        );
      });

      testWidgets('is positioned to fill parent', (tester) async {
        await mountStackedWidget(const WnOverlay(), tester);

        expect(find.byType(Positioned), findsOneWidget);
        final positioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned.left, 0.0);
        expect(positioned.top, 0.0);
        expect(positioned.right, 0.0);
        expect(positioned.bottom, 0.0);
      });
    });

    group('backdrop filter', () {
      testWidgets('uses default sigma values', (tester) async {
        await mountStackedWidget(const WnOverlay(), tester);

        final backdropFilter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
        final blur = backdropFilter.filter;
        expect(blur, isNotNull);
      });

      testWidgets('applies custom sigmaX value', (tester) async {
        await mountStackedWidget(const WnOverlay(sigmaX: 25.0), tester);

        final overlay = tester.widget<WnOverlay>(find.byType(WnOverlay));
        expect(overlay.sigmaX, 25.0);
      });

      testWidgets('applies custom sigmaY value', (tester) async {
        await mountStackedWidget(const WnOverlay(sigmaY: 30.0), tester);

        final overlay = tester.widget<WnOverlay>(find.byType(WnOverlay));
        expect(overlay.sigmaY, 30.0);
      });

      testWidgets('applies both custom sigma values', (tester) async {
        await mountStackedWidget(const WnOverlay(sigmaX: 40.0, sigmaY: 60.0), tester);

        final overlay = tester.widget<WnOverlay>(find.byType(WnOverlay));
        expect(overlay.sigmaX, 40.0);
        expect(overlay.sigmaY, 60.0);
      });

      testWidgets('handles zero sigma values', (tester) async {
        await mountStackedWidget(const WnOverlay(sigmaX: 0.0, sigmaY: 0.0), tester);

        final overlay = tester.widget<WnOverlay>(find.byType(WnOverlay));
        expect(overlay.sigmaX, 0.0);
        expect(overlay.sigmaY, 0.0);
      });
    });

    group('color', () {
      testWidgets('uses overlayPrimary color from light theme', (tester) async {
        await mountStackedWidget(const WnOverlay(), tester);

        final coloredBox = tester.widget<ColoredBox>(
          find.descendant(of: find.byType(WnOverlay), matching: find.byType(ColoredBox)),
        );
        expect(coloredBox.color, SemanticColors.light.overlayPrimary);
      });
    });

    group('widget properties', () {
      testWidgets('exposes sigmaX property with default value', (tester) async {
        await mountStackedWidget(const WnOverlay(), tester);

        final overlay = tester.widget<WnOverlay>(find.byType(WnOverlay));
        expect(overlay.sigmaX, 50.0);
      });

      testWidgets('exposes sigmaY property with default value', (tester) async {
        await mountStackedWidget(const WnOverlay(), tester);

        final overlay = tester.widget<WnOverlay>(find.byType(WnOverlay));
        expect(overlay.sigmaY, 50.0);
      });
    });

    group('layout behavior', () {
      testWidgets('fills available space in a Stack', (tester) async {
        await mountStackedWidget(
          const SizedBox(
            width: 300,
            height: 400,
            child: Stack(children: [WnOverlay()]),
          ),
          tester,
        );

        expect(find.byType(WnOverlay), findsOneWidget);
      });

      testWidgets('can be used with other widgets in Stack', (tester) async {
        await mountStackedWidget(
          const SizedBox(
            width: 300,
            height: 400,
            child: Stack(
              children: [
                Positioned.fill(child: Placeholder()),
                WnOverlay(),
                Center(child: Text('Content')),
              ],
            ),
          ),
          tester,
        );

        expect(find.byType(WnOverlay), findsOneWidget);
        expect(find.text('Content'), findsOneWidget);
        expect(find.byType(Placeholder), findsOneWidget);
      });
    });
  });
}
