import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:whitenoise/services/scanner_service.dart';
import '../mocks/mock_mobile_scanner_controller.dart';

void main() {
  group('MobileScannerService', () {
    late MockMobileScannerController mockController;
    late MobileScannerService service;

    setUp(() {
      mockController = MockMobileScannerController();
      service = MobileScannerService(controller: mockController);
    });

    test('controller returns injected controller', () {
      expect(service.controller, mockController);
    });

    test('barcodeStream returns controller barcodes stream', () {
      expect(service.barcodeStream, mockController.barcodes);
    });

    test('start calls controller start and returns true', () async {
      expect(mockController.startCalled, isFalse);

      final result = await service.start();

      expect(mockController.startCalled, isTrue);
      expect(result, isTrue);
    });

    test('stop calls controller stop and returns true', () async {
      expect(mockController.stopCalled, isFalse);

      final result = await service.stop();

      expect(mockController.stopCalled, isTrue);
      expect(result, isTrue);
    });

    test('dispose calls controller dispose', () {
      expect(mockController.disposeCalled, isFalse);

      service.dispose();

      expect(mockController.disposeCalled, isTrue);
    });
  });

  group('ScannerService factory', () {
    tearDown(() {
      resetScannerServiceFactory();
    });

    test('createScannerService returns MobileScannerService by default', () {
      final service = createScannerService();

      expect(service, isA<MobileScannerService>());
    });

    test('setScannerServiceFactory changes factory', () {
      final mockController = MockMobileScannerController();
      final customService = MobileScannerService(controller: mockController);

      setScannerServiceFactory(() => customService);
      final service = createScannerService();

      expect(service, customService);
    });

    test('resetScannerServiceFactory restores default factory', () {
      final mockController = MockMobileScannerController();
      final customService = MobileScannerService(controller: mockController);

      setScannerServiceFactory(() => customService);
      resetScannerServiceFactory();
      final service = createScannerService();

      expect(service, isNot(customService));
      expect(service, isA<MobileScannerService>());
    });
  });

  group('MobileScannerService error handling', () {
    test('start returns false on exception', () async {
      final throwingController = _ThrowingMobileScannerController();
      final service = MobileScannerService(controller: throwingController);

      final result = await service.start();

      expect(result, isFalse);
    });

    test('stop returns false on exception', () async {
      final throwingController = _ThrowingMobileScannerController();
      final service = MobileScannerService(controller: throwingController);

      final result = await service.stop();

      expect(result, isFalse);
    });
  });
}

class _ThrowingMobileScannerController implements MobileScannerController {
  @override
  Future<void> start({CameraFacing? cameraDirection}) async {
    throw Exception('Camera not available');
  }

  @override
  Future<void> stop() async {
    throw Exception('Camera not available');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
