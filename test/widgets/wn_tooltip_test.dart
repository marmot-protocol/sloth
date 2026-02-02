import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart' show Key, Scaffold, SizedBox, Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_tooltip.dart';
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnTooltip tests', () {
    group('basic functionality', () {
      testWidgets('displays child widget', (WidgetTester tester) async {
        final widget = const WnTooltip(
          message: 'Tooltip message',
          child: Text('Hover me'),
        );
        await mountWidget(widget, tester);
        expect(find.text('Hover me'), findsOneWidget);
      });

      testWidgets('does not show tooltip initially', (WidgetTester tester) async {
        final widget = const WnTooltip(
          message: 'Tooltip message',
          child: Text('Hover me'),
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('tooltip_content')), findsNothing);
      });

      testWidgets('shows tooltip on long press', (WidgetTester tester) async {
        final widget = const WnTooltip(
          message: 'Tooltip message',
          child: Text('Hover me'),
        );
        await mountWidget(widget, tester);
        await tester.longPress(find.text('Hover me'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tooltip_content')), findsOneWidget);
        expect(find.text('Tooltip message'), findsOneWidget);
      });

      testWidgets('shows tooltip on mouse hover', (WidgetTester tester) async {
        final widget = const WnTooltip(
          message: 'Tooltip message',
          waitDuration: Duration(milliseconds: 100),
          child: Text('Hover me'),
        );
        await mountWidget(widget, tester);

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        await gesture.moveTo(tester.getCenter(find.text('Hover me')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump();

        expect(find.byKey(const Key('tooltip_content')), findsOneWidget);
      });

      testWidgets('hides tooltip when tapping outside after hover', (WidgetTester tester) async {
        final widget = const SizedBox(
          width: 300,
          height: 300,
          child: WnTooltip(
            message: 'Tooltip message',
            waitDuration: Duration(milliseconds: 100),
            child: Text('Hover me'),
          ),
        );
        await mountWidget(widget, tester);

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        await gesture.moveTo(tester.getCenter(find.text('Hover me')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump();
        expect(find.byKey(const Key('tooltip_content')), findsOneWidget);

        await tester.tapAt(const Offset(250, 250));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tooltip_content')), findsNothing);
      });
    });

    group('positions', () {
      testWidgets('renders tooltip at top position by default', (WidgetTester tester) async {
        final widget = const WnTooltip(
          message: 'Top tooltip',
          child: Text('Trigger'),
        );
        await mountWidget(widget, tester);
        await tester.longPress(find.text('Trigger'));
        await tester.pumpAndSettle();
        expect(find.text('Top tooltip'), findsOneWidget);
      });

      testWidgets('renders tooltip at bottom position', (WidgetTester tester) async {
        final widget = const WnTooltip(
          message: 'Bottom tooltip',
          position: WnTooltipPosition.bottom,
          child: Text('Trigger'),
        );
        await mountWidget(widget, tester);
        await tester.longPress(find.text('Trigger'));
        await tester.pumpAndSettle();
        expect(find.text('Bottom tooltip'), findsOneWidget);
      });

      testWidgets('renders tooltip at left position', (WidgetTester tester) async {
        final widget = const WnTooltip(
          message: 'Left tooltip',
          position: WnTooltipPosition.left,
          child: Text('Trigger'),
        );
        await mountWidget(widget, tester);
        await tester.longPress(find.text('Trigger'));
        await tester.pumpAndSettle();
        expect(find.text('Left tooltip'), findsOneWidget);
      });

      testWidgets('renders tooltip at right position', (WidgetTester tester) async {
        final widget = const WnTooltip(
          message: 'Right tooltip',
          position: WnTooltipPosition.right,
          child: Text('Trigger'),
        );
        await mountWidget(widget, tester);
        await tester.longPress(find.text('Trigger'));
        await tester.pumpAndSettle();
        expect(find.text('Right tooltip'), findsOneWidget);
      });
    });

    group('arrow', () {
      testWidgets('shows arrow by default', (WidgetTester tester) async {
        final widget = const WnTooltip(
          message: 'With arrow',
          child: Text('Trigger'),
        );
        await mountWidget(widget, tester);
        await tester.longPress(find.text('Trigger'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tooltip_arrow')), findsOneWidget);
      });

      testWidgets('hides arrow when showArrow is false', (WidgetTester tester) async {
        final widget = const WnTooltip(
          message: 'No arrow',
          showArrow: false,
          child: Text('Trigger'),
        );
        await mountWidget(widget, tester);
        await tester.longPress(find.text('Trigger'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tooltip_arrow')), findsNothing);
      });
    });

    group('custom content', () {
      testWidgets('displays message text', (WidgetTester tester) async {
        final widget = const WnTooltip(
          message: 'Custom message',
          child: Text('Trigger'),
        );
        await mountWidget(widget, tester);
        await tester.longPress(find.text('Trigger'));
        await tester.pumpAndSettle();
        expect(find.text('Custom message'), findsOneWidget);
      });

      testWidgets('displays custom content widget', (WidgetTester tester) async {
        final widget = const WnTooltip(
          message: '',
          content: SizedBox(
            key: Key('custom_content_widget'),
            width: 100,
            height: 50,
            child: Text('Custom Widget'),
          ),
          child: Text('Trigger'),
        );
        await mountWidget(widget, tester);
        await tester.longPress(find.text('Trigger'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('custom_content_widget')), findsOneWidget);
        expect(find.text('Custom Widget'), findsOneWidget);
      });

      testWidgets('content widget takes precedence over message', (WidgetTester tester) async {
        final widget = const WnTooltip(
          message: 'Message text',
          content: Text('Content widget', key: Key('content_text')),
          child: Text('Trigger'),
        );
        await mountWidget(widget, tester);
        await tester.longPress(find.text('Trigger'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('content_text')), findsOneWidget);
        expect(find.text('Content widget'), findsOneWidget);
      });
    });

    group('trigger behavior', () {
      testWidgets('tapping outside hides tooltip', (WidgetTester tester) async {
        final widget = const Scaffold(
          body: SizedBox(
            width: 300,
            height: 300,
            child: WnTooltip(
              message: 'Tooltip',
              child: Text('Trigger'),
            ),
          ),
        );
        await mountWidget(widget, tester);
        await tester.longPress(find.text('Trigger'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tooltip_content')), findsOneWidget);

        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tooltip_content')), findsNothing);
      });
    });

    group('wait duration', () {
      testWidgets('respects custom wait duration', (WidgetTester tester) async {
        final widget = const WnTooltip(
          message: 'Delayed tooltip',
          waitDuration: Duration(milliseconds: 200),
          child: Text('Hover me'),
        );
        await mountWidget(widget, tester);

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        await gesture.moveTo(tester.getCenter(find.text('Hover me')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump();
        expect(find.byKey(const Key('tooltip_content')), findsNothing);

        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump();
        expect(find.byKey(const Key('tooltip_content')), findsOneWidget);
      });
    });
  });
}
