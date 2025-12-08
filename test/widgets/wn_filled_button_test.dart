import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_filled_button.dart' show WnFilledButton;
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnFilledButton tests', () {
    testWidgets('displays text', (WidgetTester tester) async {
      final widget = WnFilledButton(
        text: 'Hi I am a button!',
        onPressed: () {},
      );
      await mountWidget(widget, tester);
      expect(find.text('Hi I am a button!'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      var onPressedCalled = false;
      final widget = WnFilledButton(
        text: 'Hi I am a button!',
        onPressed: () {
          onPressedCalled = true;
        },
      );
      await mountWidget(widget, tester);
      await tester.tap(find.byType(WnFilledButton));
      expect(onPressedCalled, isTrue);
    });
  });
}
