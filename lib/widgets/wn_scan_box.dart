import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sloth/theme.dart';

class WnScanBox extends StatelessWidget {
  const WnScanBox({
    super.key,
    required this.onBarcodeDetected,
    this.width,
    this.height,
  });

  final void Function(String value) onBarcodeDetected;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: colors.borderTertiary, width: 1.w),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7.r),
        child: MobileScanner(
          onDetect: (capture) {
            if (capture.barcodes.isEmpty) return;
            final barcode = capture.barcodes.first;
            final rawValue = barcode.rawValue?.trim() ?? '';
            if (rawValue.isNotEmpty) {
              onBarcodeDetected(rawValue);
            }
          },
        ),
      ),
    );
  }
}
