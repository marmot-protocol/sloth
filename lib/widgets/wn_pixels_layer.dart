import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'
    show HookWidget, useAnimationController, useEffect;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_animated_pixel_overlay.dart';

class WnPixelsLayer extends HookWidget {
  const WnPixelsLayer({super.key, this.isAnimating = false});

  final bool isAnimating;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 2000),
    );

    useEffect(() {
      if (isAnimating) {
        controller.repeat();
      } else {
        controller.stop();
        controller.reset();
      }
      return null;
    }, [isAnimating]);
    return Positioned(
      top: 0,
      height: 300.h,
      width: 400.w,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) {
          return LinearGradient(
            colors: [
              colors.backgroundPrimary.withValues(alpha: 0.8),
              colors.backgroundPrimary.withValues(alpha: 0.6),
              colors.backgroundPrimary.withValues(alpha: 0.2),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(rect);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.asset(
              'assets/svgs/pixels.svg',
              fit: BoxFit.cover,
            ),
            if (isAnimating)
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return WnAnimatedPixelOverlay(
                    key: const Key('animation_layer'),
                    progress: controller.value,
                    color: colors.backgroundPrimary,
                    width: 400.w,
                    height: 300.h,
                    pixelSize: 18.0.w,
                    shouldDrawThreshold: 0.6,
                    seed: 123,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
