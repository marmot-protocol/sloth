import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_animated_pixel_overlay.dart';
import 'package:sloth/widgets/wn_initials_avatar.dart';

class WnAvatar extends HookWidget {
  const WnAvatar({
    super.key,
    this.pictureUrl,
    this.displayName,
    this.size,
    this.animated = false,
    this.imageProvider,
  });

  final String? pictureUrl;
  final String? displayName;
  final double? size;
  final bool animated;

  final ImageProvider? imageProvider;

  @override
  Widget build(BuildContext context) {
    final avatarSize = size ?? 44.w;

    final image = useMemoized(() {
      if (imageProvider != null) return imageProvider;
      final url = pictureUrl;
      if (url == null || url.isEmpty) return null;
      return CachedNetworkImageProvider(url);
    }, [pictureUrl, imageProvider]);

    if (image == null) {
      return WnInitialsAvatar(displayName: displayName, size: avatarSize);
    }

    if (animated) {
      return _AnimatedAvatar(
        image: image,
        displayName: displayName,
        size: avatarSize,
      );
    }

    return _StaticAvatar(
      image: image,
      displayName: displayName,
      size: avatarSize,
    );
  }
}

class _AvatarContainer extends StatelessWidget {
  const _AvatarContainer({required this.size, required this.child});

  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.borderTertiary, width: 1.5),
      ),
      child: ClipOval(child: child),
    );
  }
}

class _StaticAvatar extends StatelessWidget {
  const _StaticAvatar({
    required this.image,
    this.displayName,
    required this.size,
  });

  final ImageProvider image;
  final String? displayName;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _AvatarContainer(
      size: size,
      child: Image(
        image: image,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => WnInitialsAvatar(
          displayName: displayName,
          size: size,
        ),
      ),
    );
  }
}

class _AnimatedAvatar extends HookWidget {
  const _AnimatedAvatar({
    required this.image,
    this.displayName,
    required this.size,
  });

  final ImageProvider image;
  final String? displayName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    final isLoading = useState(true);
    final hasError = useState(false);

    useEffect(() {
      void stopLoading() {
        isLoading.value = false;
        animationController.stop();
        animationController.reset();
      }

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

    if (hasError.value) {
      return WnInitialsAvatar(
        displayName: displayName,
        size: size,
      );
    }

    return _AvatarContainer(
      size: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: colors.backgroundSecondary.withValues(alpha: 0.4)),
          if (!isLoading.value)
            Image(
              image: image,
              width: size,
              height: size,
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
                    width: size,
                    height: size,
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
