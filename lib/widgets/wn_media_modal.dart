import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:whitenoise/l10n/l10n.dart';
import 'package:whitenoise/providers/locale_provider.dart';
import 'package:whitenoise/src/rust/api/media_files.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_avatar.dart';
import 'package:whitenoise/widgets/wn_media_image.dart';
import 'package:whitenoise/widgets/wn_media_thumbnail.dart';
import 'package:whitenoise/widgets/wn_slate.dart';

class WnMediaModal extends HookWidget {
  final List<MediaFile> mediaFiles;
  final int initialIndex;
  final String? senderName;
  final String? senderPictureUrl;
  final String? senderPubkey;
  final DateTime? timestamp;

  const WnMediaModal({
    super.key,
    required this.mediaFiles,
    this.initialIndex = 0,
    this.senderName,
    this.senderPictureUrl,
    this.senderPubkey,
    this.timestamp,
  });

  static Future<void> show({
    required BuildContext context,
    required List<MediaFile> mediaFiles,
    int initialIndex = 0,
    String? senderName,
    String? senderPictureUrl,
    String? senderPubkey,
    DateTime? timestamp,
  }) {
    return showDialog<void>(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black,
      builder: (_) => WnMediaModal(
        mediaFiles: mediaFiles,
        initialIndex: initialIndex,
        senderName: senderName,
        senderPictureUrl: senderPictureUrl,
        senderPubkey: senderPubkey,
        timestamp: timestamp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentIndex = useState(initialIndex);
    final isFullscreen = useState(false);
    final isZoomed = useState(false);
    final pageController = useMemoized(
      () => PageController(initialPage: initialIndex),
    );

    useEffect(() => pageController.dispose, [pageController]);

    final showOverlays = !isFullscreen.value && !isZoomed.value;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: WnSlate(
            key: const Key('media_modal_header'),
            animateContent: false,
            child: GestureDetector(
              onTap: () {
                if (!isZoomed.value) {
                  isFullscreen.value = !isFullscreen.value;
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    key: const Key('media_page_view'),
                    controller: pageController,
                    itemCount: mediaFiles.length,
                    physics: isZoomed.value
                        ? const NeverScrollableScrollPhysics()
                        : const PageScrollPhysics(),
                    onPageChanged: (index) => currentIndex.value = index,
                    itemBuilder: (_, index) {
                      return WnMediaImage(
                        key: Key('media_image_$index'),
                        mediaFile: mediaFiles[index],
                        onZoomChanged: (zoomed) => isZoomed.value = zoomed,
                      );
                    },
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: showOverlays ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !showOverlays,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: _HeaderContent(
                            senderName: senderName,
                            senderPictureUrl: senderPictureUrl,
                            senderPubkey: senderPubkey,
                            timestamp: timestamp,
                            onClose: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (mediaFiles.length > 1)
                    _ThumbnailStrip(
                      key: const Key('media_thumbnail_strip'),
                      visible: showOverlays,
                      mediaFiles: mediaFiles,
                      currentIndex: currentIndex.value,
                      colors: colors,
                      onThumbnailTap: (index) {
                        pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderContent extends ConsumerWidget {
  final String? senderName;
  final String? senderPictureUrl;
  final String? senderPubkey;
  final DateTime? timestamp;
  final VoidCallback onClose;

  const _HeaderContent({
    this.senderName,
    this.senderPictureUrl,
    this.senderPubkey,
    this.timestamp,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typographyScaled;
    final formatters = ref.watch(localeFormattersProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          GestureDetector(
            key: const Key('media_modal_close'),
            onTap: onClose,
            child: Icon(
              Icons.close,
              color: colors.backgroundContentPrimary,
              size: 24.w,
            ),
          ),
          Gap(12.w),
          WnAvatar(
            pictureUrl: senderPictureUrl,
            displayName: senderName,
            color: senderPubkey != null
                ? AvatarColor.fromPubkey(senderPubkey!)
                : AvatarColor.neutral,
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  senderName ?? 'Unknown',
                  key: const Key('media_modal_sender_name'),
                  style: typography.semiBold14.copyWith(
                    color: colors.backgroundContentPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (timestamp != null)
                  Text(
                    formatters.formatRelativeTime(timestamp!, context.l10n),
                    key: const Key('media_modal_timestamp'),
                    style: typography.medium12.copyWith(
                      color: colors.backgroundContentTertiary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailStrip extends StatelessWidget {
  final bool visible;
  final List<MediaFile> mediaFiles;
  final int currentIndex;
  final SemanticColors colors;
  final ValueChanged<int> onThumbnailTap;

  const _ThumbnailStrip({
    super.key,
    required this.visible,
    required this.mediaFiles,
    required this.currentIndex,
    required this.colors,
    required this.onThumbnailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: visible ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !visible,
          child: Container(
            padding: EdgeInsets.only(
              top: 16.h,
              bottom: 16.h,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(mediaFiles.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: index < mediaFiles.length - 1 ? 8.w : 0),
                    child: WnMediaThumbnail(
                      key: Key('thumbnail_$index'),
                      mediaFile: mediaFiles[index],
                      isSelected: index == currentIndex,
                      onTap: () => onThumbnailTap(index),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
