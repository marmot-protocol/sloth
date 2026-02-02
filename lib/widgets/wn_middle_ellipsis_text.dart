import 'package:flutter/material.dart';

const _ellipsis = ' ... ';

class WnMiddleEllipsisText extends StatelessWidget {
  const WnMiddleEllipsisText({
    super.key,
    required this.text,
    this.style,
    this.maxLines = 1,
    this.suffixLength = 8,
  }) : assert(suffixLength >= 0);

  final String text;
  final TextStyle? style;
  final int maxLines;
  final int suffixLength;

  bool _fitsInMaxLines(
    String candidate,
    double maxWidth,
    TextStyle effectiveStyle,
    TextScaler textScaler,
    TextDirection textDirection,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: candidate, style: effectiveStyle),
      maxLines: maxLines,
      textDirection: textDirection,
      textScaler: textScaler,
    );
    try {
      painter.layout(maxWidth: maxWidth);
      return !painter.didExceedMaxLines;
    } finally {
      painter.dispose();
    }
  }

  String _computeDisplayText(
    double maxWidth,
    TextStyle effectiveStyle,
    TextScaler textScaler,
    TextDirection textDirection,
  ) {
    if (_fitsInMaxLines(text, maxWidth, effectiveStyle, textScaler, textDirection)) return text;

    final effectiveSuffixLength = suffixLength.clamp(0, text.length);
    final suffix = text.length > effectiveSuffixLength
        ? text.substring(text.length - effectiveSuffixLength)
        : '';
    final maxPrefixEnd = text.length - effectiveSuffixLength - 1;

    if (maxPrefixEnd <= 0) return '$_ellipsis$suffix';

    var lowPrefixEnd = 0;
    var highPrefixEnd = maxPrefixEnd;
    var bestPrefix = '';

    while (lowPrefixEnd <= highPrefixEnd) {
      final midPrefixEnd = (lowPrefixEnd + highPrefixEnd) ~/ 2;
      final prefix = text.substring(0, midPrefixEnd);
      final candidate = '$prefix$_ellipsis$suffix';

      if (_fitsInMaxLines(candidate, maxWidth, effectiveStyle, textScaler, textDirection)) {
        bestPrefix = prefix;
        lowPrefixEnd = midPrefixEnd + 1;
      } else {
        highPrefixEnd = midPrefixEnd - 1;
      }
    }

    final result = bestPrefix.isEmpty ? '$_ellipsis$suffix' : '$bestPrefix$_ellipsis$suffix';
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final effectiveStyle = style != null
            ? DefaultTextStyle.of(context).style.merge(style)
            : DefaultTextStyle.of(context).style;
        final textScaler = MediaQuery.textScalerOf(context);
        final textDirection = Directionality.of(context);
        final displayText = _computeDisplayText(
          maxWidth,
          effectiveStyle,
          textScaler,
          textDirection,
        );
        return Text(
          displayText,
          style: style,
          maxLines: maxLines,
        );
      },
    );
  }
}
