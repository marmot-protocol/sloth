import 'package:flutter/material.dart';

import 'theme/app_typography.dart';
import 'theme/semantic_colors.dart';

export 'theme/app_typography.dart';
export 'theme/semantic_colors.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Manrope',
  extensions: const [SemanticColors.light, AppTypography.instance],
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Manrope',
  extensions: const [SemanticColors.dark, AppTypography.instance],
);
