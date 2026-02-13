import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:whitenoise/src/rust/api/media_files.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_media_tile.dart';

class WnMessageMedia extends StatelessWidget {
  final List<MediaFile> mediaFiles;
  final ValueChanged<int>? onMediaTap;

  const WnMessageMedia({super.key, required this.mediaFiles, this.onMediaTap});

  @override
  Widget build(BuildContext context) {
    if (mediaFiles.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;

    return switch (mediaFiles.length) {
      1 => _buildOneLayout(),
      2 => _buildTwoLayout(),
      3 => _buildThreeLayout(),
      4 => _buildFourLayout(),
      5 => _buildFiveLayout(),
      _ => _buildSixPlusLayout(colors),
    };
  }

  Widget _buildOneLayout() {
    return AspectRatio(
      key: const Key('one_layout'),
      aspectRatio: 1,
      child: _TappableMediaTile(
        mediaFile: mediaFiles[0],
        index: 0,
        onTap: onMediaTap,
      ),
    );
  }

  Widget _buildTwoLayout() {
    return IntrinsicHeight(
      key: const Key('two_layout'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: _TappableMediaTile(
                mediaFile: mediaFiles[0],
                index: 0,
                onTap: onMediaTap,
              ),
            ),
          ),
          Gap(4.w),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: _TappableMediaTile(
                mediaFile: mediaFiles[1],
                index: 1,
                onTap: onMediaTap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeLayout() {
    return IntrinsicHeight(
      key: const Key('three_layout'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: _TappableMediaTile(
                mediaFile: mediaFiles[0],
                index: 0,
                onTap: onMediaTap,
              ),
            ),
          ),
          Gap(4.w),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: _TappableMediaTile(
                mediaFile: mediaFiles[1],
                index: 1,
                onTap: onMediaTap,
              ),
            ),
          ),
          Gap(4.w),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: _TappableMediaTile(
                mediaFile: mediaFiles[2],
                index: 2,
                onTap: onMediaTap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourLayout() {
    return Column(
      key: const Key('four_layout'),
      mainAxisSize: MainAxisSize.min,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _TappableMediaTile(
                    mediaFile: mediaFiles[0],
                    index: 0,
                    onTap: onMediaTap,
                  ),
                ),
              ),
              Gap(4.w),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _TappableMediaTile(
                    mediaFile: mediaFiles[1],
                    index: 1,
                    onTap: onMediaTap,
                  ),
                ),
              ),
            ],
          ),
        ),
        Gap(4.h),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _TappableMediaTile(
                    mediaFile: mediaFiles[2],
                    index: 2,
                    onTap: onMediaTap,
                  ),
                ),
              ),
              Gap(4.w),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _TappableMediaTile(
                    mediaFile: mediaFiles[3],
                    index: 3,
                    onTap: onMediaTap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFiveLayout() {
    return Column(
      key: const Key('five_layout'),
      mainAxisSize: MainAxisSize.min,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _TappableMediaTile(
                    mediaFile: mediaFiles[0],
                    index: 0,
                    onTap: onMediaTap,
                  ),
                ),
              ),
              Gap(4.w),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _TappableMediaTile(
                    mediaFile: mediaFiles[1],
                    index: 1,
                    onTap: onMediaTap,
                  ),
                ),
              ),
              Gap(4.w),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _TappableMediaTile(
                    mediaFile: mediaFiles[2],
                    index: 2,
                    onTap: onMediaTap,
                  ),
                ),
              ),
            ],
          ),
        ),
        Gap(4.h),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _TappableMediaTile(
                    mediaFile: mediaFiles[3],
                    index: 3,
                    onTap: onMediaTap,
                  ),
                ),
              ),
              Gap(4.w),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _TappableMediaTile(
                    mediaFile: mediaFiles[4],
                    index: 4,
                    onTap: onMediaTap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSixPlusLayout(SemanticColors colors) {
    final overflowCount = mediaFiles.length - 6;

    return Column(
      key: const Key('six_plus_layout'),
      mainAxisSize: MainAxisSize.min,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _TappableMediaTile(
                    mediaFile: mediaFiles[0],
                    index: 0,
                    onTap: onMediaTap,
                  ),
                ),
              ),
              Gap(4.w),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _TappableMediaTile(
                    mediaFile: mediaFiles[1],
                    index: 1,
                    onTap: onMediaTap,
                  ),
                ),
              ),
              Gap(4.w),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _TappableMediaTile(
                    mediaFile: mediaFiles[2],
                    index: 2,
                    onTap: onMediaTap,
                  ),
                ),
              ),
            ],
          ),
        ),
        Gap(4.h),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _TappableMediaTile(
                    mediaFile: mediaFiles[3],
                    index: 3,
                    onTap: onMediaTap,
                  ),
                ),
              ),
              Gap(4.w),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _TappableMediaTile(
                    mediaFile: mediaFiles[4],
                    index: 4,
                    onTap: onMediaTap,
                  ),
                ),
              ),
              Gap(4.w),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _TappableMediaTile(
                        mediaFile: mediaFiles[5],
                        index: 5,
                        onTap: onMediaTap,
                      ),
                      if (overflowCount > 0)
                        IgnorePointer(
                          child: Container(
                            key: const Key('overflow_indicator'),
                            decoration: BoxDecoration(
                              color: colors.overlayTertiary,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Center(
                              child: Text(
                                '+$overflowCount',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  color: colors.fillContentQuaternary,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 24 / 18,
                                  letterSpacing: 0.1.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TappableMediaTile extends StatelessWidget {
  final MediaFile mediaFile;
  final int index;
  final ValueChanged<int>? onTap;

  const _TappableMediaTile({
    required this.mediaFile,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('tappable_media_tile_$index'),
      onTap: onTap != null ? () => onTap!(index) : null,
      child: WnMediaTile(mediaFile: mediaFile),
    );
  }
}
