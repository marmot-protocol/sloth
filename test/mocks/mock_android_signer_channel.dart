import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channelName = 'org.parres.whitenoise/android_signer';

({
  void Function(String, Object?) setResult,
  void Function(String, PlatformException) setException,
  List<MethodCall> log,
  void Function() reset,
})
mockAndroidSignerChannel() {
  final log = <MethodCall>[];
  final results = <String, Object?>{};
  final exceptions = <String, PlatformException>{};
  final channel = const MethodChannel(_channelName);

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall call) async {
      log.add(call);
      final e = exceptions[call.method];
      if (e != null) throw e;
      return results[call.method];
    },
  );

  return (
    setResult: (String method, Object? value) {
      results[method] = value;
      exceptions.remove(method);
    },
    setException: (String method, PlatformException e) {
      exceptions[method] = e;
      results.remove(method);
    },
    log: log,
    reset: () {
      results.clear();
      exceptions.clear();
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
    },
  );
}
