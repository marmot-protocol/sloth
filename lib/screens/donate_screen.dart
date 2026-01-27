import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_copyable_field.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  static const _lightningAddress = 'whitenoise@npub.cash';
  static const _bitcoinAddress =
      'sp1qqvp56mxcj9pz9xudvlch5g4ah5hrc8rj6neu25p34rc9gxhp38cwqqlmld28u57w2srgckr34dkyg3q02phu8tm05cyj483q026xedp0s5f5j40p';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlateContainer(
            child: Column(
              spacing: 24.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WnScreenHeader(title: context.l10n.donateToWhiteNoise),
                Text(
                  context.l10n.donateDescription,
                  style: TextStyle(
                    color: colors.backgroundContentTertiary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                WnCopyableField(
                  label: context.l10n.lightningAddress,
                  value: _lightningAddress,
                  copiedMessage: context.l10n.copiedToClipboardThankYou,
                ),
                WnCopyableField(
                  label: context.l10n.bitcoinSilentPayment,
                  value: _bitcoinAddress,
                  copiedMessage: context.l10n.copiedToClipboardThankYou,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
