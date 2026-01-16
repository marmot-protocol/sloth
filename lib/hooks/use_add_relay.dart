import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';

final _logger = Logger('useAddRelay');

({
  TextEditingController controller,
  bool isValid,
  String? validationError,
  void Function() paste,
})
useAddRelay() {
  final controller = useTextEditingController(text: 'wss://');
  final isValid = useState(false);
  final validationError = useState<String?>(null);
  final debounceTimer = useRef<Timer?>(null);

  String? validateUrl(String url) {
    if (!url.startsWith('wss://') && !url.startsWith('ws://')) {
      return 'URL must start with wss:// or ws://';
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      return 'Invalid relay URL';
    }

    if (uri.host.isEmpty) {
      return 'Invalid relay URL';
    }

    if (uri.host.contains('wss://') || uri.host.contains('ws://') || uri.host.contains('://')) {
      return 'Invalid relay URL';
    }

    final hostParts = uri.host.split('.');
    if (hostParts.length < 2 || hostParts.any((part) => part.isEmpty)) {
      return 'Invalid relay URL';
    }

    return null;
  }

  void validateRelayUrl() {
    final url = controller.text.trim();

    if (url.isEmpty || url == 'wss://' || url == 'ws://') {
      isValid.value = false;
      validationError.value = null;
      return;
    }

    final error = validateUrl(url);

    if (error == null) {
      isValid.value = true;
      validationError.value = null;
    } else {
      isValid.value = false;
      validationError.value = error;
    }
  }

  void onUrlChanged() {
    debounceTimer.value?.cancel();
    debounceTimer.value = Timer(const Duration(milliseconds: 500), validateRelayUrl);
  }

  useEffect(() {
    controller.addListener(onUrlChanged);
    return () {
      debounceTimer.value?.cancel();
      controller.removeListener(onUrlChanged);
    };
  }, [controller]);

  Future<void> paste() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        final String pastedText = clipboardData!.text!.trim();

        if (pastedText.startsWith('wss://') || pastedText.startsWith('ws://')) {
          controller.text = pastedText;
        } else {
          controller.text = 'wss://$pastedText';
        }

        debounceTimer.value?.cancel();
        debounceTimer.value = Timer(const Duration(milliseconds: 100), validateRelayUrl);
      }
    } catch (e) {
      _logger.warning('Failed to paste from clipboard: $e');
    }
  }

  return (
    controller: controller,
    isValid: isValid.value,
    validationError: validationError.value,
    paste: paste,
  );
}
