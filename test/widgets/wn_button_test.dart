import 'package:flutter/material.dart' show Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_icon.dart';
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnButton tests', () {
    group('basic functionality', () {
      testWidgets('displays text', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Click me',
          onPressed: () {},
        );
        await mountWidget(widget, tester);
        expect(find.text('Click me'), findsOneWidget);
      });

      testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
        var onPressedCalled = false;
        final widget = WnButton(
          text: 'Click me',
          onPressed: () {
            onPressedCalled = true;
          },
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnButton));
        expect(onPressedCalled, isTrue);
      });
    });

    group('button types', () {
      testWidgets('renders primary type by default', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Primary',
          onPressed: () {},
        );
        await mountWidget(widget, tester);
        expect(find.text('Primary'), findsOneWidget);
      });

      testWidgets('renders outline type', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Outline',
          onPressed: () {},
          type: WnButtonType.outline,
        );
        await mountWidget(widget, tester);
        expect(find.text('Outline'), findsOneWidget);
      });

      testWidgets('renders ghost type', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Ghost',
          onPressed: () {},
          type: WnButtonType.ghost,
        );
        await mountWidget(widget, tester);
        expect(find.text('Ghost'), findsOneWidget);
      });

      testWidgets('renders overlay type', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Overlay',
          onPressed: () {},
          type: WnButtonType.overlay,
        );
        await mountWidget(widget, tester);
        expect(find.text('Overlay'), findsOneWidget);
      });

      testWidgets('renders destructive type', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Destructive',
          onPressed: () {},
          type: WnButtonType.destructive,
        );
        await mountWidget(widget, tester);
        expect(find.text('Destructive'), findsOneWidget);
      });
    });

    group('button sizes', () {
      testWidgets('renders large size by default', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Large',
          onPressed: () {},
        );
        await mountWidget(widget, tester);
        expect(find.text('Large'), findsOneWidget);
      });

      testWidgets('renders medium size', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Medium',
          onPressed: () {},
          size: WnButtonSize.medium,
        );
        await mountWidget(widget, tester);
        expect(find.text('Medium'), findsOneWidget);
      });

      testWidgets('renders small size', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Small',
          onPressed: () {},
          size: WnButtonSize.small,
        );
        await mountWidget(widget, tester);
        expect(find.text('Small'), findsOneWidget);
      });
    });

    group('icons', () {
      testWidgets('renders leading icon when provided', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'With Icon',
          onPressed: () {},
          leadingIcon: WnIcons.addLarge,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('leading_icon')), findsOneWidget);
      });

      testWidgets('renders trailing icon when provided', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'With Icon',
          onPressed: () {},
          trailingIcon: WnIcons.arrowRight,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('trailing_icon')), findsOneWidget);
      });

      testWidgets('renders both leading and trailing icons', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'With Icons',
          onPressed: () {},
          leadingIcon: WnIcons.addLarge,
          trailingIcon: WnIcons.arrowRight,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('leading_icon')), findsOneWidget);
        expect(find.byKey(const Key('trailing_icon')), findsOneWidget);
      });

      testWidgets('does not render icons when not provided', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'No Icons',
          onPressed: () {},
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('leading_icon')), findsNothing);
        expect(find.byKey(const Key('trailing_icon')), findsNothing);
      });
    });

    group('loading state', () {
      testWidgets('displays loading indicator when loading', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Loading',
          onPressed: () {},
          loading: true,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
      });

      testWidgets('hides text when loading', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Loading',
          onPressed: () {},
          loading: true,
        );
        await mountWidget(widget, tester);
        expect(find.text('Loading'), findsNothing);
      });

      testWidgets('does not call onPressed when loading', (WidgetTester tester) async {
        var onPressedCalled = false;
        final widget = WnButton(
          text: 'Loading',
          onPressed: () {
            onPressedCalled = true;
          },
          loading: true,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnButton));
        expect(onPressedCalled, isFalse);
      });

      testWidgets('hides icons when loading', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Loading',
          onPressed: () {},
          loading: true,
          leadingIcon: WnIcons.addLarge,
          trailingIcon: WnIcons.arrowRight,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('leading_icon')), findsNothing);
        expect(find.byKey(const Key('trailing_icon')), findsNothing);
      });
    });

    group('disabled state', () {
      testWidgets('displays text when disabled', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Disabled',
          onPressed: () {},
          disabled: true,
        );
        await mountWidget(widget, tester);
        expect(find.text('Disabled'), findsOneWidget);
      });

      testWidgets('does not display loading indicator when disabled', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Disabled',
          onPressed: () {},
          disabled: true,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('loading_indicator')), findsNothing);
      });

      testWidgets('does not call onPressed when disabled', (WidgetTester tester) async {
        var onPressedCalled = false;
        final widget = WnButton(
          text: 'Disabled',
          onPressed: () {
            onPressedCalled = true;
          },
          disabled: true,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnButton));
        expect(onPressedCalled, isFalse);
      });

      testWidgets('displays icons when disabled', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Disabled',
          onPressed: () {},
          disabled: true,
          leadingIcon: WnIcons.addLarge,
          trailingIcon: WnIcons.arrowRight,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('leading_icon')), findsOneWidget);
        expect(find.byKey(const Key('trailing_icon')), findsOneWidget);
      });
    });

    group('disabled state for each button type', () {
      testWidgets('primary button respects disabled state', (WidgetTester tester) async {
        var onPressedCalled = false;
        final widget = WnButton(
          text: 'Primary',
          onPressed: () {
            onPressedCalled = true;
          },
          disabled: true,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnButton));
        expect(onPressedCalled, isFalse);
      });

      testWidgets('outline button respects disabled state', (WidgetTester tester) async {
        var onPressedCalled = false;
        final widget = WnButton(
          text: 'Outline',
          onPressed: () {
            onPressedCalled = true;
          },
          type: WnButtonType.outline,
          disabled: true,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnButton));
        expect(onPressedCalled, isFalse);
      });

      testWidgets('ghost button respects disabled state', (WidgetTester tester) async {
        var onPressedCalled = false;
        final widget = WnButton(
          text: 'Ghost',
          onPressed: () {
            onPressedCalled = true;
          },
          type: WnButtonType.ghost,
          disabled: true,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnButton));
        expect(onPressedCalled, isFalse);
      });

      testWidgets('overlay button respects disabled state', (WidgetTester tester) async {
        var onPressedCalled = false;
        final widget = WnButton(
          text: 'Overlay',
          onPressed: () {
            onPressedCalled = true;
          },
          type: WnButtonType.overlay,
          disabled: true,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnButton));
        expect(onPressedCalled, isFalse);
      });

      testWidgets('destructive button respects disabled state', (WidgetTester tester) async {
        var onPressedCalled = false;
        final widget = WnButton(
          text: 'Destructive',
          onPressed: () {
            onPressedCalled = true;
          },
          type: WnButtonType.destructive,
          disabled: true,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnButton));
        expect(onPressedCalled, isFalse);
      });
    });

    group('loading state for each button type', () {
      testWidgets('primary button shows loading indicator', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Primary',
          onPressed: () {},
          loading: true,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
      });

      testWidgets('outline button shows loading indicator', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Outline',
          onPressed: () {},
          type: WnButtonType.outline,
          loading: true,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
      });

      testWidgets('ghost button shows loading indicator', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Ghost',
          onPressed: () {},
          type: WnButtonType.ghost,
          loading: true,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
      });

      testWidgets('overlay button shows loading indicator', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Overlay',
          onPressed: () {},
          type: WnButtonType.overlay,
          loading: true,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
      });

      testWidgets('destructive button shows loading indicator', (WidgetTester tester) async {
        final widget = WnButton(
          text: 'Destructive',
          onPressed: () {},
          type: WnButtonType.destructive,
          loading: true,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
      });
    });

    group('WnButtonSize enum', () {
      test('large size has height of 56', () {
        expect(WnButtonSize.large.height, 56);
      });

      test('medium size has height of 44', () {
        expect(WnButtonSize.medium.height, 44);
      });

      test('small size has height of 32', () {
        expect(WnButtonSize.small.height, 32);
      });
    });
  });
}
