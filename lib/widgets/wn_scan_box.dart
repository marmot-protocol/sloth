import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sloth/hooks/use_scan.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/theme.dart';

class WnScanBox extends HookWidget {
  const WnScanBox({
    super.key,
    required this.onBarcodeDetected,
    this.onError,
    this.size,
  });

  final void Function(String value) onBarcodeDetected;
  final void Function(MobileScannerException error)? onError;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final boxSize = size ?? 240.w;
    final (:controller, isProcessing: _) = useScan(onBarcodeDetected: onBarcodeDetected);

    return Center(
      child: Container(
        width: boxSize,
        height: boxSize,
        decoration: BoxDecoration(
          border: Border.all(color: colors.borderPrimary, width: 1.w),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7.r),
          child: MobileScanner(
            controller: controller,
            errorBuilder: (context, error) {
              onError?.call(error);
              if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                return _CameraPermissionDenied(colors: colors);
              }
              return _ScannerError(colors: colors);
            },
          ),
        ),
      ),
    );
  }
}

class _CameraPermissionDenied extends StatelessWidget {
  const _CameraPermissionDenied({required this.colors});

  final SemanticColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.backgroundSecondary,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            context.l10n.cameraPermissionDenied,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: colors.backgroundContentSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.colors});

  final SemanticColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.backgroundSecondary,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            context.l10n.somethingWentWrong,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: colors.backgroundContentSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
