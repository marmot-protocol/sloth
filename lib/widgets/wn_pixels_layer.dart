import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:sloth/theme.dart';

class WnPixelsLayer extends StatelessWidget {
  const WnPixelsLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Positioned(
      top: 0,
      height: 300.h,
      width: 400.w,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) {
          return LinearGradient(
            colors: [
              colors.primary.withValues(alpha: 0.8),
              colors.primary.withValues(alpha: 0.6),
              colors.primary.withValues(alpha: 0.2),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(rect);
        },
        child: SvgPicture.asset(
          'assets/svgs/pixels.svg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
