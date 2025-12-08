import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_outlined_button.dart' show WnOutlinedButton;
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnOutlinedButton tests', () {
    testWidgets('displays text', (WidgetTester tester) async {
      final widget = WnOutlinedButton(
        text: 'Hi I am a button!',
        onPressed: () {},
      );
      await mountWidget(widget, tester);
      expect(find.text('Hi I am a button!'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      var onPressedCalled = false;
      final widget = WnOutlinedButton(
        text: 'Hi I am a button!',
        onPressed: () {
          onPressedCalled = true;
        },
      );
      await mountWidget(widget, tester);
      await tester.tap(find.byType(WnOutlinedButton));
      expect(onPressedCalled, isTrue);
    });
  });
}
