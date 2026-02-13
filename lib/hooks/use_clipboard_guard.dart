import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

final _logger = Logger('useClipboardGuard');

const Duration _clipboardClearDelay = Duration(seconds: 60);

Timer? _activeTimer;

@visibleForTesting
void cancelClipboardGuardTimer() {
  _activeTimer?.cancel();
  _activeTimer = null;
}

void Function() useClipboardGuard() {
  void scheduleClipboardClear() {
    _activeTimer?.cancel();
    _activeTimer = Timer(_clipboardClearDelay, () async {
      try {
        await Clipboard.setData(const ClipboardData(text: ''));
      } catch (e) {
        _logger.warning('Failed to clear clipboard: $e');
      }
      _activeTimer = null;
    });
  }

  return scheduleClipboardClear;
}
