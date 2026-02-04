import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';

enum WnTooltipPosition { top, bottom }

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
  });

  final Widget child;
  final String message;
  final Widget? content;
  final WnTooltipPosition position;
  final Duration waitDuration;
  final WnTooltipTriggerMode triggerMode;

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
          onTap: triggerMode == WnTooltipTriggerMode.tap ? showTooltip : null,
          onLongPress: triggerMode == WnTooltipTriggerMode.longPress ? showTooltip : null,
          child: child,
        ),
      ),
    );
  }
}

class _TooltipOverlay extends StatefulWidget {
  const _TooltipOverlay({
    required this.layerLink,
    required this.position,
    required this.targetSize,
    required this.targetGlobalPosition,
    required this.colors,
    required this.onDismiss,
    required this.child,
  });

  final LayerLink layerLink;
  final WnTooltipPosition position;
  final Size targetSize;
  final Offset targetGlobalPosition;
  final SemanticColors colors;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  State<_TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<_TooltipOverlay> with SingleTickerProviderStateMixin {
  final GlobalKey _contentKey = GlobalKey();
  double _arrowOffset = 0;
  double _horizontalShift = 0;
  bool _isPositioned = false;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateShift();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateShift() {
    final contentRenderBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (contentRenderBox == null) return;

    final contentSize = contentRenderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 16.w;

    final targetCenterX = widget.targetGlobalPosition.dx + widget.targetSize.width / 2;
    final tooltipLeft = targetCenterX - contentSize.width / 2;
    final tooltipRight = targetCenterX + contentSize.width / 2;

    double shift = 0;

    final wouldOverflowLeft = tooltipLeft < padding;
    final wouldOverflowRight = tooltipRight > screenWidth - padding;

    if (wouldOverflowLeft || wouldOverflowRight) {
      final screenCenterX = screenWidth / 2;
      shift = screenCenterX - targetCenterX;
    }

    setState(() {
      _horizontalShift = shift;
      _arrowOffset = -shift;
      _isPositioned = true;
    });
    _animationController.forward();
  }

  Offset _getOffset() {
    final arrowHeight = 6.h;

    return switch (widget.position) {
      WnTooltipPosition.top => Offset(
        widget.targetSize.width / 2 + _horizontalShift,
        -arrowHeight,
      ),
      WnTooltipPosition.bottom => Offset(
        widget.targetSize.width / 2 + _horizontalShift,
        widget.targetSize.height + arrowHeight,
      ),
    };
  }

  Alignment _getFollowerAnchor() {
    return switch (widget.position) {
      WnTooltipPosition.top => Alignment.bottomCenter,
      WnTooltipPosition.bottom => Alignment.topCenter,
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.translucent,
          ),
        ),
        CompositedTransformFollower(
          link: widget.layerLink,
          offset: _getOffset(),
          followerAnchor: _getFollowerAnchor(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Opacity(
              opacity: _isPositioned ? 1.0 : 0.0,
              child: Material(
                color: Colors.transparent,
                child: _TooltipContent(
                  key: _contentKey,
                  position: widget.position,
                  colors: widget.colors,
                  arrowOffset: _arrowOffset,
                  screenWidth: screenWidth,
                  child: widget.child,
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
    required this.screenWidth,
    this.arrowOffset = 0,
  });

  final WnTooltipPosition position;
  final SemanticColors colors;
  final Widget child;
  final double arrowOffset;
  final double screenWidth;

  static final double _horizontalPadding = 16.w;

  @override
  Widget build(BuildContext context) {
    final arrowWidget = Transform.translate(
      offset: Offset(arrowOffset, 0),
      child: _TooltipArrow(
        key: const Key('tooltip_arrow'),
        position: position,
        color: colors.fillPrimary,
      ),
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
    final maxWidth = screenWidth - (_horizontalPadding * 2);

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
