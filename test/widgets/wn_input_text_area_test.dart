import 'package:flutter/material.dart' show EditableText, Key, TextField;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_input.dart' show WnInputSize;
import 'package:sloth/widgets/wn_input_text_area.dart';
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnInputTextArea', () {
    testWidgets('displays label when provided', (tester) async {
      await mountWidget(
        const WnInputTextArea(label: 'Description', placeholder: 'Enter text'),
        tester,
      );
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('does not display label when not provided', (tester) async {
      await mountWidget(
        const WnInputTextArea(placeholder: 'Enter text'),
        tester,
      );
      expect(find.text('Description'), findsNothing);
    });

    testWidgets('displays placeholder', (tester) async {
      await mountWidget(
        const WnInputTextArea(label: 'Label', placeholder: 'Enter your message'),
        tester,
      );
      expect(find.text('Enter your message'), findsOneWidget);
    });

    testWidgets('displays entered text', (tester) async {
      await mountWidget(
        const WnInputTextArea(label: 'Label', placeholder: 'hint'),
        tester,
      );
      await tester.enterText(find.byKey(const Key('text_area_field')), 'hello world');
      await tester.pump();
      expect(find.text('hello world'), findsOneWidget);
    });

    testWidgets('is not focused by default', (tester) async {
      await mountWidget(
        const WnInputTextArea(label: 'Label', placeholder: 'hint'),
        tester,
      );
      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.focusNode.hasFocus, isFalse);
    });

    group('with autofocus', () {
      testWidgets('is focused', (tester) async {
        await mountWidget(
          const WnInputTextArea(
            label: 'Label',
            placeholder: 'hint',
            autofocus: true,
          ),
          tester,
        );
        final field = tester.widget<EditableText>(find.byType(EditableText));
        expect(field.focusNode.hasFocus, isTrue);
      });
    });

    group('sizes', () {
      testWidgets('defaults to size56', (tester) async {
        await mountWidget(
          const WnInputTextArea(placeholder: 'hint'),
          tester,
        );
        expect(find.byKey(const Key('text_area_field')), findsOneWidget);
        final containerSize = tester.getSize(
          find.byKey(const Key('text_area_container')),
        );
        expect(containerSize.height, greaterThanOrEqualTo(182.0));
      });

      testWidgets('can use size44', (tester) async {
        await mountWidget(
          const WnInputTextArea(placeholder: 'hint', size: WnInputSize.size44),
          tester,
        );
        expect(find.byKey(const Key('text_area_field')), findsOneWidget);
        final containerSize = tester.getSize(
          find.byKey(const Key('text_area_container')),
        );
        expect(containerSize.height, greaterThanOrEqualTo(102.0));
      });
    });

    group('with error', () {
      testWidgets('shows error message', (tester) async {
        await mountWidget(
          const WnInputTextArea(
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
          const WnInputTextArea(label: 'Label', placeholder: 'hint'),
          tester,
        );
        expect(find.text('This field is required'), findsNothing);
      });
    });

    group('with helper text', () {
      testWidgets('shows helper text when provided', (tester) async {
        await mountWidget(
          const WnInputTextArea(
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
          const WnInputTextArea(
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
          WnInputTextArea(
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
          WnInputTextArea(
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
          const WnInputTextArea(label: 'Label', placeholder: 'hint', enabled: false),
          tester,
        );
        final field = tester.widget<TextField>(find.byKey(const Key('text_area_field')));
        expect(field.enabled, isFalse);
      });
    });

    group('multiline', () {
      testWidgets('supports unlimited lines by default', (tester) async {
        await mountWidget(
          const WnInputTextArea(label: 'Label', placeholder: 'hint'),
          tester,
        );
        final field = tester.widget<EditableText>(find.byType(EditableText));
        expect(field.maxLines, isNull);
      });

      testWidgets('supports limited maxLines', (tester) async {
        await mountWidget(
          const WnInputTextArea(label: 'Label', placeholder: 'hint', maxLines: 5),
          tester,
        );
        final field = tester.widget<EditableText>(find.byType(EditableText));
        expect(field.maxLines, 5);
      });
    });
  });
}
