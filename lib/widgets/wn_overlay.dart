import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';

enum WnOverlayVariant {
  heavy,
  light,
}

class WnOverlay extends StatelessWidget {
  const WnOverlay({
    super.key,
    this.variant = WnOverlayVariant.heavy,
  });

  final WnOverlayVariant variant;

  double get _sigmaX => variant == WnOverlayVariant.heavy ? 40.0 : 10.0;
  double get _sigmaY => variant == WnOverlayVariant.heavy ? 40.0 : 10.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final overlayColor = variant == WnOverlayVariant.heavy
        ? colors.overlayPrimary
        : colors.overlaySecondary;

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
        child: ColoredBox(color: overlayColor),
      ),
    );
  }
}
