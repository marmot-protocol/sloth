import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart'
    show AnimatedContainer, BoxDecoration, Key, MainAxisSize, Row;
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_filter_chip.dart';
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnFilterChip tests', () {
    group('basic functionality', () {
      testWidgets('displays label text', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'All',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);
        expect(find.text('All'), findsOneWidget);
      });

      testWidgets('calls onSelected with true when tapped while unselected', (
        WidgetTester tester,
      ) async {
        bool? selectedValue;
        final widget = WnFilterChip(
          label: 'Filter',
          selected: false,
          onSelected: (value) => selectedValue = value,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnFilterChip));
        expect(selectedValue, isTrue);
      });

      testWidgets('calls onSelected with false when tapped while selected', (
        WidgetTester tester,
      ) async {
        bool? selectedValue;
        final widget = WnFilterChip(
          label: 'Filter',
          selected: true,
          onSelected: (value) => selectedValue = value,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnFilterChip));
        expect(selectedValue, isFalse);
      });
    });

    group('variants', () {
      testWidgets('renders standard variant by default', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Standard',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);
        expect(find.text('Standard'), findsOneWidget);
      });

      testWidgets('renders elevated variant', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Elevated',
          selected: false,
          onSelected: (_) {},
          variant: WnFilterChipVariant.elevated,
        );
        await mountWidget(widget, tester);
        expect(find.text('Elevated'), findsOneWidget);
      });

      testWidgets('elevated variant has shadow when unselected', (WidgetTester tester) async {
        final widget = WnFilterChip(
          key: const Key('chip'),
          label: 'Elevated',
          selected: false,
          onSelected: (_) {},
          variant: WnFilterChipVariant.elevated,
        );
        await mountWidget(widget, tester);

        final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
        final decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.length, 2);
      });

      testWidgets('elevated variant has shadow when selected', (WidgetTester tester) async {
        final widget = WnFilterChip(
          key: const Key('chip'),
          label: 'Elevated',
          selected: true,
          onSelected: (_) {},
          variant: WnFilterChipVariant.elevated,
        );
        await mountWidget(widget, tester);

        final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
        final decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.length, 2);
      });

      testWidgets('standard variant has no shadow', (WidgetTester tester) async {
        final widget = WnFilterChip(
          key: const Key('chip'),
          label: 'Standard',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);

        final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
        final decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNull);
      });
    });

    group('selected state', () {
      testWidgets('renders correctly when selected', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Selected',
          selected: true,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);
        expect(find.text('Selected'), findsOneWidget);
      });

      testWidgets('renders correctly when unselected', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Unselected',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);
        expect(find.text('Unselected'), findsOneWidget);
      });
    });

    group('hover state', () {
      testWidgets('responds to hover enter', (WidgetTester tester) async {
        final widget = WnFilterChip(
          key: const Key('chip'),
          label: 'Hoverable',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        await gesture.moveTo(tester.getCenter(find.byType(WnFilterChip)));
        await tester.pump();

        expect(find.text('Hoverable'), findsOneWidget);
      });

      testWidgets('responds to hover exit', (WidgetTester tester) async {
        final widget = WnFilterChip(
          key: const Key('chip'),
          label: 'Hoverable',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: const Offset(-100, -100));
        addTearDown(gesture.removePointer);

        await gesture.moveTo(tester.getCenter(find.byType(WnFilterChip)));
        await tester.pump();

        await gesture.moveTo(const Offset(-100, -100));
        await tester.pump();

        expect(find.text('Hoverable'), findsOneWidget);
      });
    });

    group('combined states', () {
      testWidgets('standard variant selected', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Test',
          selected: true,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);

        final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
        final decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNull);
      });

      testWidgets('elevated variant selected', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Test',
          selected: true,
          onSelected: (_) {},
          variant: WnFilterChipVariant.elevated,
        );
        await mountWidget(widget, tester);

        final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
        final decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNotNull);
      });

      testWidgets('standard variant hovered', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Test',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        await gesture.moveTo(tester.getCenter(find.byType(WnFilterChip)));
        await tester.pump();

        final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
        final decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNull);
      });

      testWidgets('elevated variant hovered', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Test',
          selected: false,
          onSelected: (_) {},
          variant: WnFilterChipVariant.elevated,
        );
        await mountWidget(widget, tester);

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        await gesture.moveTo(tester.getCenter(find.byType(WnFilterChip)));
        await tester.pump();

        final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
        final decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNotNull);
      });
    });

    group('different labels', () {
      testWidgets('renders All label', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'All',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);
        expect(find.text('All'), findsOneWidget);
      });

      testWidgets('renders Unread label', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Unread',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);
        expect(find.text('Unread'), findsOneWidget);
      });

      testWidgets('renders Archived label', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Archived',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);
        expect(find.text('Archived'), findsOneWidget);
      });

      testWidgets('renders Favorites label', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Favorites',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);
        expect(find.text('Favorites'), findsOneWidget);
      });

      testWidgets('renders long label', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Very Long Filter Name',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);
        expect(find.text('Very Long Filter Name'), findsOneWidget);
      });
    });

    group('multiple chips interaction', () {
      testWidgets('can render multiple chips', (WidgetTester tester) async {
        final widget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WnFilterChip(label: 'All', selected: true, onSelected: (_) {}),
            WnFilterChip(label: 'Unread', selected: false, onSelected: (_) {}),
            WnFilterChip(label: 'Archived', selected: false, onSelected: (_) {}),
          ],
        );
        await mountWidget(widget, tester);
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Unread'), findsOneWidget);
        expect(find.text('Archived'), findsOneWidget);
      });

      testWidgets('tapping one chip does not affect others', (WidgetTester tester) async {
        bool allSelected = true;
        bool unreadSelected = false;

        final widget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WnFilterChip(
              key: const Key('all_chip'),
              label: 'All',
              selected: allSelected,
              onSelected: (value) => allSelected = value,
            ),
            WnFilterChip(
              key: const Key('unread_chip'),
              label: 'Unread',
              selected: unreadSelected,
              onSelected: (value) => unreadSelected = value,
            ),
          ],
        );
        await mountWidget(widget, tester);

        await tester.tap(find.byKey(const Key('unread_chip')));
        expect(unreadSelected, isTrue);
        expect(allSelected, isTrue);
      });
    });

    group('animation', () {
      testWidgets('uses AnimatedContainer for smooth transitions', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Test',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);

        final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
        expect(animatedContainer.duration, const Duration(milliseconds: 150));
      });
    });

    group('decoration', () {
      testWidgets('has rounded border radius', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Test',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);

        final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
        final decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.borderRadius, isNotNull);
      });

      testWidgets('has border', (WidgetTester tester) async {
        final widget = WnFilterChip(
          label: 'Test',
          selected: false,
          onSelected: (_) {},
        );
        await mountWidget(widget, tester);

        final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
        final decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.border, isNotNull);
      });
    });
  });
}
