import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';

enum WnTooltipPosition { top, bottom }

class WnTooltip extends HookWidget {
  const WnTooltip({
    super.key,
    required this.child,
    required this.message,
    this.content,
    this.position = WnTooltipPosition.top,
    this.waitDuration = const Duration(milliseconds: 400),
  });

  final Widget child;
  final String message;
  final Widget? content;
  final WnTooltipPosition position;
  final Duration waitDuration;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final overlayEntryRef = useRef<OverlayEntry?>(null);
    final isHovering = useState(false);
    final isVisible = useState(false);
    final wasDismissed = useState(false);
    final layerLink = useMemoized(() => LayerLink());

    void hideTooltip({bool dismissed = false}) {
      overlayEntryRef.value?.remove();
      overlayEntryRef.value = null;
      isVisible.value = false;
      if (dismissed) {
        wasDismissed.value = true;
      }
    }

    void showTooltip() {
      if (overlayEntryRef.value != null) return;
      if (wasDismissed.value) return;

      final overlay = Overlay.of(context);
      final renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;

      final entry = OverlayEntry(
        builder: (context) => _TooltipOverlay(
          layerLink: layerLink,
          position: position,
          targetSize: size,
          colors: colors,
          onDismiss: () => hideTooltip(dismissed: true),
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
      if (isHovering.value && !isVisible.value && !wasDismissed.value) {
        final timer = Timer(waitDuration, () {
          if (isHovering.value && !isVisible.value && !wasDismissed.value) {
            showTooltip();
          }
        });
        return timer.cancel;
      }
      return null;
    }, [isHovering.value, isVisible.value, wasDismissed.value]);

    return CompositedTransformTarget(
      link: layerLink,
      child: MouseRegion(
        onEnter: (_) => isHovering.value = true,
        onExit: (_) {
          isHovering.value = false;
          wasDismissed.value = false;
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
    required this.targetSize,
    required this.colors,
    required this.onDismiss,
    required this.child,
  });

  final LayerLink layerLink;
  final WnTooltipPosition position;
  final Size targetSize;
  final SemanticColors colors;
  final VoidCallback onDismiss;
  final Widget child;

  Offset _getOffset() {
    final arrowHeight = 6.h;

    return switch (position) {
      WnTooltipPosition.top => Offset(targetSize.width / 2, -arrowHeight),
      WnTooltipPosition.bottom => Offset(
        targetSize.width / 2,
        targetSize.height + arrowHeight,
      ),
    };
  }

  Alignment _getFollowerAnchor() {
    return switch (position) {
      WnTooltipPosition.top => Alignment.bottomCenter,
      WnTooltipPosition.bottom => Alignment.topCenter,
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
    required this.colors,
    required this.child,
  });

  final WnTooltipPosition position;
  final SemanticColors colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final arrowWidget = _TooltipArrow(
      key: const Key('tooltip_arrow'),
      position: position,
      color: colors.fillPrimary,
    );

    return switch (position) {
      WnTooltipPosition.top => Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildContentBox(), arrowWidget],
      ),
      WnTooltipPosition.bottom => Column(
        mainAxisSize: MainAxisSize.min,
        children: [arrowWidget, _buildContentBox()],
      ),
    };
  }

  Widget _buildContentBox() {
    return Container(
      key: const Key('tooltip_content'),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: colors.fillPrimary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.w),
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
      size: Size(13.w, 6.h),
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
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.color != color;
  }
}
