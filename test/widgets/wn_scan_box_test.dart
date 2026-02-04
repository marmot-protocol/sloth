import 'package:flutter/material.dart' show Key, Locale, MaterialApp, Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/widgets/wn_scan_box.dart';
import '../mocks/mock_scanner_service.dart';
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnScanBox', () {
    setUp(() {
      setupMockScannerService();
    });

    tearDown(() {
      tearDownMockScannerService();
    });

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

    group('error handling', () {
      testWidgets('calls onError when error occurs', (tester) async {
        MobileScannerException? receivedError;

        await mountWidget(
          WnScanBox(
            onBarcodeDetected: (_) {},
            onError: (error) => receivedError = error,
          ),
          tester,
        );

        final scanner = tester.widget<MobileScanner>(find.byType(MobileScanner));
        const error = MobileScannerException(
          errorCode: MobileScannerErrorCode.genericError,
        );

        scanner.errorBuilder!(tester.element(find.byType(MobileScanner)), error);
        await tester.pump();

        expect(receivedError, error);
      });

      testWidgets('shows permission denied message when permission denied', (tester) async {
        await mountWidget(
          WnScanBox(onBarcodeDetected: (_) {}),
          tester,
        );

        final scanner = tester.widget<MobileScanner>(find.byType(MobileScanner));
        final context = tester.element(find.byType(MobileScanner));
        const error = MobileScannerException(
          errorCode: MobileScannerErrorCode.permissionDenied,
        );

        final errorWidget = scanner.errorBuilder!(context, error);
        await tester.pumpWidget(
          _wrapWithLocalization(errorWidget),
        );

        expect(find.text('Camera permission denied'), findsOneWidget);
      });

      testWidgets('shows generic error message for other errors', (tester) async {
        await mountWidget(
          WnScanBox(onBarcodeDetected: (_) {}),
          tester,
        );

        final scanner = tester.widget<MobileScanner>(find.byType(MobileScanner));
        final context = tester.element(find.byType(MobileScanner));
        const error = MobileScannerException(
          errorCode: MobileScannerErrorCode.genericError,
        );

        final errorWidget = scanner.errorBuilder!(context, error);
        await tester.pumpWidget(
          _wrapWithLocalization(errorWidget),
        );

        expect(find.text('Something went wrong'), findsOneWidget);
      });
    });
  });
}

MaterialApp _wrapWithLocalization(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: child,
  );
}
