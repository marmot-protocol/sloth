import 'package:flutter/material.dart';

typedef ThemeColors = ({Color primary, Color secondary, Color tertiary});

const ThemeColors lightColors = (
  primary: Color(0xFFFAFAFA),
  secondary: Color(0xFF0A0A0A),
  tertiary: Color(0xFF737373),
);

const ThemeColors darkColors = (
  primary: Color(0xFF171717),
  secondary: Color(0xFFFAFAFA),
  tertiary: Color(0xFF737373),
);

extension ThemeExtension on BuildContext {
  ThemeColors get colors => Theme.of(this).brightness == Brightness.dark ? darkColors : lightColors;
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Manrope',
);
final darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Manrope',
);
