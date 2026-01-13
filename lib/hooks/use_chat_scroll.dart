import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const _bottomThreshold = 50.0;

void useChatScroll({
  required ScrollController scrollController,
  required FocusNode focusNode,
  required String? latestMessageId,
  required bool isLatestMessageOwn,
}) {
  final isAtBottom = useState(true);
  final prevLatestMessageId = useRef<String?>(null);
  final shouldStayAtBottom = useRef(false);

  void scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void jumpToBottom() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  void updateIsAtBottom() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    final atBottom = position.pixels <= _bottomThreshold;
    if (isAtBottom.value != atBottom) {
      isAtBottom.value = atBottom;
    }
  }

  useEffect(() {
    scrollController.addListener(updateIsAtBottom);
    return () => scrollController.removeListener(updateIsAtBottom);
  }, [scrollController]);

  useEffect(() {
    void onFocusChange() {
      if (focusNode.hasFocus) {
        shouldStayAtBottom.value = true;
        scrollToBottom();
      } else {
        shouldStayAtBottom.value = false;
      }
    }

    focusNode.addListener(onFocusChange);
    return () => focusNode.removeListener(onFocusChange);
  }, [focusNode]);

  final observer = useMemoized(
    () => _KeyboardObserver(() {
      if (shouldStayAtBottom.value || isAtBottom.value) {
        jumpToBottom();
      }
    }),
    [],
  );

  useEffect(() {
    WidgetsBinding.instance.addObserver(observer);
    return () => WidgetsBinding.instance.removeObserver(observer);
  }, [observer]);

  useEffect(() {
    if (latestMessageId != null && latestMessageId != prevLatestMessageId.value) {
      final isInitialLoad = prevLatestMessageId.value == null;
      if (isInitialLoad || isAtBottom.value || isLatestMessageOwn) {
        scrollToBottom();
      }
    }
    prevLatestMessageId.value = latestMessageId;
    return null;
  }, [latestMessageId, isLatestMessageOwn]);
}

class _KeyboardObserver extends WidgetsBindingObserver {
  _KeyboardObserver(this.onMetricsChange);

  final VoidCallback onMetricsChange;

  @override
  void didChangeMetrics() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      onMetricsChange();
    });
  }
}
