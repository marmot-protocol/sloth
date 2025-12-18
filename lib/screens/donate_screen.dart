import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/widgets/wn_copyable_field.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  static const _lightningAddress = 'whitenoise@npub.cash';
  static const _bitcoinAddress =
      'sp1qqvp56mxcj9pz9xudvlch5g4ah5hrc8rj6neu25p34rc9gxhp38cwqqlmld28u57w2srgckr34dkyg3q02phu8tm05cyj483q026xedp0s5f5j40p';
  static const _copiedMessage = 'Copied to clipboard. Thank you! 🦥';

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
                const WnScreenHeader(title: 'Donate to White Noise'),
                Text(
                  'As a not-for-profit, White Noise exists solely for your privacy and freedom, not for profit. Your support keeps us independent and uncompromised.',
                  style: TextStyle(
                    color: colors.foregroundTertiary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const WnCopyableField(
                  label: 'Lightning Address',
                  value: _lightningAddress,
                  copiedMessage: _copiedMessage,
                ),
                const WnCopyableField(
                  label: 'Bitcoin Silent Payment',
                  value: _bitcoinAddress,
                  copiedMessage: _copiedMessage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
