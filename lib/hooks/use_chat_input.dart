import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

typedef ChatInputState = ({
  TextEditingController controller,
  FocusNode focusNode,
  bool hasContent,
  VoidCallback clear,
});

ChatInputState useChatInput() {
  final controller = useTextEditingController();
  final focusNode = useFocusNode();
  final hasContent = useListenableSelector(controller, () => controller.text.isNotEmpty);

  return (
    controller: controller,
    focusNode: focusNode,
    hasContent: hasContent,
    clear: controller.clear,
  );
}
