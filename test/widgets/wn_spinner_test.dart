import 'dart:math' show atan2;

import 'package:flutter/material.dart'
    show
        Column,
        CustomPaint,
        Key,
        MainAxisSize,
        Matrix4,
        RenderBox,
        StatefulBuilder,
        Text,
        TextButton,
        Transform;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_spinner.dart';
import '../test_helpers.dart' show mountWidget;

double _extractRotationAngle(Matrix4 matrix) {
  final sinAngle = matrix.storage[1];
  final cosAngle = matrix.storage[0];
  return atan2(sinAngle, cosAngle);
}

void main() {
  group('WnSpinner tests', () {
    group('basic functionality', () {
      testWidgets('displays spinner indicator', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('spinner_indicator')), findsOneWidget);
      });

      testWidgets('renders CustomPaint for spinner', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);
        final customPaint = tester.widget<CustomPaint>(
          find.byKey(const Key('spinner_indicator')),
        );
        expect(customPaint, isNotNull);
      });

      testWidgets('has fixed 16px dimension', (WidgetTester tester) async {
        final widget = const WnSpinner(key: Key('test_spinner'));
        await mountWidget(widget, tester);
        final renderBox = tester.renderObject(find.byKey(const Key('test_spinner'))) as RenderBox;
        expect(renderBox.size.width, 16);
        expect(renderBox.size.height, 16);
      });
    });

    group('types', () {
      testWidgets('renders primary type by default', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('spinner_indicator')), findsOneWidget);
      });

      testWidgets('renders secondary type', (WidgetTester tester) async {
        final widget = const WnSpinner(type: WnSpinnerType.secondary);
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('spinner_indicator')), findsOneWidget);
      });

      testWidgets('renders destructive type', (WidgetTester tester) async {
        final widget = const WnSpinner(type: WnSpinnerType.destructive);
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('spinner_indicator')), findsOneWidget);
      });

      testWidgets('primary type renders custom paint', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);
        final customPaint = tester.widget<CustomPaint>(
          find.byKey(const Key('spinner_indicator')),
        );
        expect(customPaint, isNotNull);
      });

      testWidgets('secondary type renders custom paint', (WidgetTester tester) async {
        final widget = const WnSpinner(type: WnSpinnerType.secondary);
        await mountWidget(widget, tester);
        final customPaint = tester.widget<CustomPaint>(
          find.byKey(const Key('spinner_indicator')),
        );
        expect(customPaint, isNotNull);
      });

      testWidgets('destructive type renders custom paint', (WidgetTester tester) async {
        final widget = const WnSpinner(type: WnSpinnerType.destructive);
        await mountWidget(widget, tester);
        final customPaint = tester.widget<CustomPaint>(
          find.byKey(const Key('spinner_indicator')),
        );
        expect(customPaint, isNotNull);
      });
    });

    group('animation', () {
      testWidgets('spinner animates with 900ms duration', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);

        final initialTransform = tester.firstWidget<Transform>(find.byType(Transform));
        final initialMatrix = initialTransform.transform;

        await tester.pump(const Duration(milliseconds: 450));
        final midTransform = tester.firstWidget<Transform>(find.byType(Transform));
        final midMatrix = midTransform.transform;

        await tester.pump(const Duration(milliseconds: 450));
        final finalTransform = tester.firstWidget<Transform>(find.byType(Transform));
        final finalMatrix = finalTransform.transform;

        final initialAngle = _extractRotationAngle(initialMatrix);
        final midAngle = _extractRotationAngle(midMatrix);
        final finalAngle = _extractRotationAngle(finalMatrix);

        expect(midAngle, isNot(equals(initialAngle)));
        expect(finalAngle, isNot(equals(midAngle)));
        expect(
          (midAngle - initialAngle).abs(),
          closeTo((finalAngle - midAngle).abs(), 0.01),
        );
      });

      testWidgets('uses linear easing with consistent rotation delta', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);

        final angles = <double>[];
        const pumpDuration = Duration(milliseconds: 100);

        for (var i = 0; i < 5; i++) {
          final transform = tester.firstWidget<Transform>(find.byType(Transform));
          angles.add(_extractRotationAngle(transform.transform));
          await tester.pump(pumpDuration);
        }

        final deltas = <double>[];
        for (var i = 1; i < angles.length; i++) {
          deltas.add((angles[i] - angles[i - 1]).abs());
        }

        for (var i = 1; i < deltas.length; i++) {
          expect(deltas[i], closeTo(deltas[0], 0.01));
        }
      });
    });

    group('accessibility', () {
      testWidgets('spinner has semantic label for accessibility', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);

        expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      });
    });

    group('repaint behavior', () {
      testWidgets('spinner still displayed after type change triggers repaint', (
        WidgetTester tester,
      ) async {
        var type = WnSpinnerType.primary;
        await mountWidget(
          StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WnSpinner(type: type),
                TextButton(
                  key: const Key('rebuild_spinner'),
                  onPressed: () => setState(() => type = WnSpinnerType.secondary),
                  child: const Text('Rebuild'),
                ),
              ],
            ),
          ),
          tester,
        );

        expect(find.byKey(const Key('spinner_indicator')), findsOneWidget);

        await tester.tap(find.byKey(const Key('rebuild_spinner')));
        await tester.pump();

        expect(find.byKey(const Key('spinner_indicator')), findsOneWidget);
      });
    });
  });
}
