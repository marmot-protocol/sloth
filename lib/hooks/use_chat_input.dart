import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/src/rust/api/messages.dart';

typedef ChatInputState = ({
  TextEditingController controller,
  FocusNode focusNode,
  bool hasContent,
  VoidCallback clear,
  ChatMessage? replyingTo,
  void Function(ChatMessage message) setReplyingTo,
  VoidCallback cancelReply,
});

ChatInputState useChatInput() {
  final controller = useTextEditingController();
  final focusNode = useFocusNode();
  final hasContent = useListenableSelector(controller, () => controller.text.isNotEmpty);
  final replyingTo = useState<ChatMessage?>(null);

  void setReplyingTo(ChatMessage message) {
    replyingTo.value = message;
  }

  void cancelReply() {
    replyingTo.value = null;
  }

  void clear() {
    controller.clear();
    replyingTo.value = null;
  }

  return (
    controller: controller,
    focusNode: focusNode,
    hasContent: hasContent,
    clear: clear,
    replyingTo: replyingTo.value,
    setReplyingTo: setReplyingTo,
    cancelReply: cancelReply,
  );
}
