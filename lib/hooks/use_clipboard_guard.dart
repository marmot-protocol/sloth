import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';

final _logger = Logger('useClipboardGuard');

const Duration _clipboardClearDelay = Duration(seconds: 60);

void Function() useClipboardGuard() {
  final timerRef = useRef<Timer?>(null);

  useEffect(() {
    return () {
      timerRef.value?.cancel();
    };
  }, const []);

  void scheduleClipboardClear() {
    timerRef.value?.cancel();
    timerRef.value = Timer(_clipboardClearDelay, () {
      try {
        Clipboard.setData(const ClipboardData(text: ''));
      } catch (e) {
        _logger.warning('Failed to clear clipboard: $e');
      }
    });
  }

  return scheduleClipboardClear;
}
