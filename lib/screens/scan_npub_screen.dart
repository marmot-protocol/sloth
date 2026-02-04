import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/theme.dart';
import 'package:sloth/utils/encoding.dart' show hexFromNpub;
import 'package:sloth/widgets/wn_scan_box.dart' show WnScanBox;
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';

class ScanNpubScreen extends StatelessWidget {
  const ScanNpubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    void onBarcodeDetected(String value) {
      final hexPubkey = hexFromNpub(value);
      if (hexPubkey != null) {
        Routes.goBack(context);
        Routes.pushToStartChat(context, hexPubkey);
      }
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlate(
            header: WnSlateNavigationHeader(
              title: context.l10n.scanNpub,
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
                    context.l10n.scanNpubHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
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
    );
  }
}
