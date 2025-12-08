import 'package:flutter/material.dart' show Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_outlined_container.dart' show WnOutlinedContainer;
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnOutlinedContainer tests', () {
    testWidgets('renders child', (WidgetTester tester) async {
      final widget = const WnOutlinedContainer(
        child: Text('Hi I am a child!'),
      );
      await mountWidget(widget, tester);
      expect(find.text('Hi I am a child!'), findsOneWidget);
    });
  });
}
