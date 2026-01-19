import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_secret_field.dart';
import '../mocks/mock_clipboard.dart';
import '../test_helpers.dart';

void main() {
  group('WnSecretField', () {
    testWidgets('displays label', (tester) async {
      final controller = TextEditingController(text: 'my-value');
      await mountWidget(
        WnSecretField(
          label: 'My Label',
          value: 'my-value',
          controller: controller,
        ),
        tester,
      );
      expect(find.text('My Label'), findsOneWidget);
    });

    testWidgets('displays value in text field', (tester) async {
      final controller = TextEditingController(text: 'my-value');
      await mountWidget(
        WnSecretField(
          label: 'Label',
          value: 'my-value',
          controller: controller,
        ),
        tester,
      );
      expect(find.text('my-value'), findsOneWidget);
    });

    testWidgets('displays copy button', (tester) async {
      final controller = TextEditingController(text: 'value');
      await mountWidget(
        WnSecretField(
          label: 'Label',
          value: 'value',
          controller: controller,
        ),
        tester,
      );
      expect(find.byKey(const Key('copy_button')), findsOneWidget);
    });

    testWidgets('does not show visibility toggle when not obscurable', (tester) async {
      final controller = TextEditingController(text: 'value');
      await mountWidget(
        WnSecretField(
          label: 'Label',
          value: 'value',
          controller: controller,
        ),
        tester,
      );
      expect(find.byKey(const Key('visibility_toggle')), findsNothing);
    });

    testWidgets('shows visibility toggle when obscurable', (tester) async {
      final controller = TextEditingController(text: 'value');
      await mountWidget(
        WnSecretField(
          label: 'Label',
          value: 'value',
          controller: controller,
          obscurable: true,
        ),
        tester,
      );
      expect(find.byKey(const Key('visibility_toggle')), findsOneWidget);
    });

    testWidgets('shows visibility_outlined icon when obscured', (tester) async {
      final controller = TextEditingController(text: 'value');
      await mountWidget(
        WnSecretField(
          label: 'Label',
          value: 'value',
          controller: controller,
          obscurable: true,
        ),
        tester,
      );
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('shows visibility_off_outlined icon when not obscured', (tester) async {
      final controller = TextEditingController(text: 'value');
      await mountWidget(
        WnSecretField(
          label: 'Label',
          value: 'value',
          controller: controller,
          obscurable: true,
          obscured: false,
        ),
        tester,
      );
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    group('copy functionality', () {
      late String? Function() getClipboard;

      setUp(() {
        getClipboard = mockClipboard();
      });

      testWidgets('copies value to clipboard on tap', (tester) async {
        final controller = TextEditingController(text: 'secret-value');
        await mountWidget(
          WnSecretField(
            label: 'Label',
            value: 'secret-value',
            controller: controller,
          ),
          tester,
        );
        await tester.tap(find.byKey(const Key('copy_button')));
        expect(getClipboard(), 'secret-value');
      });

      testWidgets('shows snackbar when copiedMessage is provided', (tester) async {
        final controller = TextEditingController(text: 'value');
        await mountWidget(
          WnSecretField(
            label: 'Label',
            value: 'value',
            controller: controller,
            copiedMessage: 'Copied!',
          ),
          tester,
        );
        await tester.tap(find.byKey(const Key('copy_button')));
        await tester.pump();
        expect(find.text('Copied!'), findsOneWidget);
      });

      testWidgets('does not show snackbar when copiedMessage is null', (tester) async {
        final controller = TextEditingController(text: 'value');
        await mountWidget(
          WnSecretField(
            label: 'Label',
            value: 'value',
            controller: controller,
          ),
          tester,
        );
        await tester.tap(find.byKey(const Key('copy_button')));
        await tester.pump();
        expect(find.byType(SnackBar), findsNothing);
      });
    });

    group('visibility toggle', () {
      testWidgets('calls onToggleVisibility when tapped', (tester) async {
        var toggleCalled = false;
        final controller = TextEditingController(text: 'value');
        await mountWidget(
          WnSecretField(
            label: 'Label',
            value: 'value',
            controller: controller,
            obscurable: true,
            onToggleVisibility: () => toggleCalled = true,
          ),
          tester,
        );
        await tester.tap(find.byKey(const Key('visibility_toggle')));
        expect(toggleCalled, isTrue);
      });
    });
  });
}
