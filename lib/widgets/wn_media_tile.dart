import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whitenoise/hooks/use_media_download.dart';
import 'package:whitenoise/src/rust/api/media_files.dart';
import 'package:whitenoise/widgets/wn_blurhash_placeholder.dart';
import 'package:whitenoise/widgets/wn_media_error_placeholder.dart';

class WnMediaTile extends HookWidget {
  final MediaFile mediaFile;
  final double? width;
  final double? height;

  const WnMediaTile({super.key, required this.mediaFile, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final (:status, :localPath, :retry) = useMediaDownload(mediaFile: mediaFile);
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

    if (status == MediaDownloadStatus.error) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: WnMediaErrorPlaceholder(
          key: const Key('error_placeholder'),
          onRetry: retry!,
          width: width,
          height: height,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          WnBlurhashPlaceholder(
            key: const Key('loading_placeholder'),
            blurhash: mediaFile.fileMetadata?.blurhash,
            width: width,
            height: height,
          ),
          if (status == MediaDownloadStatus.success)
            FadeTransition(
              key: const Key('fade_transition'),
              opacity: fadeController,
              child: Image.file(
                File(localPath!),
                key: const Key('media_image'),
                width: width,
                height: height,
                fit: BoxFit.cover,
                cacheWidth: width?.toInt(),
                cacheHeight: height?.toInt(),
              ),
            ),
        ],
      ),
    );
  }
}
