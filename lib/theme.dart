import 'package:flutter/material.dart';

import 'theme/semantic_colors.dart';

export 'theme/semantic_colors.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Manrope',
  extensions: const [SemanticColors.light],
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Manrope',
  extensions: const [SemanticColors.dark],
);
