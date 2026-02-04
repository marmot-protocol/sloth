import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';

enum WnTooltipPosition { top, bottom, left, right }

enum WnTooltipTriggerMode { tap, longPress }

class WnTooltip extends HookWidget {
  const WnTooltip({
    super.key,
    required this.child,
    required this.message,
    this.content,
    this.position = WnTooltipPosition.top,
    this.waitDuration = const Duration(milliseconds: 400),
    this.triggerMode = WnTooltipTriggerMode.tap,
    this.showArrow = true,
  });

  final Widget child;
  final String message;
  final Widget? content;
  final WnTooltipPosition position;
  final Duration waitDuration;
  final WnTooltipTriggerMode triggerMode;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final overlayEntryRef = useRef<OverlayEntry?>(null);
    final isHovering = useState(false);
    final isVisible = useState(false);
    final dismissedWhileHovering = useState(false);
    final layerLink = useMemoized(() => LayerLink());

    void hideTooltip({bool fromDismiss = false}) {
      overlayEntryRef.value?.remove();
      overlayEntryRef.value = null;
      isVisible.value = false;
      if (fromDismiss && isHovering.value) {
        dismissedWhileHovering.value = true;
      }
    }

    void showTooltip() {
      if (overlayEntryRef.value != null) return;

      final overlay = Overlay.of(context);
      final renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      final targetGlobalPosition = renderBox.localToGlobal(Offset.zero);

      final entry = OverlayEntry(
        builder: (context) => _TooltipOverlay(
          layerLink: layerLink,
          position: position,
          targetSize: size,
          targetGlobalPosition: targetGlobalPosition,
          colors: colors,
          onDismiss: () => hideTooltip(fromDismiss: true),
          showArrow: showArrow,
          child: content ?? Text(message, style: TextStyle(fontSize: 14.sp)),
        ),
      );

      overlayEntryRef.value = entry;
      overlay.insert(entry);
      isVisible.value = true;
    }

    useEffect(() {
      return () {
        overlayEntryRef.value?.remove();
        overlayEntryRef.value = null;
      };
    }, const []);

    useEffect(() {
      if (isHovering.value && !isVisible.value && !dismissedWhileHovering.value) {
        final timer = Timer(waitDuration, () {
          if (isHovering.value && !isVisible.value && !dismissedWhileHovering.value) {
            showTooltip();
          }
        });
        return timer.cancel;
      }
      return null;
    }, [isHovering.value, isVisible.value, dismissedWhileHovering.value]);

    return CompositedTransformTarget(
      link: layerLink,
      child: MouseRegion(
        onEnter: (_) => isHovering.value = true,
        onExit: (_) {
          isHovering.value = false;
          dismissedWhileHovering.value = false;
          hideTooltip();
        },
        child: GestureDetector(
          onTap: triggerMode == WnTooltipTriggerMode.tap
              ? () {
                  dismissedWhileHovering.value = false;
                  showTooltip();
                }
              : null,
          onLongPress: () {
            dismissedWhileHovering.value = false;
            showTooltip();
          },
          child: child,
        ),
      ),
    );
  }
}

class _TooltipOverlay extends HookWidget {
  const _TooltipOverlay({
    required this.layerLink,
    required this.position,
    required this.targetSize,
    required this.targetGlobalPosition,
    required this.colors,
    required this.onDismiss,
    required this.child,
    required this.showArrow,
  });

  final LayerLink layerLink;
  final WnTooltipPosition position;
  final Size targetSize;
  final Offset targetGlobalPosition;
  final SemanticColors colors;
  final VoidCallback onDismiss;
  final Widget child;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final contentKey = useMemoized(() => GlobalKey());
    final arrowOffset = useState(0.0);
    final shift = useState(0.0);
    final isPositioned = useState(false);
    final mountedRef = useRef(true);

    useEffect(() {
      mountedRef.value = true;
      return () => mountedRef.value = false;
    }, const []);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
    );
    final fadeAnimation = useMemoized(
      () => CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      [animationController],
    );

    void calculateShift() {
      if (!mountedRef.value) return;

      final contentRenderBox = contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (contentRenderBox == null) return;

      final contentSize = contentRenderBox.size;
      final screenSize = MediaQuery.of(context).size;
      final horizontalPadding = 16.w;
      final verticalPadding = 16.h;

      double newShift = 0;

      if (position == WnTooltipPosition.top || position == WnTooltipPosition.bottom) {
        final targetCenterX = targetGlobalPosition.dx + targetSize.width / 2;
        final tooltipLeft = targetCenterX - contentSize.width / 2;
        final tooltipRight = targetCenterX + contentSize.width / 2;

        final wouldOverflowLeft = tooltipLeft < horizontalPadding;
        final wouldOverflowRight = tooltipRight > screenSize.width - horizontalPadding;

        if (wouldOverflowLeft || wouldOverflowRight) {
          final screenCenterX = screenSize.width / 2;
          newShift = screenCenterX - targetCenterX;
        }
      } else {
        final targetCenterY = targetGlobalPosition.dy + targetSize.height / 2;
        final tooltipTop = targetCenterY - contentSize.height / 2;
        final tooltipBottom = targetCenterY + contentSize.height / 2;

        final wouldOverflowTop = tooltipTop < verticalPadding;
        final wouldOverflowBottom = tooltipBottom > screenSize.height - verticalPadding;

        if (wouldOverflowTop || wouldOverflowBottom) {
          final screenCenterY = screenSize.height / 2;
          newShift = screenCenterY - targetCenterY;
        }
      }

      if (!mountedRef.value) return;

      shift.value = newShift;
      arrowOffset.value = -newShift;
      isPositioned.value = true;
      animationController.forward();
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mountedRef.value) {
          calculateShift();
        }
      });
      return null;
    }, const []);

    final screenSize = MediaQuery.of(context).size;

    Offset getOffset() {
      final arrowHeight = showArrow ? 6.h : 0.0;
      final arrowWidth = showArrow ? 6.w : 0.0;

      return switch (position) {
        WnTooltipPosition.top => Offset(
          targetSize.width / 2 + shift.value,
          -arrowHeight,
        ),
        WnTooltipPosition.bottom => Offset(
          targetSize.width / 2 + shift.value,
          targetSize.height + arrowHeight,
        ),
        WnTooltipPosition.left => Offset(
          -arrowWidth,
          targetSize.height / 2 + shift.value,
        ),
        WnTooltipPosition.right => Offset(
          targetSize.width + arrowWidth,
          targetSize.height / 2 + shift.value,
        ),
      };
    }

    Alignment getFollowerAnchor() {
      return switch (position) {
        WnTooltipPosition.top => Alignment.bottomCenter,
        WnTooltipPosition.bottom => Alignment.topCenter,
        WnTooltipPosition.left => Alignment.centerRight,
        WnTooltipPosition.right => Alignment.centerLeft,
      };
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.translucent,
          ),
        ),
        CompositedTransformFollower(
          link: layerLink,
          offset: getOffset(),
          followerAnchor: getFollowerAnchor(),
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Opacity(
              opacity: isPositioned.value ? 1.0 : 0.0,
              child: Material(
                color: Colors.transparent,
                child: _TooltipContent(
                  key: contentKey,
                  position: position,
                  colors: colors,
                  arrowOffset: arrowOffset.value,
                  screenSize: screenSize,
                  showArrow: showArrow,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TooltipContent extends StatelessWidget {
  const _TooltipContent({
    super.key,
    required this.position,
    required this.colors,
    required this.child,
    required this.screenSize,
    required this.showArrow,
    this.arrowOffset = 0,
  });

  final WnTooltipPosition position;
  final SemanticColors colors;
  final Widget child;
  final double arrowOffset;
  final Size screenSize;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = 16.w;
    final isVertical = position == WnTooltipPosition.top || position == WnTooltipPosition.bottom;

    Widget? arrowWidget;
    if (showArrow) {
      arrowWidget = Transform.translate(
        offset: isVertical ? Offset(arrowOffset, 0) : Offset(0, arrowOffset),
        child: _TooltipArrow(
          key: const Key('tooltip_arrow'),
          position: position,
          color: colors.fillPrimary,
        ),
      );
    }

    final contentBox = _buildContentBox(horizontalPadding);

    return switch (position) {
      WnTooltipPosition.top => Column(
        mainAxisSize: MainAxisSize.min,
        children: [contentBox, if (arrowWidget != null) arrowWidget],
      ),
      WnTooltipPosition.bottom => Column(
        mainAxisSize: MainAxisSize.min,
        children: [if (arrowWidget != null) arrowWidget, contentBox],
      ),
      WnTooltipPosition.left => Row(
        mainAxisSize: MainAxisSize.min,
        children: [contentBox, if (arrowWidget != null) arrowWidget],
      ),
      WnTooltipPosition.right => Row(
        mainAxisSize: MainAxisSize.min,
        children: [if (arrowWidget != null) arrowWidget, contentBox],
      ),
    };
  }

  Widget _buildContentBox(double horizontalPadding) {
    final maxWidth = screenSize.width - (horizontalPadding * 2);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        key: const Key('tooltip_content'),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: colors.fillPrimary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: DefaultTextStyle(
            style: TextStyle(
              color: colors.fillContentPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              height: 18 / 14,
              letterSpacing: 0.4.sp,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _TooltipArrow extends StatelessWidget {
  const _TooltipArrow({
    super.key,
    required this.position,
    required this.color,
  });

  final WnTooltipPosition position;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isVertical = position == WnTooltipPosition.top || position == WnTooltipPosition.bottom;
    return CustomPaint(
      size: isVertical ? Size(13.w, 6.h) : Size(6.w, 13.h),
      painter: ArrowPainter(position: position, color: color),
    );
  }
}

@visibleForTesting
class ArrowPainter extends CustomPainter {
  ArrowPainter({required this.position, required this.color});

  final WnTooltipPosition position;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    switch (position) {
      case WnTooltipPosition.top:
        path.moveTo(0, 0);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(size.width, 0);
        break;
      case WnTooltipPosition.bottom:
        path.moveTo(0, size.height);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        break;
      case WnTooltipPosition.left:
        path.moveTo(0, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        break;
      case WnTooltipPosition.right:
        path.moveTo(size.width, 0);
        path.lineTo(0, size.height / 2);
        path.lineTo(size.width, size.height);
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.color != color;
  }
}
