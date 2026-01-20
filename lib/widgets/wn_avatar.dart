import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_initials_avatar.dart';

class WnAvatar extends StatelessWidget {
  const WnAvatar({
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
    final avatarSize = size ?? 44.w;

    if (pictureUrl?.isNotEmpty ?? false) {
      return SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: Image.network(
          key: const Key('avatar_image'),
          pictureUrl!,
          width: avatarSize,
          height: avatarSize,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            final imageWithBorder = Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.borderSecondary, width: 1.5),
              ),
              child: ClipOval(child: child),
            );
            if (wasSynchronouslyLoaded) return imageWithBorder;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: imageWithBorder,
            );
          },
          errorBuilder: (context, error, stackTrace) => WnInitialsAvatar(
            displayName: displayName,
            size: avatarSize,
          ),
        ),
      );
    }

    return WnInitialsAvatar(displayName: displayName, size: avatarSize);
  }
}
