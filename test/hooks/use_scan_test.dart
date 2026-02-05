import 'dart:ui' show AppLifecycleState;

import 'package:flutter/widgets.dart' show SizedBox;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:whitenoise/hooks/use_scan.dart';
import '../mocks/mock_scanner_service.dart';
import '../test_helpers.dart' show mountHook;

void main() {
  group('useScan', () {
    late MockScannerService mockService;

    setUp(() {
      mockService = setupMockScannerService();
    });

    tearDown(() {
      tearDownMockScannerService();
    });

    testWidgets('returns controller and isProcessing', (tester) async {
      final getResult = await mountHook(tester, () {
        return useScan(onBarcodeDetected: (_) {});
      });

      final result = getResult();
      expect(result.controller, isA<MobileScannerController>());
      expect(result.isProcessing, isFalse);
    });

    testWidgets('controller is memoized across rebuilds', (tester) async {
      MobileScannerController? firstController;
      MobileScannerController? secondController;

      await mountHook(tester, () {
        final result = useScan(onBarcodeDetected: (_) {});
        firstController ??= result.controller;
        secondController = result.controller;
        return result;
      });

      await tester.pump();

      expect(firstController, equals(secondController));
    });

    testWidgets('isProcessing starts as false', (tester) async {
      final getResult = await mountHook(tester, () {
        return useScan(onBarcodeDetected: (_) {});
      });

      expect(getResult().isProcessing, isFalse);
    });

    testWidgets('controller has qrCode format', (tester) async {
      final getResult = await mountHook(tester, () {
        return useScan(onBarcodeDetected: (_) {});
      });

      final result = getResult();
      expect(result.controller.formats, contains(BarcodeFormat.qrCode));
    });

    group('barcode detection', () {
      testWidgets('calls onBarcodeDetected when barcode is scanned', (tester) async {
        String? detectedValue;

        await mountHook(tester, () {
          return useScan(onBarcodeDetected: (value) => detectedValue = value);
        });

        mockService.emitBarcode('nsec1testvalue');
        await tester.pump();

        expect(detectedValue, 'nsec1testvalue');

        await tester.pump(const Duration(milliseconds: 600));
      });

      testWidgets('ignores empty barcode list', (tester) async {
        String? detectedValue;

        await mountHook(tester, () {
          return useScan(onBarcodeDetected: (value) => detectedValue = value);
        });

        mockService.emitEmpty();
        await tester.pump();

        expect(detectedValue, isNull);
      });

      testWidgets('ignores barcode with empty value', (tester) async {
        String? detectedValue;

        await mountHook(tester, () {
          return useScan(onBarcodeDetected: (value) => detectedValue = value);
        });

        mockService.emitBarcodeWithEmptyValue();
        await tester.pump();

        expect(detectedValue, isNull);
      });

      testWidgets('trims whitespace from scanned value', (tester) async {
        String? detectedValue;

        await mountHook(tester, () {
          return useScan(onBarcodeDetected: (value) => detectedValue = value);
        });

        mockService.emitBarcode('  nsec1test  ');
        await tester.pump();

        expect(detectedValue, 'nsec1test');

        await tester.pump(const Duration(milliseconds: 600));
      });

      testWidgets('sets isProcessing to true after detection', (tester) async {
        final getResult = await mountHook(tester, () {
          return useScan(onBarcodeDetected: (_) {});
        });

        mockService.emitBarcode('nsec1test');
        await tester.pump();

        expect(getResult().isProcessing, isTrue);

        await tester.pump(const Duration(milliseconds: 600));
      });

      testWidgets('resets isProcessing after delay', (tester) async {
        final getResult = await mountHook(tester, () {
          return useScan(onBarcodeDetected: (_) {});
        });

        mockService.emitBarcode('nsec1test');
        await tester.pump();
        expect(getResult().isProcessing, isTrue);

        await tester.pump(const Duration(milliseconds: 600));
        expect(getResult().isProcessing, isFalse);
      });

      testWidgets('ignores barcodes while processing', (tester) async {
        final detectedValues = <String>[];

        await mountHook(tester, () {
          return useScan(onBarcodeDetected: (value) => detectedValues.add(value));
        });

        mockService.emitBarcode('first');
        await tester.pump();
        mockService.emitBarcode('second');
        await tester.pump();

        expect(detectedValues, ['first']);

        await tester.pump(const Duration(milliseconds: 600));
      });
    });

    group('lifecycle', () {
      testWidgets('disposes service on unmount', (tester) async {
        await mountHook(tester, () {
          return useScan(onBarcodeDetected: (_) {});
        });

        expect(mockService.disposeCalled, isFalse);

        await tester.pumpWidget(const SizedBox());
        await tester.pump();

        expect(mockService.disposeCalled, isTrue);
      });

      testWidgets('calls start when app resumes', (tester) async {
        await mountHook(tester, () {
          return useScan(onBarcodeDetected: (_) {});
        });

        expect(mockService.startCalled, isFalse);

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();

        expect(mockService.startCalled, isTrue);
      });

      testWidgets('calls stop when app becomes inactive', (tester) async {
        await mountHook(tester, () {
          return useScan(onBarcodeDetected: (_) {});
        });

        expect(mockService.stopCalled, isFalse);

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        await tester.pump();

        expect(mockService.stopCalled, isTrue);
      });

      testWidgets('does not call start or stop when paused', (tester) async {
        await mountHook(tester, () {
          return useScan(onBarcodeDetected: (_) {});
        });

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();

        expect(mockService.startCalled, isFalse);
        expect(mockService.stopCalled, isFalse);
      });

      testWidgets('does not call start or stop when hidden', (tester) async {
        await mountHook(tester, () {
          return useScan(onBarcodeDetected: (_) {});
        });

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        await tester.pump();

        expect(mockService.startCalled, isFalse);
        expect(mockService.stopCalled, isFalse);
      });

      testWidgets('does not call start or stop when detached', (tester) async {
        await mountHook(tester, () {
          return useScan(onBarcodeDetected: (_) {});
        });

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
        await tester.pump();

        expect(mockService.startCalled, isFalse);
        expect(mockService.stopCalled, isFalse);
      });
    });
  });
}
