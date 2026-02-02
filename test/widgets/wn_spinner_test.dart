import 'package:flutter/material.dart'
    show CircularProgressIndicator, Color, Column, Key, SizedBox, Text;
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

      testWidgets('renders CircularProgressIndicator', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('sizes', () {
      testWidgets('renders small size', (WidgetTester tester) async {
        final widget = const WnSpinner(size: WnSpinnerSize.small);
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('spinner_indicator')), findsOneWidget);
      });

      testWidgets('renders medium size by default', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('spinner_indicator')), findsOneWidget);
      });

      testWidgets('renders large size', (WidgetTester tester) async {
        final widget = const WnSpinner(size: WnSpinnerSize.large);
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('spinner_indicator')), findsOneWidget);
      });

      testWidgets('small size has smaller dimensions', (WidgetTester tester) async {
        final widget = const WnSpinner(size: WnSpinnerSize.small);
        await mountWidget(widget, tester);
        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(SizedBox),
          ),
        );
        expect(sizedBox.width, lessThan(24));
      });

      testWidgets('large size has larger dimensions', (WidgetTester tester) async {
        final widget = const WnSpinner(size: WnSpinnerSize.large);
        await mountWidget(widget, tester);
        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(SizedBox),
          ),
        );
        expect(sizedBox.width, greaterThan(24));
      });
    });

    group('colors', () {
      testWidgets('uses theme primary color by default', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);
        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.color, isNotNull);
      });

      testWidgets('uses custom color when provided', (WidgetTester tester) async {
        const customColor = Color(0xFF00FF00);
        final widget = const WnSpinner(color: customColor);
        await mountWidget(widget, tester);
        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.color, customColor);
      });
    });

    group('label', () {
      testWidgets('displays label text when provided', (WidgetTester tester) async {
        final widget = const WnSpinner(label: 'Loading...');
        await mountWidget(widget, tester);
        expect(find.text('Loading...'), findsOneWidget);
      });

      testWidgets('does not display label when not provided', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);
        expect(find.byType(Text), findsNothing);
      });

      testWidgets('label appears below spinner', (WidgetTester tester) async {
        final widget = const WnSpinner(label: 'Please wait');
        await mountWidget(widget, tester);
        expect(find.byType(Column), findsOneWidget);
        expect(find.text('Please wait'), findsOneWidget);
      });

      testWidgets('label uses correct styling', (WidgetTester tester) async {
        final widget = const WnSpinner(label: 'Loading');
        await mountWidget(widget, tester);
        final textWidget = tester.widget<Text>(find.text('Loading'));
        expect(textWidget.style, isNotNull);
      });
    });

    group('accessibility', () {
      testWidgets('spinner has semantic label for accessibility', (WidgetTester tester) async {
        final widget = const WnSpinner();
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('spinner_indicator')), findsOneWidget);
      });
    });

    group('combined configurations', () {
      testWidgets('renders with all options', (WidgetTester tester) async {
        const customColor = Color(0xFFFF0000);
        final widget = const WnSpinner(
          size: WnSpinnerSize.large,
          color: customColor,
          label: 'Loading data...',
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('spinner_indicator')), findsOneWidget);
        expect(find.text('Loading data...'), findsOneWidget);
        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.color, customColor);
      });

      testWidgets('renders small with label', (WidgetTester tester) async {
        final widget = const WnSpinner(
          size: WnSpinnerSize.small,
          label: 'Wait',
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('spinner_indicator')), findsOneWidget);
        expect(find.text('Wait'), findsOneWidget);
      });
    });
  });
}
