import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/hooks/use_chat_input.dart';
import '../test_helpers.dart';

void main() {
  group('useChatInput', () {
    testWidgets('provides a controller', (tester) async {
      final result = (await mountHook(tester, useChatInput))();

      expect(result.controller, isNotNull);
    });

    testWidgets('provides a focusNode', (tester) async {
      final result = (await mountHook(tester, useChatInput))();

      expect(result.focusNode, isNotNull);
    });

    testWidgets('hasContent is false initially', (tester) async {
      final result = (await mountHook(tester, useChatInput))();

      expect(result.hasContent, isFalse);
    });

    testWidgets('hasContent is true when text is entered', (tester) async {
      final getResult = await mountHook(tester, useChatInput);
      getResult().controller.text = 'hello';
      await tester.pump();

      expect(getResult().hasContent, isTrue);
    });

    testWidgets('clear empties the controller', (tester) async {
      final getResult = await mountHook(tester, useChatInput);
      getResult().controller.text = 'hello';
      await tester.pump();
      expect(getResult().hasContent, isTrue);

      getResult().clear();
      await tester.pump();

      expect(getResult().controller.text, isEmpty);
      expect(getResult().hasContent, isFalse);
    });
  });
}
