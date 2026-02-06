import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:whitenoise/services/scanner_service.dart';

({
  MobileScannerController controller,
  bool isProcessing,
})
useScan({
  required void Function(String value) onBarcodeDetected,
}) {
  final isProcessing = useState(false);
  final scannerService = useMemoized(createScannerService);

  useEffect(() {
    StreamSubscription<BarcodeCapture>? subscription;

    void handleBarcode(BarcodeCapture capture) {
      if (capture.barcodes.isEmpty) return;
      if (isProcessing.value) return;

      final barcode = capture.barcodes.first;
      final rawValue = barcode.rawValue ?? '';
      if (rawValue.isEmpty) return;

      isProcessing.value = true;
      onBarcodeDetected(rawValue.trim());
      Future.delayed(const Duration(milliseconds: 500), () {
        isProcessing.value = false;
      });
    }

    subscription = scannerService.barcodeStream.listen(handleBarcode);

    return () {
      unawaited(subscription?.cancel());
      scannerService.dispose();
    };
  }, [scannerService]);

  useOnAppLifecycleStateChange((previous, current) {
    switch (current) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        unawaited(scannerService.start());
      case AppLifecycleState.inactive:
        unawaited(scannerService.stop());
    }
  });

  return (controller: scannerService.controller, isProcessing: isProcessing.value);
}
