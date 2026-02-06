import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whitenoise/l10n/l10n.dart';
import 'package:whitenoise/theme.dart';

class WnChatList extends HookWidget {
  const WnChatList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.isLoading = false,
    this.topPadding = 0,
    this.header,
    this.headerHeight = 0,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final bool isLoading;
  final double topPadding;
  final Widget? header;
  final double headerHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canScrollUp = useState(false);
    final hasHeader = header != null && headerHeight > 0;
    final headerReveal = useState(0.0);
    final headerOpen = useState(false);
    final peakReveal = useRef(0.0);
    final scrollController = useScrollController();

    if (isLoading && itemCount == 0) {
      return Center(
        key: const Key('chat_list_loading'),
        child: CircularProgressIndicator(color: colors.backgroundContentPrimary),
      );
    }

    if (itemCount == 0) {
      final typography = context.typographyScaled;
      return Center(
        key: const Key('chat_list_empty'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.noChatsYet,
              style: typography.medium18.copyWith(color: colors.backgroundContentPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              context.l10n.startConversation,
              style: typography.medium14.copyWith(color: colors.backgroundContentTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    void updateScrollState(ScrollMetrics metrics) {
      final newValue = metrics.extentBefore > 0;
      if (canScrollUp.value == newValue) return;
      if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          canScrollUp.value = newValue;
        });
      } else {
        canScrollUp.value = newValue;
      }
    }

    bool handleScrollNotification(ScrollNotification notification) {
      updateScrollState(notification.metrics);

      if (!hasHeader) return false;

      if (headerOpen.value) {
        if (notification is UserScrollNotification &&
            notification.direction == ScrollDirection.reverse) {
          headerOpen.value = false;
          headerReveal.value = 0.0;
        }
        return false;
      }

      if (notification is ScrollUpdateNotification) {
        final pixels = notification.metrics.pixels;
        if (pixels < 0) {
          final reveal = (-pixels / headerHeight).clamp(0.0, 1.0);
          headerReveal.value = reveal;
          if (reveal > peakReveal.value) {
            peakReveal.value = reveal;
          }
          if (peakReveal.value >= 0.5 && notification.dragDetails != null) {
            headerOpen.value = true;
            headerReveal.value = 1.0;
            peakReveal.value = 0.0;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!scrollController.hasClients) return;
              scrollController.jumpTo(0);
            });
            return false;
          }
        } else if (headerReveal.value > 0) {
          headerReveal.value = 0.0;
        }
      }

      if (notification is ScrollEndNotification) {
        if (notification.metrics.pixels < 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!scrollController.hasClients) return;
            scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
            headerReveal.value = 0.0;
          });
        }
        peakReveal.value = 0.0;
      }

      return false;
    }

    final headerOffset = hasHeader && headerOpen.value ? headerHeight : 0.0;

    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) {
        updateScrollState(notification.metrics);
        return false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: handleScrollNotification,
        child: Stack(
          children: [
            ListView.builder(
              key: const Key('chat_list'),
              controller: scrollController,
              padding: EdgeInsets.only(
                top: topPadding + headerOffset + 16.h,
                left: 10.w,
                right: 10.w,
              ),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            ),
            if (hasHeader && (headerOpen.value || headerReveal.value > 0))
              Positioned(
                key: const Key('chat_list_header'),
                top: topPadding,
                left: 10.w,
                right: 10.w,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: headerReveal.value.clamp(0.0, 1.0),
                    child: header,
                  ),
                ),
              ),
            if (canScrollUp.value)
              Positioned(
                key: const Key('chat_list_scroll_edge'),
                top: 0,
                left: 0,
                right: 0,
                height: topPadding,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.backgroundPrimary,
                          colors.backgroundPrimary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
