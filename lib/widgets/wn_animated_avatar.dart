import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/widgets/wn_animated_pixel_overlay.dart';
import 'package:sloth/widgets/wn_initials_avatar.dart';

class WnAnimatedAvatar extends HookWidget {
  const WnAnimatedAvatar({
    super.key,
    this.pictureUrl,
    this.displayName,
    this.size,
  });

  final String? pictureUrl;
  final String? displayName;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final avatarSize = size ?? 48.w;

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    final isLoading = useState(false);
    final hasError = useState(false);

    final image = useMemoized(
      () {
        final nonNullPictureUrl = pictureUrl;
        if (nonNullPictureUrl == null || nonNullPictureUrl.isEmpty) return null;
        return NetworkImage(nonNullPictureUrl);
      },
      [pictureUrl],
    );

    useEffect(() {
      void stopLoading() {
        isLoading.value = false;
        animationController.stop();
        animationController.reset();
      }

      if (image == null) {
        stopLoading();
        return null;
      }

      isLoading.value = true;
      hasError.value = false;
      animationController.repeat();

      final imageStream = image.resolve(ImageConfiguration.empty);
      final listener = ImageStreamListener(
        (_, _) => stopLoading(),
        onError: (_, _) {
          stopLoading();
          hasError.value = true;
        },
      );
      imageStream.addListener(listener);

      return () => imageStream.removeListener(listener);
    }, [image]);

    if (image == null || hasError.value) {
      return WnInitialsAvatar(
        displayName: displayName,
        size: avatarSize,
      );
    }

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.backgroundSecondary.withValues(alpha: 0.4),
        border: Border.all(color: colors.foregroundTertiary, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!isLoading.value)
            Image(
              image: image,
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),

          if (isLoading.value)
            AnimatedBuilder(
              animation: animationController,
              builder: (context, _) {
                final opacity = 1.0 - (animationController.value / 2);
                return Opacity(
                  opacity: opacity,
                  child: WnAnimatedPixelOverlay(
                    progress: animationController.value,
                    color: colors.backgroundPrimary,
                    width: avatarSize,
                    height: avatarSize,
                    pixelSize: 4.0.w,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
