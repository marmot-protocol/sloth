import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';

enum WnTooltipPosition { top, bottom, left, right }

class WnTooltip extends HookWidget {
  const WnTooltip({
    super.key,
    required this.child,
    required this.message,
    this.content,
    this.position = WnTooltipPosition.top,
    this.showArrow = true,
    this.waitDuration = const Duration(milliseconds: 400),
  });

  final Widget child;
  final String message;
  final Widget? content;
  final WnTooltipPosition position;
  final bool showArrow;
  final Duration waitDuration;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final overlayEntryRef = useRef<OverlayEntry?>(null);
    final isHovering = useState(false);
    final isVisible = useState(false);
    final layerLink = useMemoized(() => LayerLink());

    void hideTooltip() {
      overlayEntryRef.value?.remove();
      overlayEntryRef.value = null;
      isVisible.value = false;
    }

    void showTooltip() {
      if (overlayEntryRef.value != null) return;

      final overlay = Overlay.of(context);
      final renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;

      final entry = OverlayEntry(
        builder: (context) => _TooltipOverlay(
          layerLink: layerLink,
          position: position,
          showArrow: showArrow,
          targetSize: size,
          colors: colors,
          onDismiss: hideTooltip,
          child: content ?? Text(message, style: TextStyle(fontSize: 12.sp)),
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
      if (isHovering.value && !isVisible.value) {
        final timer = Timer(waitDuration, () {
          if (isHovering.value && !isVisible.value) {
            showTooltip();
          }
        });
        return timer.cancel;
      }
      return null;
    }, [isHovering.value, isVisible.value]);

    return CompositedTransformTarget(
      link: layerLink,
      child: MouseRegion(
        onEnter: (_) => isHovering.value = true,
        onExit: (_) {
          isHovering.value = false;
          hideTooltip();
        },
        child: GestureDetector(
          onLongPress: showTooltip,
          child: child,
        ),
      ),
    );
  }
}

class _TooltipOverlay extends StatelessWidget {
  const _TooltipOverlay({
    required this.layerLink,
    required this.position,
    required this.showArrow,
    required this.targetSize,
    required this.colors,
    required this.onDismiss,
    required this.child,
  });

  final LayerLink layerLink;
  final WnTooltipPosition position;
  final bool showArrow;
  final Size targetSize;
  final SemanticColors colors;
  final VoidCallback onDismiss;
  final Widget child;

  Offset _getOffset() {
    final arrowSize = 6.w;
    final padding = 4.w;

    return switch (position) {
      WnTooltipPosition.top => Offset(
        targetSize.width / 2,
        -(arrowSize + padding),
      ),
      WnTooltipPosition.bottom => Offset(
        targetSize.width / 2,
        targetSize.height + arrowSize + padding,
      ),
      WnTooltipPosition.left => Offset(
        -(arrowSize + padding),
        targetSize.height / 2,
      ),
      WnTooltipPosition.right => Offset(
        targetSize.width + arrowSize + padding,
        targetSize.height / 2,
      ),
    };
  }

  Alignment _getFollowerAnchor() {
    return switch (position) {
      WnTooltipPosition.top => Alignment.bottomCenter,
      WnTooltipPosition.bottom => Alignment.topCenter,
      WnTooltipPosition.left => Alignment.centerRight,
      WnTooltipPosition.right => Alignment.centerLeft,
    };
  }

  @override
  Widget build(BuildContext context) {
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
          offset: _getOffset(),
          followerAnchor: _getFollowerAnchor(),
          child: Material(
            color: Colors.transparent,
            child: _TooltipContent(
              position: position,
              showArrow: showArrow,
              colors: colors,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _TooltipContent extends StatelessWidget {
  const _TooltipContent({
    required this.position,
    required this.showArrow,
    required this.colors,
    required this.child,
  });

  final WnTooltipPosition position;
  final bool showArrow;
  final SemanticColors colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final arrowWidget = showArrow
        ? _TooltipArrow(
            key: const Key('tooltip_arrow'),
            position: position,
            color: colors.backgroundTertiary,
          )
        : null;

    return switch (position) {
      WnTooltipPosition.top => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildContentBox(),
          if (arrowWidget != null) arrowWidget,
        ],
      ),
      WnTooltipPosition.bottom => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (arrowWidget != null) arrowWidget,
          _buildContentBox(),
        ],
      ),
      WnTooltipPosition.left => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildContentBox(),
          if (arrowWidget != null) arrowWidget,
        ],
      ),
      WnTooltipPosition.right => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (arrowWidget != null) arrowWidget,
          _buildContentBox(),
        ],
      ),
    };
  }

  Widget _buildContentBox() {
    return Container(
      key: const Key('tooltip_content'),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colors.backgroundTertiary,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: colors.backgroundContentPrimary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        child: child,
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
    return CustomPaint(
      size: Size(12.w, 6.w),
      painter: _ArrowPainter(position: position, color: color),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({
    required this.position,
    required this.color,
  });

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
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.color != color;
  }
}
