import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_icon.dart';

const _animationDuration = Duration(milliseconds: 150);

class WnChatListContextMenuAction {
  final String id;
  final String label;
  final WnIcons icon;
  final VoidCallback? onTap;
  final bool isDestructive;

  const WnChatListContextMenuAction({
    required this.id,
    required this.label,
    required this.icon,
    this.onTap,
    this.isDestructive = false,
  });
}

class WnChatListContextMenuController {
  OverlayEntry? _entry;
  Future<void> Function()? _animatedDismiss;
  bool _dismissing = false;

  bool get isShowing => _entry != null;

  void dismiss() {
    if (_dismissing) return;

    final animatedDismiss = _animatedDismiss;
    if (animatedDismiss != null) {
      _dismissing = true;
      _animatedDismiss = null;
      animatedDismiss().then((_) {
        _entry?.remove();
        _entry = null;
        _dismissing = false;
      });
    } else {
      _entry?.remove();
      _entry = null;
    }
  }

  void dispose() {
    _animatedDismiss = null;
    _entry?.remove();
    _entry = null;
    _dismissing = false;
  }
}

class WnChatListContextMenu extends HookWidget {
  const WnChatListContextMenu({
    super.key,
    required this.child,
    required this.itemPosition,
    required this.itemHeight,
    required this.actions,
    required this.onDismiss,
    required this.controller,
  });

  final Widget child;
  final Offset itemPosition;
  final double itemHeight;
  final List<WnChatListContextMenuAction> actions;
  final VoidCallback onDismiss;
  final WnChatListContextMenuController controller;

  static WnChatListContextMenuController show(
    BuildContext context, {
    required Widget child,
    required RenderBox childRenderBox,
    required List<WnChatListContextMenuAction> actions,
  }) {
    final menuController = WnChatListContextMenuController();

    final position = childRenderBox.localToGlobal(Offset.zero);
    final height = childRenderBox.size.height;
    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (_) => WnChatListContextMenu(
        itemPosition: position,
        itemHeight: height,
        actions: actions,
        onDismiss: () => menuController.dismiss(),
        controller: menuController,
        child: child,
      ),
    );

    menuController._entry = entry;
    overlay.insert(entry);

    return menuController;
  }

  static void dismiss() {
    // No-op kept for backward compatibility in tests that call tearDown.
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typographyScaled;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final safeTop = mediaQuery.padding.top;
    final safeBottom = mediaQuery.padding.bottom;

    final menuPadding = 16.w;
    final buttonHeight = 44.h;
    final buttonSpacing = 8.h;
    final containerGap = 12.h;
    final menuHorizontalInset = 10.w;

    final totalButtonsHeight =
        (buttonHeight * actions.length) + (buttonSpacing * (actions.length - 1));
    final menuContentHeight =
        menuPadding + itemHeight + containerGap + totalButtonsHeight + menuPadding;

    final idealTop = itemPosition.dy - menuPadding;
    final minTop = safeTop;
    final maxTop = (screenHeight - safeBottom - menuContentHeight).clamp(minTop, double.infinity);
    final clampedTop = idealTop.clamp(minTop, maxTop);

    final menuWidth = screenWidth - (menuHorizontalInset * 2);
    final itemCenterInMenu = menuPadding + (itemHeight / 2);
    final alignX = (itemPosition.dx - menuHorizontalInset) / menuWidth;
    final alignY = (itemCenterInMenu / menuContentHeight) * 2 - 1;

    final animController = useAnimationController(duration: _animationDuration);
    final curvedAnimation = useMemoized(
      () => CurvedAnimation(parent: animController, curve: Curves.easeOut),
      [animController],
    );

    useEffect(() {
      animController.forward();
      controller._animatedDismiss = () => animController.reverse();
      return () {
        controller._animatedDismiss = null;
        curvedAnimation.dispose();
      };
    }, const []);

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        key: const Key('context_menu_dismiss'),
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        onVerticalDragStart: (_) => onDismiss(),
        child: Stack(
          children: [
            Positioned.fill(
              child: FadeTransition(
                opacity: curvedAnimation,
                child: BackdropFilter(
                  key: const Key('context_menu_overlay'),
                  filter: ImageFilter.blur(sigmaX: 10.0.r, sigmaY: 10.0.r),
                  child: ColoredBox(color: colors.overlaySecondary),
                ),
              ),
            ),
            Positioned(
              top: clampedTop,
              left: menuHorizontalInset,
              right: menuHorizontalInset,
              child: FadeTransition(
                opacity: curvedAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
                  alignment: Alignment(alignX.clamp(-1.0, 1.0), alignY.clamp(-1.0, 1.0)),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      key: const Key('context_menu_card'),
                      decoration: BoxDecoration(
                        color: colors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: colors.borderTertiary),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.1),
                            offset: const Offset(0, 1),
                            blurRadius: 2.r,
                            spreadRadius: (-1).r,
                          ),
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.1),
                            offset: const Offset(0, 1),
                            blurRadius: 3.r,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(menuPadding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: colors.backgroundPrimary,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: colors.borderTertiary),
                            ),
                            child: IgnorePointer(child: child),
                          ),
                          SizedBox(height: containerGap),
                          ...List.generate(actions.length, (index) {
                            final action = actions[index];

                            return Padding(
                              padding: EdgeInsets.only(top: index > 0 ? buttonSpacing : 0),
                              child: _ContextMenuButton(
                                key: Key('context_menu_action_${action.id}'),
                                label: action.label,
                                icon: action.icon,
                                isDestructive: action.isDestructive,
                                onTap: action.onTap != null
                                    ? () {
                                        onDismiss();
                                        action.onTap!();
                                      }
                                    : null,
                                colors: colors,
                                typography: typography,
                              ),
                            );
                          }),
                        ],
                      ),
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

class _ContextMenuButton extends StatelessWidget {
  const _ContextMenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isDestructive,
    this.onTap,
    required this.colors,
    required this.typography,
  });

  final String label;
  final WnIcons icon;
  final bool isDestructive;
  final VoidCallback? onTap;
  final SemanticColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDestructive ? colors.fillDestructive : colors.fillSecondary;
    final contentColor = isDestructive
        ? colors.fillContentDestructive
        : colors.fillContentSecondary;
    final borderSide = isDestructive ? BorderSide.none : BorderSide(color: colors.borderTertiary);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.fromBorderSide(borderSide),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: typography.medium14.copyWith(color: contentColor),
            ),
            SizedBox(width: 4.w),
            WnIcon(
              icon,
              size: 18.w,
              color: contentColor,
            ),
          ],
        ),
      ),
    );
  }
}
