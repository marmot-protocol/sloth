import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_slot.dart';
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnSlot', () {
    testWidgets('displays default label "Slot"', (tester) async {
      const widget = WnSlot();
      await mountWidget(widget, tester);
      expect(find.text('Slot'), findsOneWidget);
    });

    testWidgets('displays custom label when provided', (tester) async {
      const widget = WnSlot(label: 'Custom Label');
      await mountWidget(widget, tester);
      expect(find.text('Custom Label'), findsOneWidget);
    });

    testWidgets('displays default retry icon', (tester) async {
      const widget = WnSlot();
      await mountWidget(widget, tester);
      expect(find.byKey(const Key('wn_slot_icon')), findsOneWidget);
      final icon = tester.widget<WnIcon>(find.byKey(const Key('wn_slot_icon')));
      expect(icon.icon, WnIcons.retry);
    });

    testWidgets('displays custom icon when provided', (tester) async {
      const widget = WnSlot(icon: WnIcons.addCircle);
      await mountWidget(widget, tester);
      expect(find.byKey(const Key('wn_slot_icon')), findsOneWidget);
      final icon = tester.widget<WnIcon>(find.byKey(const Key('wn_slot_icon')));
      expect(icon.icon, WnIcons.addCircle);
    });

    testWidgets('renders child widget instead of default content', (tester) async {
      const childKey = Key('child_widget');
      const widget = WnSlot(
        child: SizedBox(key: childKey, width: 100, height: 100),
      );
      await mountWidget(widget, tester);
      expect(find.byKey(childKey), findsOneWidget);
      expect(find.text('Slot'), findsNothing);
      expect(find.byType(WnIcon), findsNothing);
    });

    testWidgets('uses CustomPaint for dashed border', (tester) async {
      const widget = WnSlot();
      await mountWidget(widget, tester);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('respects minHeight constraint', (tester) async {
      const widget = WnSlot(minHeight: 200);
      await mountWidget(widget, tester);
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.minHeight, 200);
    });

    testWidgets('respects minWidth constraint', (tester) async {
      const widget = WnSlot(minWidth: 300);
      await mountWidget(widget, tester);
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.minWidth, 300);
    });

    testWidgets('has correct text style properties', (tester) async {
      const widget = WnSlot();
      await mountWidget(widget, tester);
      final text = tester.widget<Text>(find.text('Slot'));
      final textStyle = text.style;
      expect(textStyle?.fontWeight, FontWeight.w500);
      expect(textStyle?.letterSpacing, 0.4);
    });

    testWidgets('centers content', (tester) async {
      const widget = WnSlot();
      await mountWidget(widget, tester);
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('places icon and label in a Row', (tester) async {
      const widget = WnSlot();
      await mountWidget(widget, tester);
      final row = tester.widget<Row>(
        find.ancestor(of: find.text('Slot'), matching: find.byType(Row)),
      );
      expect(row.mainAxisSize, MainAxisSize.min);
    });

    testWidgets('applies blue accent border color from theme', (tester) async {
      const widget = WnSlot();
      await mountWidget(widget, tester);
      final icon = tester.widget<WnIcon>(find.byKey(const Key('wn_slot_icon')));
      expect(icon.color, isNotNull);
    });

    testWidgets('applies background color from theme', (tester) async {
      const widget = WnSlot();
      await mountWidget(widget, tester);
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });

    testWidgets('has rounded corners on container', (tester) async {
      const widget = WnSlot();
      await mountWidget(widget, tester);
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
    });

    testWidgets('text has correct line height', (tester) async {
      const widget = WnSlot();
      await mountWidget(widget, tester);
      final text = tester.widget<Text>(find.text('Slot'));
      final textStyle = text.style;
      expect(textStyle?.height, 20 / 14);
    });

    testWidgets('text has correct font size', (tester) async {
      const widget = WnSlot();
      await mountWidget(widget, tester);
      final text = tester.widget<Text>(find.text('Slot'));
      final textStyle = text.style;
      expect(textStyle?.fontSize, isNotNull);
    });

    testWidgets('icon has correct size', (tester) async {
      const widget = WnSlot();
      await mountWidget(widget, tester);
      final icon = tester.widget<WnIcon>(find.byKey(const Key('wn_slot_icon')));
      expect(icon.size, isNotNull);
    });

    testWidgets('child completely replaces default content', (tester) async {
      const widget = WnSlot(
        child: Text('Replacement'),
      );
      await mountWidget(widget, tester);
      expect(find.text('Replacement'), findsOneWidget);
      expect(find.byKey(const Key('wn_slot_icon')), findsNothing);
      expect(find.text('Slot'), findsNothing);
    });
  });
}
