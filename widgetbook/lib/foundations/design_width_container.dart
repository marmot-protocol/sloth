import 'package:flutter/material.dart';

const designWidth = 390.0;

class DesignWidthContainer extends StatelessWidget {
  const DesignWidthContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: designWidth),
      child: child,
    );
  }
}
