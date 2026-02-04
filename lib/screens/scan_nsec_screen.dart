import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:go_router/go_router.dart' show GoRouter;
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_pixels_layer.dart' show WnPixelsLayer;
import 'package:sloth/widgets/wn_scan_box.dart' show WnScanBox;
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';

class ScanNsecScreen extends StatelessWidget {
  const ScanNsecScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typographyScaled;

    void onBarcodeDetected(String value) {
      GoRouter.of(context).pop(value);
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WnPixelsLayer(),
          Positioned.fill(
            child: GestureDetector(
              key: const Key('scan_nsec_background'),
              onTap: () => Routes.goBack(context),
              behavior: HitTestBehavior.opaque,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 34.h),
              child: WnSlate(
                header: WnSlateNavigationHeader(
                  title: context.l10n.scanNsec,
                  type: WnSlateNavigationType.back,
                  onNavigate: () => Routes.goBack(context),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: WnScanBox(onBarcodeDetected: onBarcodeDetected),
                      ),
                      Gap(12.h),
                      Text(
                        context.l10n.scanNsecHint,
                        textAlign: TextAlign.center,
                        style: typography.medium14.copyWith(
                          color: colors.backgroundContentSecondary,
                        ),
                      ),
                      Gap(12.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
