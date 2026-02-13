import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whitenoise/hooks/use_media_download.dart';
import 'package:whitenoise/src/rust/api/media_files.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_blurhash_placeholder.dart';

class WnMediaThumbnail extends HookWidget {
  final MediaFile mediaFile;
  final bool isSelected;
  final VoidCallback? onTap;

  const WnMediaThumbnail({
    super.key,
    required this.mediaFile,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (:status, :localPath, retry: _) = useMediaDownload(mediaFile: mediaFile);
    final size = 48.w;
    final borderWidth = 2.w;
    final fadeController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    useEffect(() {
      if (status == MediaDownloadStatus.success) {
        fadeController.forward();
      } else {
        fadeController.reset();
      }
      return null;
    }, [status]);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: const Key('thumbnail_container'),
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: borderWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2.r),
          child: _buildContent(colors, status, localPath, fadeController),
        ),
      ),
    );
  }

  Widget _buildContent(
    SemanticColors colors,
    MediaDownloadStatus status,
    String? localPath,
    AnimationController fadeController,
  ) {
    final blurhash = mediaFile.fileMetadata?.blurhash;

    if (status == MediaDownloadStatus.error) {
      return Container(
        key: const Key('thumbnail_error'),
        color: colors.fillSecondary,
      );
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        WnBlurhashPlaceholder(
          key: const Key('thumbnail_loading'),
          blurhash: blurhash,
          width: 48.w,
          height: 48.w,
        ),
        if (status == MediaDownloadStatus.success)
          FadeTransition(
            key: const Key('fade_transition'),
            opacity: fadeController,
            child: Image.file(
              File(localPath!),
              key: const Key('thumbnail_image'),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => WnBlurhashPlaceholder(
                key: const Key('thumbnail_error_fallback'),
                blurhash: blurhash,
                width: 48.w,
                height: 48.w,
              ),
            ),
          ),
      ],
    );
  }
}
