import 'package:flutter/material.dart' show EditableText, Key, TextFormField;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_text_form_field.dart' show WnTextFormField;
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnTextFormField', () {
    testWidgets('displays label', (tester) async {
      await mountWidget(
        const WnTextFormField(label: 'My Label', placeholder: 'hint'),
        tester,
      );
      expect(find.text('My Label'), findsOneWidget);
    });

    testWidgets('displays placeholder', (tester) async {
      await mountWidget(
        const WnTextFormField(label: 'Label', placeholder: 'Enter text'),
        tester,
      );
      expect(find.text('Enter text'), findsOneWidget);
    });

    testWidgets('displays entered text', (tester) async {
      await mountWidget(
        const WnTextFormField(label: 'Label', placeholder: 'hint'),
        tester,
      );
      await tester.enterText(find.byType(TextFormField), 'hello world');
      await tester.pump();
      expect(find.text('hello world'), findsOneWidget);
    });

    testWidgets('is not focused by default', (tester) async {
      await mountWidget(
        const WnTextFormField(
          label: 'Label',
          placeholder: 'hint',
        ),
        tester,
      );
      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.focusNode.hasFocus, isFalse);
    });

    testWidgets('does not obscure text by default', (tester) async {
      await mountWidget(
        const WnTextFormField(
          label: 'Label',
          placeholder: 'hint',
        ),
        tester,
      );
      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.obscureText, isFalse);
    });

    testWidgets('does not display error by default', (tester) async {
      await mountWidget(
        const WnTextFormField(
          label: 'Label',
          placeholder: 'hint',
        ),
        tester,
      );
      expect(find.byKey(const Key('error_icon')), findsNothing);
    });

    group('with autofocus', () {
      testWidgets('is focused', (tester) async {
        await mountWidget(
          const WnTextFormField(
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

    group('with obscureText', () {
      testWidgets('obscures content', (tester) async {
        await mountWidget(
          const WnTextFormField(
            label: 'Password',
            placeholder: 'hint',
            obscureText: true,
          ),
          tester,
        );
        await tester.enterText(find.byType(TextFormField), 'secret');
        final field = tester.widget<EditableText>(find.byType(EditableText));
        expect(field.obscureText, isTrue);
      });
    });

    group('multiline', () {
      testWidgets('defaults to single line', (tester) async {
        await mountWidget(
          const WnTextFormField(label: 'Label', placeholder: 'hint'),
          tester,
        );
        final field = tester.widget<EditableText>(find.byType(EditableText));
        expect(field.maxLines, 1);
      });

      testWidgets('supports multiple lines', (tester) async {
        await mountWidget(
          const WnTextFormField(label: 'Label', placeholder: 'hint', maxLines: 3),
          tester,
        );
        final field = tester.widget<EditableText>(find.byType(EditableText));
        expect(field.maxLines, 3);
      });

      testWidgets('supports minLines', (tester) async {
        await mountWidget(
          const WnTextFormField(
            label: 'Label',
            placeholder: 'hint',
            minLines: 2,
            maxLines: 5,
          ),
          tester,
        );
        final field = tester.widget<EditableText>(find.byType(EditableText));
        expect(field.minLines, 2);
      });
    });

    group('with error', () {
      testWidgets('shows error message', (tester) async {
        await mountWidget(
          const WnTextFormField(
            label: 'Label',
            placeholder: 'hint',
            errorText: 'This field is required',
          ),
          tester,
        );
        expect(find.text('This field is required'), findsOneWidget);
      });

      testWidgets('displays error icon', (tester) async {
        await mountWidget(
          const WnTextFormField(
            label: 'Label',
            placeholder: 'hint',
            errorText: 'Error',
          ),
          tester,
        );
        expect(find.byKey(const Key('error_icon')), findsOneWidget);
      });
    });

    group('with paste button', () {
      testWidgets('does not display paste button when onPaste is null', (tester) async {
        await mountWidget(
          const WnTextFormField(
            label: 'Label',
            placeholder: 'hint',
          ),
          tester,
        );
        expect(find.byKey(const Key('paste_button')), findsNothing);
      });

      testWidgets('displays paste button when onPaste is provided', (tester) async {
        await mountWidget(
          WnTextFormField(
            label: 'Label',
            placeholder: 'hint',
            onPaste: () {},
          ),
          tester,
        );
        expect(find.byKey(const Key('paste_button')), findsOneWidget);
      });

      testWidgets('calls onPaste when paste button is tapped', (tester) async {
        bool pasteCalled = false;
        await mountWidget(
          WnTextFormField(
            label: 'Label',
            placeholder: 'hint',
            onPaste: () {
              pasteCalled = true;
            },
          ),
          tester,
        );
        await tester.tap(find.byKey(const Key('paste_button')));
        await tester.pump();
        expect(pasteCalled, isTrue);
      });
    });
  });
}
