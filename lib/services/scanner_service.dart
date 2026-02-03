import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';

abstract class ScannerService {
  MobileScannerController get controller;
  Stream<BarcodeCapture> get barcodeStream;
  Future<bool> start();
  Future<bool> stop();
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
  Future<bool> start() async {
    try {
      await _controller.start();
      return true;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> stop() async {
    try {
      await _controller.stop();
      return true;
    } on Exception {
      return false;
    }
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
