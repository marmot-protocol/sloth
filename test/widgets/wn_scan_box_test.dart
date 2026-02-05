import 'package:flutter/material.dart' show Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sloth/widgets/wn_scan_box.dart';
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnScanBox', () {
    testWidgets('renders scanner container', (tester) async {
      await mountWidget(
        WnScanBox(onBarcodeDetected: (_) {}),
        tester,
      );
      expect(find.byType(MobileScanner), findsOneWidget);
    });

    testWidgets('uses custom dimensions when provided', (tester) async {
      await mountWidget(
        WnScanBox(
          onBarcodeDetected: (_) {},
          width: 200,
          height: 300,
        ),
        tester,
      );
      final container = tester.getSize(find.byType(MobileScanner).first);
      expect(container.width, lessThanOrEqualTo(200));
      expect(container.height, lessThanOrEqualTo(300));
    });

    testWidgets('does not show scan button key by default', (tester) async {
      await mountWidget(
        WnScanBox(onBarcodeDetected: (_) {}),
        tester,
      );
      expect(find.byKey(const Key('scan_button')), findsNothing);
    });
  });
}
