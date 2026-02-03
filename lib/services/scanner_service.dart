import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';

abstract class ScannerService {
  MobileScannerController get controller;
  Stream<BarcodeCapture> get barcodeStream;
  Future<void> start();
  Future<void> stop();
  void dispose();
}

class MobileScannerService implements ScannerService {
  MobileScannerService({MobileScannerController? controller})
    : _controller = controller ?? MobileScannerController(formats: [BarcodeFormat.qrCode]);

  final MobileScannerController _controller;

  @override
  MobileScannerController get controller => _controller;

  @override
  Stream<BarcodeCapture> get barcodeStream => _controller.barcodes;

  @override
  Future<void> start() async {
    try {
      await _controller.start();
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      await _controller.stop();
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
  }
}

ScannerService Function() _scannerServiceFactory = _defaultFactory;
ScannerService Function() _defaultFactory = MobileScannerService.new;

ScannerService createScannerService() => _scannerServiceFactory();

void setScannerServiceFactory(ScannerService Function() factory) {
  _scannerServiceFactory = factory;
}

void resetScannerServiceFactory() {
  _scannerServiceFactory = _defaultFactory;
}
