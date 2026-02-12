import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

typedef ScrollToMessageResult = ({
  AutoScrollController scrollController,
  Future<void> Function(String messageId) scrollToMessage,
});

ScrollToMessageResult useScrollToMessage({
  required int? Function(String messageId) getReversedMessageIndex,
}) {
  final controller = useMemoized(() => AutoScrollController(), []);

  useEffect(() => controller.dispose, [controller]);

  Future<void> scrollToMessage(String messageId) async {
    final reversedIndex = getReversedMessageIndex(messageId);
    if (reversedIndex == null) return;

    await controller.scrollToIndex(
      reversedIndex,
      preferPosition: AutoScrollPosition.middle,
      duration: const Duration(milliseconds: 300),
    );
  }

  return (
    scrollController: controller,
    scrollToMessage: scrollToMessage,
  );
}
