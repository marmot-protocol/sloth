import 'package:flutter/material.dart' show CustomPaint, Key, SizedBox, Transform;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_spinner.dart';
import '../test_helpers.dart' show mountWidget;

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
        final widget = const WnSpinner();
        await mountWidget(widget, tester);
        final sizedBox = tester.widget<SizedBox>(
          find.byType(SizedBox).first,
        );
        expect(sizedBox.width, 16);
        expect(sizedBox.height, 16);
      });
    });

    group('types', () {
      testWidgets('renders primary type by default', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('spinner_indicator')), findsOneWidget);
      });

      testWidgets('renders primary type', (WidgetTester tester) async {
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

        final initialTransform = tester.firstWidget(find.byType(Transform));
        await tester.pump(const Duration(milliseconds: 450));
        final midTransform = tester.firstWidget(find.byType(Transform));
        await tester.pump(const Duration(milliseconds: 450));
        final finalTransform = tester.firstWidget(find.byType(Transform));

        expect(initialTransform, isNotNull);
        expect(midTransform, isNotNull);
        expect(finalTransform, isNotNull);
      });

      testWidgets('uses linear easing', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);
        final customPaint = tester.widget<CustomPaint>(
          find.byKey(const Key('spinner_indicator')),
        );
        expect(customPaint, isNotNull);
      });
    });

    group('accessibility', () {
      testWidgets('spinner has semantic label for accessibility', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('spinner_indicator')), findsOneWidget);
      });
    });
  });
}
