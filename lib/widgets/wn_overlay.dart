import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:whitenoise/theme.dart';

class WnOverlay extends StatelessWidget {
  const WnOverlay({
    super.key,
    this.sigmaX = 50.0,
    this.sigmaY = 50.0,
  });

  final double sigmaX;
  final double sigmaY;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: ColoredBox(color: colors.overlayPrimary),
      ),
    );
  }
}
