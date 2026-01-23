import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_copyable_field.dart';
import 'package:sloth/widgets/wn_icon.dart';
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

    testWidgets('shows view icon when obscured', (tester) async {
      await mountWidget(
        const WnCopyableField(
          label: 'Label',
          value: 'value',
          obscurable: true,
        ),
        tester,
      );
      final icons = find.byType(WnIcon);
      final viewIcon = icons.evaluate().where((e) {
        final widget = e.widget as WnIcon;
        return widget.icon == WnIcons.view;
      });
      expect(viewIcon.length, 1);
    });

    testWidgets('shows view_off icon when not obscured', (tester) async {
      await mountWidget(
        const WnCopyableField(
          label: 'Label',
          value: 'value',
          obscurable: true,
          obscured: false,
        ),
        tester,
      );
      final icons = find.byType(WnIcon);
      final viewOffIcon = icons.evaluate().where((e) {
        final widget = e.widget as WnIcon;
        return widget.icon == WnIcons.viewOff;
      });
      expect(viewOffIcon.length, 1);
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

      testWidgets('copies updated value when value prop changes', (tester) async {
        // This test verifies the fix: copy should use controller.text (the displayed value)
        // not the stale initial value prop
        await mountWidget(
          const WnCopyableField(
            label: 'Label',
            value: 'initial-value',
          ),
          tester,
        );

        // Rebuild with new value
        await mountWidget(
          const WnCopyableField(
            label: 'Label',
            value: 'updated-value',
          ),
          tester,
        );

        await tester.tap(find.byKey(const Key('copy_button')));
        expect(getClipboard(), 'updated-value');
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
