import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_button.dart';
import 'package:whitenoise/widgets/wn_confirmation_bottom_sheet.dart';

import '../test_helpers.dart';

void main() {
  group('WnConfirmationBottomSheet', () {
    testWidgets('displays title and message', (tester) async {
      await mountWidget(
        WnConfirmationBottomSheet(
          title: 'Test Title',
          message: 'Test Message',
          confirmText: 'Confirm',
          onConfirm: () {},
        ),
        tester,
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
    });

    testWidgets('displays confirm and cancel buttons', (tester) async {
      await mountWidget(
        WnConfirmationBottomSheet(
          title: 'Test Title',
          message: 'Test Message',
          confirmText: 'Confirm',
          cancelText: 'Cancel',
          onConfirm: () {},
        ),
        tester,
      );

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('confirm button calls onConfirm', (tester) async {
      var confirmed = false;

      await mountWidget(
        WnConfirmationBottomSheet(
          title: 'Test Title',
          message: 'Test Message',
          confirmText: 'Confirm',
          onConfirm: () => confirmed = true,
        ),
        tester,
      );

      await tester.tap(find.byKey(const Key('confirm_button')));
      await tester.pumpAndSettle();

      expect(confirmed, true);
    });

    testWidgets('cancel button dismisses sheet', (tester) async {
      bool? result;

      await mountTestApp(tester);

      final context = tester.element(find.byType(Scaffold));

      WnConfirmationBottomSheet.show(
        context: context,
        title: 'Test Title',
        message: 'Test Message',
        confirmText: 'Confirm',
      ).then((value) => result = value);

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cancel_button')));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets('uses destructive button style when isDestructive is true', (tester) async {
      await mountWidget(
        WnConfirmationBottomSheet(
          title: 'Test Title',
          message: 'Test Message',
          confirmText: 'Delete',
          onConfirm: () {},
          isDestructive: true,
        ),
        tester,
      );

      expect(find.text('Delete'), findsOneWidget);

      final confirmButton = tester.widget<WnButton>(find.byKey(const Key('confirm_button')));
      expect(confirmButton.type, WnButtonType.destructive);
    });

    testWidgets('show returns true when confirmed', (tester) async {
      bool? result;

      await mountTestApp(tester);

      final context = tester.element(find.byType(Scaffold));

      WnConfirmationBottomSheet.show(
        context: context,
        title: 'Test Title',
        message: 'Test Message',
        confirmText: 'Confirm',
      ).then((value) => result = value);

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_button')));
      await tester.pumpAndSettle();

      expect(result, true);
    });
  });
}
