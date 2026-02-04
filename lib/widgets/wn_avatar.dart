import 'dart:io' show File;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/utils/avatar_color.dart';
import 'package:sloth/utils/formatting.dart' show formatInitials;
import 'package:sloth/widgets/wn_icon.dart';

export 'package:sloth/utils/avatar_color.dart';

enum WnAvatarSize { small, medium, large }

class WnAvatar extends HookWidget {
  const WnAvatar({
    super.key,
    this.pictureUrl,
    this.displayName,
    this.size = WnAvatarSize.small,
    this.imageProvider,
    this.color = AvatarColor.neutral,
    this.onEditTap,
  });

  final String? pictureUrl;
  final String? displayName;
  final WnAvatarSize size;
  final ImageProvider? imageProvider;
  final AvatarColor color;
  final VoidCallback? onEditTap;

  double _getAvatarSize() {
    return switch (size) {
      WnAvatarSize.small => 48.w,
      WnAvatarSize.medium => 56.w,
      WnAvatarSize.large => 96.w,
    };
  }

  double _getFontSize() {
    return switch (size) {
      WnAvatarSize.small => 14.sp,
      WnAvatarSize.medium => 16.sp,
      WnAvatarSize.large => 32.sp,
    };
  }

  double _getIconSize() {
    return switch (size) {
      WnAvatarSize.small => 16.w,
      WnAvatarSize.medium => 20.w,
      WnAvatarSize.large => 32.w,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final avatarSize = _getAvatarSize();
    final fontSize = _getFontSize();
    final iconSize = _getIconSize();

    final colorSet = color.toColorSet(colors);

    final image = useMemoized(() {
      if (imageProvider != null) return imageProvider;
      final url = pictureUrl;
      if (url == null || url.isEmpty) return null;
      final isUrl = url.startsWith('http://') || url.startsWith('https://');
      if (isUrl) {
        return CachedNetworkImageProvider(url);
      }
      return FileImage(File(url));
    }, [pictureUrl, imageProvider]);

    final avatarWidget = image == null
        ? _InitialsAvatar(
            displayName: displayName,
            size: avatarSize,
            fontSize: fontSize,
            iconSize: iconSize,
            colorSet: colorSet,
          )
        : _ImageAvatar(
            image: image,
            displayName: displayName,
            size: avatarSize,
            fontSize: fontSize,
            iconSize: iconSize,
            colorSet: colorSet,
          );

    final showEditButton = onEditTap != null && size == WnAvatarSize.large;

    return Stack(
      children: [
        avatarWidget,
        if (showEditButton)
          Positioned(
            right: 0,
            bottom: 0,
            child: _EditButton(onTap: onEditTap!),
          ),
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final buttonSize = 28.w;
    final iconSize = 16.w;

    return GestureDetector(
      key: const Key('avatar_edit_button'),
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.backgroundSecondary,
          border: Border.all(color: colors.borderTertiary),
        ),
        child: Center(
          child: WnIcon(
            WnIcons.editCircle,
            size: iconSize,
            color: colors.backgroundContentPrimary,
          ),
        ),
      ),
    );
  }
}

class _InitialsContent extends StatelessWidget {
  const _InitialsContent({
    this.displayName,
    required this.fontSize,
    required this.iconSize,
    required this.contentColor,
  });

  final String? displayName;
  final double fontSize;
  final double iconSize;
  final Color contentColor;

  @override
  Widget build(BuildContext context) {
    final initials = formatInitials(displayName);

    return Center(
      child: initials != null
          ? Text(
              initials,
              style: TextStyle(
                color: contentColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            )
          : WnIcon(
              WnIcons.user,
              size: iconSize,
              color: contentColor,
            ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({
    this.displayName,
    required this.size,
    required this.fontSize,
    required this.iconSize,
    required this.colorSet,
  });

  final String? displayName;
  final double size;
  final double fontSize;
  final double iconSize;
  final AvatarColorSet colorSet;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('avatar_container'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorSet.background,
        border: Border.all(color: colorSet.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: _InitialsContent(
        displayName: displayName,
        fontSize: fontSize,
        iconSize: iconSize,
        contentColor: colorSet.content,
      ),
    );
  }
}

class _AvatarContainer extends StatelessWidget {
  const _AvatarContainer({
    required this.size,
    required this.child,
  });

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
        color: colors.backgroundPrimary,
        border: Border.all(color: colors.borderTertiary),
      ),
      child: ClipOval(child: child),
    );
  }
}

class _ImageAvatar extends HookWidget {
  const _ImageAvatar({
    required this.image,
    this.displayName,
    required this.size,
    required this.fontSize,
    required this.iconSize,
    required this.colorSet,
  });

  final ImageProvider image;
  final String? displayName;
  final double size;
  final double fontSize;
  final double iconSize;
  final AvatarColorSet colorSet;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLoading = useState(true);
    final hasError = useState(false);
    final previousImage = useRef<ImageProvider?>(null);

    useEffect(() {
      isLoading.value = true;
      hasError.value = false;

      final imageStream = image.resolve(ImageConfiguration.empty);
      final listener = ImageStreamListener(
        (_, _) {
          isLoading.value = false;
          previousImage.value = image;
        },
        onError: (_, _) {
          isLoading.value = false;
          hasError.value = true;
        },
      );
      imageStream.addListener(listener);

      return () => imageStream.removeListener(listener);
    }, [image]);

    if (hasError.value && previousImage.value == null) {
      return _InitialsAvatar(
        displayName: displayName,
        size: size,
        fontSize: fontSize,
        iconSize: iconSize,
        colorSet: colorSet,
      );
    }

    return _AvatarContainer(
      size: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: colors.backgroundPrimary,
            child: _InitialsContent(
              displayName: displayName,
              fontSize: fontSize,
              iconSize: iconSize,
              contentColor: colors.backgroundContentSecondary,
            ),
          ),
          if (previousImage.value != null)
            Image(
              image: previousImage.value!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
            opacity: isLoading.value ? 0.0 : 1.0,
            child: Image(
              image: image,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
