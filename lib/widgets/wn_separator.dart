import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';

enum WnSeparatorOrientation { horizontal, vertical }

class WnSeparator extends StatelessWidget {
  const WnSeparator({
    super.key,
    this.orientation = WnSeparatorOrientation.horizontal,
    this.thickness = 1.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.color,
  });

  final WnSeparatorOrientation orientation;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final separatorColor = color ?? colors.borderTertiary;

    return switch (orientation) {
      WnSeparatorOrientation.horizontal => _buildHorizontal(separatorColor),
      WnSeparatorOrientation.vertical => _buildVertical(separatorColor),
    };
  }

  Widget _buildHorizontal(Color separatorColor) {
    return Container(
      height: thickness,
      margin: EdgeInsets.only(left: indent, right: endIndent),
      color: separatorColor,
    );
  }

  Widget _buildVertical(Color separatorColor) {
    return Container(
      width: thickness,
      margin: EdgeInsets.only(top: indent, bottom: endIndent),
      color: separatorColor,
    );
  }
}
