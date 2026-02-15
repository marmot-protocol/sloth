import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/theme/semantic_colors.dart';
import 'package:whitenoise/widgets/wn_reaction.dart';
import '../test_helpers.dart';

Color _pillColor(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(of: find.byType(WnReaction), matching: find.byType(Container)),
  );
  return (container.decoration! as BoxDecoration).color!;
}

void main() {
  group('WnReaction', () {
    testWidgets('renders emoji', (tester) async {
      await mountWidget(const WnReaction(emoji: '👍'), tester);

      expect(find.text('👍'), findsOneWidget);
    });

    testWidgets('does not show count when count is null', (tester) async {
      await mountWidget(const WnReaction(emoji: '👍'), tester);

      expect(find.text('👍'), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('does not show count when count is 1', (tester) async {
      await mountWidget(const WnReaction(emoji: '👍', count: 1), tester);

      expect(find.text('👍'), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('shows count when count is greater than 1', (tester) async {
      await mountWidget(const WnReaction(emoji: '👍', count: 5), tester);

      expect(find.text('👍'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows double digit count', (tester) async {
      await mountWidget(const WnReaction(emoji: '👍', count: 42), tester);

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('shows 99+ for counts over 99', (tester) async {
      await mountWidget(const WnReaction(emoji: '👍', count: 150), tester);

      expect(find.text('99+'), findsOneWidget);
      expect(find.text('150'), findsNothing);
    });

    testWidgets('shows 99+ for count of exactly 100', (tester) async {
      await mountWidget(const WnReaction(emoji: '👍', count: 100), tester);

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('shows 99 for count of exactly 99', (tester) async {
      await mountWidget(const WnReaction(emoji: '👍', count: 99), tester);

      expect(find.text('99'), findsOneWidget);
    });

    group('interaction', () {
      testWidgets('calls onTap when tapped', (tester) async {
        var tapped = false;
        await mountWidget(WnReaction(emoji: '👍', onTap: () => tapped = true), tester);

        await tester.tap(find.text('👍'));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('does not crash when onTap is null and tapped', (tester) async {
        await mountWidget(const WnReaction(emoji: '👍'), tester);

        await tester.tap(find.text('👍'));
        await tester.pump();

        expect(find.text('👍'), findsOneWidget);
      });
    });

    group('fill colors', () {
      final incoming = SemanticColors.light.reaction.incoming;
      final outgoing = SemanticColors.light.reaction.outgoing;

      testWidgets('incoming default', (tester) async {
        await mountWidget(const WnReaction(emoji: '👍'), tester);
        expect(_pillColor(tester), incoming.fill);
      });

      testWidgets('outgoing default', (tester) async {
        await mountWidget(
          const WnReaction(emoji: '👍', type: WnReactionType.outgoing),
          tester,
        );
        expect(_pillColor(tester), outgoing.fill);
      });

      testWidgets('incoming selected', (tester) async {
        await mountWidget(const WnReaction(emoji: '👍', isSelected: true), tester);
        expect(_pillColor(tester), incoming.fillSelected);
      });

      testWidgets('outgoing selected', (tester) async {
        await mountWidget(
          const WnReaction(emoji: '👍', type: WnReactionType.outgoing, isSelected: true),
          tester,
        );
        expect(_pillColor(tester), outgoing.fillSelected);
      });

      testWidgets('incoming hover', (tester) async {
        await mountWidget(const WnReaction(emoji: '👍'), tester);

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        await gesture.moveTo(tester.getCenter(find.byType(WnReaction)));
        await tester.pump();

        expect(_pillColor(tester), incoming.fillHover);
      });

      testWidgets('outgoing hover', (tester) async {
        await mountWidget(
          const WnReaction(emoji: '👍', type: WnReactionType.outgoing),
          tester,
        );

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        await gesture.moveTo(tester.getCenter(find.byType(WnReaction)));
        await tester.pump();

        expect(_pillColor(tester), outgoing.fillHover);
      });

      testWidgets('hover takes priority over selected', (tester) async {
        await mountWidget(const WnReaction(emoji: '👍', isSelected: true), tester);

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        await gesture.moveTo(tester.getCenter(find.byType(WnReaction)));
        await tester.pump();

        expect(_pillColor(tester), incoming.fillHover);
      });

      testWidgets('reverts on mouse exit', (tester) async {
        await mountWidget(const WnReaction(emoji: '👍'), tester);

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: const Offset(-100, -100));
        addTearDown(gesture.removePointer);
        await gesture.moveTo(tester.getCenter(find.byType(WnReaction)));
        await tester.pump();
        await gesture.moveTo(const Offset(-100, -100));
        await tester.pump();

        expect(_pillColor(tester), incoming.fill);
      });
    });
  });
}
