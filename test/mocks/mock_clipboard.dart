import 'package:flutter/services.dart' show SystemChannels;
import 'package:flutter_test/flutter_test.dart' show TestDefaultBinaryMessengerBinding;

String? Function() mockClipboard() {
  String? content;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        content = (call.arguments as Map)['text'] as String?;
      }
      return null;
    },
  );
  return () => content;
}

void mockClipboardFailing() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') throw Exception('clipboard error');
      return null;
    },
  );
}

void clearClipboardMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    null,
  );
}
