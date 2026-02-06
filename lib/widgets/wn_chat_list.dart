import 'package:flutter/material.dart';
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
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final bool isLoading;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    if (isLoading && itemCount == 0) {
      return _buildLoading(context);
    }

    if (itemCount == 0) {
      return _buildEmpty(context);
    }

    return _buildList(context);
  }

  Widget _buildLoading(BuildContext context) {
    final colors = context.colors;
    return Center(
      key: const Key('chat_list_loading'),
      child: CircularProgressIndicator(color: colors.backgroundContentPrimary),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colors = context.colors;
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

  Widget _buildList(BuildContext context) {
    final colors = context.colors;
    final canScrollUp = useState(false);

    void updateScrollState(ScrollMetrics metrics) {
      canScrollUp.value = metrics.extentBefore > 0;
    }

    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) {
        updateScrollState(notification.metrics);
        return false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          updateScrollState(notification.metrics);
          return false;
        },
        child: Stack(
          children: [
            ListView.builder(
              key: const Key('chat_list'),
              padding: EdgeInsets.only(
                top: topPadding + 16.h,
                left: 10.w,
                right: 10.w,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
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
