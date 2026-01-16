import 'package:flutter/services.dart' show SystemChannels;
import 'package:flutter_test/flutter_test.dart' show TestDefaultBinaryMessengerBinding;

({
  void Function(Map<String, dynamic>?) setData,
  void Function(Object) setException,
  void Function() reset,
})
mockClipboardPaste() {
  Map<String, dynamic>? clipboardData;
  Object? clipboardException;

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.getData') {
        if (clipboardException != null) {
          throw clipboardException!;
        }
        return clipboardData;
      }
      return null;
    },
  );

  return (
    setData: (data) {
      clipboardData = data;
      clipboardException = null;
    },
    setException: (exception) {
      clipboardException = exception;
      clipboardData = null;
    },
    reset: () {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    },
  );
}
