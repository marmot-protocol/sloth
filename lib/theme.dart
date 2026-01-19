import 'package:flutter/material.dart';

typedef ThemeColors = ({
  Color backgroundPrimary,
  Color backgroundSecondary,
  Color backgroundTertiary,
  Color foregroundPrimary,
  Color foregroundSecondary,
  Color foregroundTertiary,
  Color shadow,
  Color error,
  Color success,
});

const ThemeColors lightColors = (
  backgroundPrimary: Color(0xFFFFFFFF),
  backgroundSecondary: Color(0xFF0A0A0A),
  backgroundTertiary: Color(0xFFFAFAFA),
  foregroundPrimary: Color(0xFF0A0A0A),
  foregroundSecondary: Color(0xFFFFFFFF),
  foregroundTertiary: Color(0xFF737373),
  shadow: Color(0x0A0D120F),
  error: Color(0xffB91C1C),
  success: Color(0xFF22C55E),
);

const ThemeColors darkColors = (
  backgroundPrimary: Color(0xFF0A0A0A),
  backgroundSecondary: Color(0xFFFFFFFF),
  backgroundTertiary: Color(0xFF171717),
  foregroundPrimary: Color(0xFFFFFFFF),
  foregroundSecondary: Color(0xFF0A0A0A),
  foregroundTertiary: Color(0xFF737373),
  shadow: Color(0xFFFAFAFA),
  error: Color(0xffB91C1C),
  success: Color(0xFF22C55E),
);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Manrope',
);
final darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Manrope',
);
