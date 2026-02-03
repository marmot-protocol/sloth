import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';

class MockMobileScannerController implements MobileScannerController {
  bool startCalled = false;
  bool stopCalled = false;
  bool disposeCalled = false;

  final _barcodeController = StreamController<BarcodeCapture>.broadcast();

  @override
  Stream<BarcodeCapture> get barcodes => _barcodeController.stream;

  @override
  Future<void> start({CameraFacing? cameraDirection}) async {
    startCalled = true;
  }

  @override
  Future<void> stop() async {
    stopCalled = true;
  }

  @override
  Future<void> dispose() async {
    disposeCalled = true;
    await _barcodeController.close();
  }

  @override
  List<BarcodeFormat> get formats => [BarcodeFormat.qrCode];

  void reset() {
    startCalled = false;
    stopCalled = false;
    disposeCalled = false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
