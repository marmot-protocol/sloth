import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_copyable_field.dart';
import '../mocks/mock_clipboard.dart';
import '../test_helpers.dart';

void main() {
  group('WnCopyableField', () {
    testWidgets('displays label', (tester) async {
      await mountWidget(
        const WnCopyableField(
          label: 'My Label',
          value: 'my-value',
        ),
        tester,
      );
      expect(find.text('My Label'), findsOneWidget);
    });

    testWidgets('displays value in text field', (tester) async {
      await mountWidget(
        const WnCopyableField(
          label: 'Label',
          value: 'my-value',
        ),
        tester,
      );
      expect(find.text('my-value'), findsOneWidget);
    });

    testWidgets('displays copy button', (tester) async {
      await mountWidget(
        const WnCopyableField(
          label: 'Label',
          value: 'value',
        ),
        tester,
      );
      expect(find.byKey(const Key('copy_button')), findsOneWidget);
    });

    testWidgets('does not show visibility toggle when not obscurable', (tester) async {
      await mountWidget(
        const WnCopyableField(
          label: 'Label',
          value: 'value',
        ),
        tester,
      );
      expect(find.byKey(const Key('visibility_toggle')), findsNothing);
    });

    testWidgets('shows visibility toggle when obscurable', (tester) async {
      await mountWidget(
        const WnCopyableField(
          label: 'Label',
          value: 'value',
          obscurable: true,
        ),
        tester,
      );
      expect(find.byKey(const Key('visibility_toggle')), findsOneWidget);
    });

    testWidgets('shows visibility_outlined icon when obscured', (tester) async {
      await mountWidget(
        const WnCopyableField(
          label: 'Label',
          value: 'value',
          obscurable: true,
        ),
        tester,
      );
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('shows visibility_off_outlined icon when not obscured', (tester) async {
      await mountWidget(
        const WnCopyableField(
          label: 'Label',
          value: 'value',
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
        await mountWidget(
          const WnCopyableField(
            label: 'Label',
            value: 'secret-value',
          ),
          tester,
        );
        await tester.tap(find.byKey(const Key('copy_button')));
        expect(getClipboard(), 'secret-value');
      });

      testWidgets('shows snackbar when copiedMessage is provided', (tester) async {
        await mountWidget(
          const WnCopyableField(
            label: 'Label',
            value: 'value',
            copiedMessage: 'Copied!',
          ),
          tester,
        );
        await tester.tap(find.byKey(const Key('copy_button')));
        await tester.pump();
        expect(find.text('Copied!'), findsOneWidget);
      });

      testWidgets('does not show snackbar when copiedMessage is null', (tester) async {
        await mountWidget(
          const WnCopyableField(
            label: 'Label',
            value: 'value',
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
        await mountWidget(
          WnCopyableField(
            label: 'Label',
            value: 'value',
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
