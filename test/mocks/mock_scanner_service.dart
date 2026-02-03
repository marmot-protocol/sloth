import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sloth/services/scanner_service.dart';

class MockScannerService implements ScannerService {
  MockScannerService() : _controller = MobileScannerController(formats: [BarcodeFormat.qrCode]);

  final MobileScannerController _controller;
  final _barcodeController = StreamController<BarcodeCapture>.broadcast();

  bool startCalled = false;
  bool stopCalled = false;
  bool disposeCalled = false;

  @override
  MobileScannerController get controller => _controller;

  @override
  Stream<BarcodeCapture> get barcodeStream => _barcodeController.stream;

  @override
  Future<void> start() async {
    startCalled = true;
  }

  @override
  Future<void> stop() async {
    stopCalled = true;
  }

  @override
  void dispose() {
    disposeCalled = true;
    _barcodeController.close();
  }

  void emitBarcode(String value) {
    final barcode = Barcode(rawValue: value);
    _barcodeController.add(BarcodeCapture(barcodes: [barcode]));
  }

  void emitEmpty() {
    _barcodeController.add(const BarcodeCapture());
  }

  void emitBarcodeWithEmptyValue() {
    const barcode = Barcode(rawValue: '');
    _barcodeController.add(const BarcodeCapture(barcodes: [barcode]));
  }

  void reset() {
    startCalled = false;
    stopCalled = false;
    disposeCalled = false;
  }
}

MockScannerService? _mockInstance;

MockScannerService setupMockScannerService() {
  _mockInstance = MockScannerService();
  setScannerServiceFactory(() => _mockInstance!);
  return _mockInstance!;
}

void tearDownMockScannerService() {
  resetScannerServiceFactory();
  _mockInstance = null;
}
