import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'
    show HookWidget, useAnimationController, useEffect, useState;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:sloth/theme.dart';
import 'package:sloth/utils/formatting.dart' show formatInitials;
import 'package:sloth/widgets/wn_animated_pixel_overlay.dart';

class WnImagePicker extends HookWidget {
  const WnImagePicker({
    super.key,
    this.imagePath,
    this.displayName,
    this.onImageSelected,
    this.loading = false,
    this.disabled = false,
  });

  final String? imagePath;
  final String? displayName;
  final ValueChanged<String>? onImageSelected;
  final bool loading;
  final bool disabled;

  static final double _size = 80.w;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isImageChanging = useState(false);

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      isImageChanging.value = true;
      onImageSelected?.call(image.path);

      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        isImageChanging.value = false;
      }
    }

    final isDisabled = disabled || isImageChanging.value;
    final isAnimating = loading || isImageChanging.value;

    return GestureDetector(
      onTap: isDisabled ? null : pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: _ImageDisplay(
              imagePath: imagePath,
              displayName: displayName,
              isAnimating: isAnimating,
            ),
          ),
          if (!isDisabled)
            Container(
              key: const Key('edit_icon'),
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: colors.backgroundPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: colors.backgroundContentTertiary, width: 1.5),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/svgs/edit.svg',
                  width: 14.w,
                  height: 14.w,
                  colorFilter: ColorFilter.mode(
                    colors.backgroundContentTertiary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageDisplay extends HookWidget {
  const _ImageDisplay({
    this.imagePath,
    this.displayName,
    this.isAnimating = false,
  });

  final String? imagePath;
  final String? displayName;
  final bool isAnimating;

  double get _size => WnImagePicker._size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    useEffect(() {
      if (isAnimating) {
        animationController.repeat();
      } else {
        animationController.stop();
        animationController.reset();
      }
      return null;
    }, [isAnimating]);

    if (imagePath != null && imagePath!.isNotEmpty) {
      final isUrl = imagePath!.startsWith('http://') || imagePath!.startsWith('https://');
      return _buildImageContainer(
        colors: colors,
        child: isUrl
            ? Image.network(
                imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildInitialsContent(colors),
              )
            : Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildInitialsContent(colors),
              ),
        loading: isAnimating,
        animationController: animationController,
      );
    }

    return _buildInitials(colors);
  }

  Widget _buildImageContainer({
    required SemanticColors colors,
    required Widget child,
    required bool loading,
    required AnimationController animationController,
  }) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.backgroundSecondary.withValues(alpha: 0.4),
        border: Border.all(color: colors.backgroundContentTertiary, width: 1.5),
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            AnimatedBuilder(
              animation: animationController,
              builder: (context, _) {
                if (!loading && !animationController.isAnimating) {
                  return const SizedBox.shrink();
                }
                final opacity = 1.0 - (animationController.value / 2);

                return Opacity(
                  opacity: opacity,
                  child: WnAnimatedPixelOverlay(
                    key: const Key('image_picker_animation'),
                    progress: animationController.value,
                    color: colors.backgroundPrimary,
                    width: _size,
                    height: _size,
                    pixelSize: 8.0.w,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitials(SemanticColors colors) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.backgroundSecondary.withValues(alpha: 0.4),
        border: Border.all(color: colors.backgroundContentTertiary, width: 1.5),
      ),
      child: Center(child: _buildInitialsContent(colors)),
    );
  }

  Widget _buildInitialsContent(SemanticColors colors) {
    final initials = formatInitials(displayName);

    if (initials != null) {
      return Text(
        initials,
        style: TextStyle(
          color: colors.fillContentPrimary,
          fontSize: _size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return SvgPicture.asset(
      key: const Key('user_icon'),
      'assets/svgs/user.svg',
      width: _size * 0.4,
      height: _size * 0.4,
      colorFilter: ColorFilter.mode(
        colors.fillContentPrimary,
        BlendMode.srcIn,
      ),
    );
  }
}
