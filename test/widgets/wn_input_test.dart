import 'package:flutter/material.dart' show EditableText, Key, TextField;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_icon.dart' show WnIcons;
import 'package:sloth/widgets/wn_input.dart';
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnInput', () {
    testWidgets('displays label when provided', (tester) async {
      await mountWidget(
        const WnInput(label: 'My Label', placeholder: 'hint'),
        tester,
      );
      expect(find.text('My Label'), findsOneWidget);
    });

    testWidgets('does not display label when not provided', (tester) async {
      await mountWidget(
        const WnInput(placeholder: 'hint'),
        tester,
      );
      expect(find.text('My Label'), findsNothing);
    });

    testWidgets('displays placeholder', (tester) async {
      await mountWidget(
        const WnInput(label: 'Label', placeholder: 'Enter text'),
        tester,
      );
      expect(find.text('Enter text'), findsOneWidget);
    });

    testWidgets('displays entered text', (tester) async {
      await mountWidget(
        const WnInput(label: 'Label', placeholder: 'hint'),
        tester,
      );
      await tester.enterText(find.byKey(const Key('input_field')), 'hello world');
      await tester.pump();
      expect(find.text('hello world'), findsOneWidget);
    });

    testWidgets('is not focused by default', (tester) async {
      await mountWidget(
        const WnInput(label: 'Label', placeholder: 'hint'),
        tester,
      );
      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.focusNode.hasFocus, isFalse);
    });

    group('with autofocus', () {
      testWidgets('is focused', (tester) async {
        await mountWidget(
          const WnInput(label: 'Label', placeholder: 'hint', autofocus: true),
          tester,
        );
        final field = tester.widget<EditableText>(find.byType(EditableText));
        expect(field.focusNode.hasFocus, isTrue);
      });
    });

    group('sizes', () {
      testWidgets('defaults to size56', (tester) async {
        await mountWidget(
          const WnInput(placeholder: 'hint'),
          tester,
        );
        final field = find.byKey(const Key('input_field'));
        expect(field, findsOneWidget);
      });

      testWidgets('can use size44', (tester) async {
        await mountWidget(
          const WnInput(placeholder: 'hint', size: WnInputSize.size44),
          tester,
        );
        final field = find.byKey(const Key('input_field'));
        expect(field, findsOneWidget);
      });
    });

    group('with error', () {
      testWidgets('shows error message', (tester) async {
        await mountWidget(
          const WnInput(
            label: 'Label',
            placeholder: 'hint',
            errorText: 'This field is required',
          ),
          tester,
        );
        expect(find.text('This field is required'), findsOneWidget);
      });

      testWidgets('does not show error when not provided', (tester) async {
        await mountWidget(
          const WnInput(label: 'Label', placeholder: 'hint'),
          tester,
        );
        expect(find.text('This field is required'), findsNothing);
      });
    });

    group('with helper text', () {
      testWidgets('shows helper text when provided', (tester) async {
        await mountWidget(
          const WnInput(
            label: 'Label',
            placeholder: 'hint',
            helperText: 'This is helper text',
          ),
          tester,
        );
        expect(find.text('This is helper text'), findsOneWidget);
      });

      testWidgets('error text takes precedence over helper text', (tester) async {
        await mountWidget(
          const WnInput(
            label: 'Label',
            placeholder: 'hint',
            helperText: 'Helper',
            errorText: 'Error',
          ),
          tester,
        );
        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Helper'), findsNothing);
      });
    });

    group('with label help icon', () {
      testWidgets('displays help icon when provided', (tester) async {
        await mountWidget(
          WnInput(
            label: 'Label',
            placeholder: 'hint',
            labelHelpIcon: () {},
          ),
          tester,
        );
        expect(find.byKey(const Key('label_help_icon')), findsOneWidget);
      });

      testWidgets('calls callback when tapped', (tester) async {
        bool helpTapped = false;
        await mountWidget(
          WnInput(
            label: 'Label',
            placeholder: 'hint',
            labelHelpIcon: () {
              helpTapped = true;
            },
          ),
          tester,
        );
        await tester.tap(find.byKey(const Key('label_help_icon')));
        await tester.pump();
        expect(helpTapped, isTrue);
      });
    });

    group('with disabled state', () {
      testWidgets('field is disabled when enabled is false', (tester) async {
        await mountWidget(
          const WnInput(label: 'Label', placeholder: 'hint', enabled: false),
          tester,
        );
        final field = tester.widget<TextField>(find.byKey(const Key('input_field')));
        expect(field.enabled, isFalse);
      });
    });

    group('with inline action', () {
      testWidgets('displays inline action when provided', (tester) async {
        await mountWidget(
          WnInput(
            label: 'Label',
            placeholder: 'hint',
            inlineAction: WnInputFieldButton(
              key: const Key('inline_action'),
              icon: WnIcons.search,
              onPressed: () {},
            ),
          ),
          tester,
        );
        expect(find.byKey(const Key('inline_action')), findsOneWidget);
      });
    });

    group('with trailing action', () {
      testWidgets('displays trailing action when provided', (tester) async {
        await mountWidget(
          WnInput(
            label: 'Label',
            placeholder: 'hint',
            trailingAction: WnInputTrailingButton(
              key: const Key('trailing_action'),
              icon: WnIcons.paste,
              onPressed: () {},
            ),
          ),
          tester,
        );
        expect(find.byKey(const Key('trailing_action')), findsOneWidget);
      });
    });
  });

  group('WnInputFieldButton', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;
      await mountWidget(
        WnInputFieldButton(
          icon: WnIcons.search,
          onPressed: () {
            pressed = true;
          },
        ),
        tester,
      );
      await tester.tap(find.byType(WnInputFieldButton));
      await tester.pump();
      expect(pressed, isTrue);
    });
  });

  group('WnInputTrailingButton', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;
      await mountWidget(
        WnInputTrailingButton(
          icon: WnIcons.paste,
          onPressed: () {
            pressed = true;
          },
        ),
        tester,
      );
      await tester.tap(find.byType(WnInputTrailingButton));
      await tester.pump();
      expect(pressed, isTrue);
    });
  });
}
