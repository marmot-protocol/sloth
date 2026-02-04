import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

TextStyle _scaleStyle(TextStyle style) {
  return style.copyWith(
    fontSize: style.fontSize?.sp,
    letterSpacing: style.letterSpacing?.sp,
  );
}

@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  final TextStyle medium96;
  final TextStyle semiBold96;
  final TextStyle bold96;
  final TextStyle medium72;
  final TextStyle semiBold72;
  final TextStyle bold72;
  final TextStyle medium60;
  final TextStyle semiBold60;
  final TextStyle bold60;
  final TextStyle medium48;
  final TextStyle semiBold48;
  final TextStyle bold48;
  final TextStyle medium36;
  final TextStyle semiBold36;
  final TextStyle bold36;
  final TextStyle medium32;
  final TextStyle semiBold32;
  final TextStyle bold32;
  final TextStyle medium28;
  final TextStyle semiBold28;
  final TextStyle bold28;
  final TextStyle medium24;
  final TextStyle semiBold24;
  final TextStyle bold24;
  final TextStyle medium20;
  final TextStyle semiBold20;
  final TextStyle bold20;
  final TextStyle medium18;
  final TextStyle semiBold18;
  final TextStyle bold18;
  final TextStyle medium16;
  final TextStyle semiBold16;
  final TextStyle bold16;
  final TextStyle medium14;
  final TextStyle semiBold14;
  final TextStyle bold14;
  final TextStyle medium14Compact;
  final TextStyle semiBold14Compact;
  final TextStyle bold14Compact;
  final TextStyle medium12;
  final TextStyle semiBold12;
  final TextStyle bold12;

  const AppTypography({
    required this.medium96,
    required this.semiBold96,
    required this.bold96,
    required this.medium72,
    required this.semiBold72,
    required this.bold72,
    required this.medium60,
    required this.semiBold60,
    required this.bold60,
    required this.medium48,
    required this.semiBold48,
    required this.bold48,
    required this.medium36,
    required this.semiBold36,
    required this.bold36,
    required this.medium32,
    required this.semiBold32,
    required this.bold32,
    required this.medium28,
    required this.semiBold28,
    required this.bold28,
    required this.medium24,
    required this.semiBold24,
    required this.bold24,
    required this.medium20,
    required this.semiBold20,
    required this.bold20,
    required this.medium18,
    required this.semiBold18,
    required this.bold18,
    required this.medium16,
    required this.semiBold16,
    required this.bold16,
    required this.medium14,
    required this.semiBold14,
    required this.bold14,
    required this.medium14Compact,
    required this.semiBold14Compact,
    required this.bold14Compact,
    required this.medium12,
    required this.semiBold12,
    required this.bold12,
  });

  static const instance = AppTypography(
    medium96: TextStyle(
      fontSize: 96,
      height: 104 / 96,
      letterSpacing: -1.5,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    semiBold96: TextStyle(
      fontSize: 96,
      height: 104 / 96,
      letterSpacing: -1.5,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bold96: TextStyle(
      fontSize: 96,
      height: 104 / 96,
      letterSpacing: -1.5,
      fontWeight: FontWeight.w700,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    medium72: TextStyle(
      fontSize: 72,
      height: 80 / 72,
      letterSpacing: -1.2,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    semiBold72: TextStyle(
      fontSize: 72,
      height: 80 / 72,
      letterSpacing: -1.2,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bold72: TextStyle(
      fontSize: 72,
      height: 80 / 72,
      letterSpacing: -1.2,
      fontWeight: FontWeight.w700,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    medium60: TextStyle(
      fontSize: 60,
      height: 68 / 60,
      letterSpacing: -1.0,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    semiBold60: TextStyle(
      fontSize: 60,
      height: 68 / 60,
      letterSpacing: -1.0,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bold60: TextStyle(
      fontSize: 60,
      height: 68 / 60,
      letterSpacing: -1.0,
      fontWeight: FontWeight.w700,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    medium48: TextStyle(
      fontSize: 48,
      height: 56 / 48,
      letterSpacing: -0.6,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    semiBold48: TextStyle(
      fontSize: 48,
      height: 56 / 48,
      letterSpacing: -0.6,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bold48: TextStyle(
      fontSize: 48,
      height: 56 / 48,
      letterSpacing: -0.6,
      fontWeight: FontWeight.w700,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    medium36: TextStyle(
      fontSize: 36,
      height: 44 / 36,
      letterSpacing: -0.4,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    semiBold36: TextStyle(
      fontSize: 36,
      height: 44 / 36,
      letterSpacing: -0.4,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bold36: TextStyle(
      fontSize: 36,
      height: 44 / 36,
      letterSpacing: -0.4,
      fontWeight: FontWeight.w700,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    medium32: TextStyle(
      fontSize: 32,
      height: 38 / 32,
      letterSpacing: -0.3,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    semiBold32: TextStyle(
      fontSize: 32,
      height: 38 / 32,
      letterSpacing: -0.3,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bold32: TextStyle(
      fontSize: 32,
      height: 38 / 32,
      letterSpacing: -0.3,
      fontWeight: FontWeight.w700,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    medium28: TextStyle(
      fontSize: 28,
      height: 34 / 28,
      letterSpacing: -0.2,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    semiBold28: TextStyle(
      fontSize: 28,
      height: 34 / 28,
      letterSpacing: -0.2,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bold28: TextStyle(
      fontSize: 28,
      height: 34 / 28,
      letterSpacing: -0.2,
      fontWeight: FontWeight.w700,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    medium24: TextStyle(
      fontSize: 24,
      height: 30 / 24,
      letterSpacing: -0.1,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    semiBold24: TextStyle(
      fontSize: 24,
      height: 30 / 24,
      letterSpacing: -0.1,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bold24: TextStyle(
      fontSize: 24,
      height: 30 / 24,
      letterSpacing: -0.1,
      fontWeight: FontWeight.w700,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    medium20: TextStyle(
      fontSize: 20,
      height: 26 / 20,
      letterSpacing: 0,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    semiBold20: TextStyle(
      fontSize: 20,
      height: 26 / 20,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bold20: TextStyle(
      fontSize: 20,
      height: 26 / 20,
      letterSpacing: 0,
      fontWeight: FontWeight.w700,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    medium18: TextStyle(
      fontSize: 18,
      height: 24 / 18,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    semiBold18: TextStyle(
      fontSize: 18,
      height: 24 / 18,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bold18: TextStyle(
      fontSize: 18,
      height: 24 / 18,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w700,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    medium16: TextStyle(
      fontSize: 16,
      height: 22 / 16,
      letterSpacing: 0.2,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    semiBold16: TextStyle(
      fontSize: 16,
      height: 22 / 16,
      letterSpacing: 0.2,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bold16: TextStyle(
      fontSize: 16,
      height: 22 / 16,
      letterSpacing: 0.2,
      fontWeight: FontWeight.w700,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    medium14: TextStyle(
      fontSize: 14,
      height: 18 / 14,
      letterSpacing: 0.4,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    semiBold14: TextStyle(
      fontSize: 14,
      height: 18 / 14,
      letterSpacing: 0.4,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bold14: TextStyle(
      fontSize: 14,
      height: 18 / 14,
      letterSpacing: 0.4,
      fontWeight: FontWeight.w700,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    medium14Compact: TextStyle(
      fontSize: 14,
      height: 16 / 14,
      letterSpacing: 0.4,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    semiBold14Compact: TextStyle(
      fontSize: 14,
      height: 16 / 14,
      letterSpacing: 0.4,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bold14Compact: TextStyle(
      fontSize: 14,
      height: 16 / 14,
      letterSpacing: 0.4,
      fontWeight: FontWeight.w700,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    medium12: TextStyle(
      fontSize: 12,
      height: 16 / 12,
      letterSpacing: 0.6,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    semiBold12: TextStyle(
      fontSize: 12,
      height: 16 / 12,
      letterSpacing: 0.6,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bold12: TextStyle(
      fontSize: 12,
      height: 16 / 12,
      letterSpacing: 0.6,
      fontWeight: FontWeight.w700,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  @override
  AppTypography copyWith({
    TextStyle? medium96,
    TextStyle? semiBold96,
    TextStyle? bold96,
    TextStyle? medium72,
    TextStyle? semiBold72,
    TextStyle? bold72,
    TextStyle? medium60,
    TextStyle? semiBold60,
    TextStyle? bold60,
    TextStyle? medium48,
    TextStyle? semiBold48,
    TextStyle? bold48,
    TextStyle? medium36,
    TextStyle? semiBold36,
    TextStyle? bold36,
    TextStyle? medium32,
    TextStyle? semiBold32,
    TextStyle? bold32,
    TextStyle? medium28,
    TextStyle? semiBold28,
    TextStyle? bold28,
    TextStyle? medium24,
    TextStyle? semiBold24,
    TextStyle? bold24,
    TextStyle? medium20,
    TextStyle? semiBold20,
    TextStyle? bold20,
    TextStyle? medium18,
    TextStyle? semiBold18,
    TextStyle? bold18,
    TextStyle? medium16,
    TextStyle? semiBold16,
    TextStyle? bold16,
    TextStyle? medium14,
    TextStyle? semiBold14,
    TextStyle? bold14,
    TextStyle? medium14Compact,
    TextStyle? semiBold14Compact,
    TextStyle? bold14Compact,
    TextStyle? medium12,
    TextStyle? semiBold12,
    TextStyle? bold12,
    TextStyle? semiBold10,
    TextStyle? bold10,
  }) {
    return AppTypography(
      medium96: medium96 ?? this.medium96,
      semiBold96: semiBold96 ?? this.semiBold96,
      bold96: bold96 ?? this.bold96,
      medium72: medium72 ?? this.medium72,
      semiBold72: semiBold72 ?? this.semiBold72,
      bold72: bold72 ?? this.bold72,
      medium60: medium60 ?? this.medium60,
      semiBold60: semiBold60 ?? this.semiBold60,
      bold60: bold60 ?? this.bold60,
      medium48: medium48 ?? this.medium48,
      semiBold48: semiBold48 ?? this.semiBold48,
      bold48: bold48 ?? this.bold48,
      medium36: medium36 ?? this.medium36,
      semiBold36: semiBold36 ?? this.semiBold36,
      bold36: bold36 ?? this.bold36,
      medium32: medium32 ?? this.medium32,
      semiBold32: semiBold32 ?? this.semiBold32,
      bold32: bold32 ?? this.bold32,
      medium28: medium28 ?? this.medium28,
      semiBold28: semiBold28 ?? this.semiBold28,
      bold28: bold28 ?? this.bold28,
      medium24: medium24 ?? this.medium24,
      semiBold24: semiBold24 ?? this.semiBold24,
      bold24: bold24 ?? this.bold24,
      medium20: medium20 ?? this.medium20,
      semiBold20: semiBold20 ?? this.semiBold20,
      bold20: bold20 ?? this.bold20,
      medium18: medium18 ?? this.medium18,
      semiBold18: semiBold18 ?? this.semiBold18,
      bold18: bold18 ?? this.bold18,
      medium16: medium16 ?? this.medium16,
      semiBold16: semiBold16 ?? this.semiBold16,
      bold16: bold16 ?? this.bold16,
      medium14: medium14 ?? this.medium14,
      semiBold14: semiBold14 ?? this.semiBold14,
      bold14: bold14 ?? this.bold14,
      medium14Compact: medium14Compact ?? this.medium14Compact,
      semiBold14Compact: semiBold14Compact ?? this.semiBold14Compact,
      bold14Compact: bold14Compact ?? this.bold14Compact,
      medium12: medium12 ?? this.medium12,
      semiBold12: semiBold12 ?? this.semiBold12,
      bold12: bold12 ?? this.bold12,
    );
  }

  @override
  AppTypography lerp(AppTypography? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      medium96: TextStyle.lerp(medium96, other.medium96, t)!,
      semiBold96: TextStyle.lerp(semiBold96, other.semiBold96, t)!,
      bold96: TextStyle.lerp(bold96, other.bold96, t)!,
      medium72: TextStyle.lerp(medium72, other.medium72, t)!,
      semiBold72: TextStyle.lerp(semiBold72, other.semiBold72, t)!,
      bold72: TextStyle.lerp(bold72, other.bold72, t)!,
      medium60: TextStyle.lerp(medium60, other.medium60, t)!,
      semiBold60: TextStyle.lerp(semiBold60, other.semiBold60, t)!,
      bold60: TextStyle.lerp(bold60, other.bold60, t)!,
      medium48: TextStyle.lerp(medium48, other.medium48, t)!,
      semiBold48: TextStyle.lerp(semiBold48, other.semiBold48, t)!,
      bold48: TextStyle.lerp(bold48, other.bold48, t)!,
      medium36: TextStyle.lerp(medium36, other.medium36, t)!,
      semiBold36: TextStyle.lerp(semiBold36, other.semiBold36, t)!,
      bold36: TextStyle.lerp(bold36, other.bold36, t)!,
      medium32: TextStyle.lerp(medium32, other.medium32, t)!,
      semiBold32: TextStyle.lerp(semiBold32, other.semiBold32, t)!,
      bold32: TextStyle.lerp(bold32, other.bold32, t)!,
      medium28: TextStyle.lerp(medium28, other.medium28, t)!,
      semiBold28: TextStyle.lerp(semiBold28, other.semiBold28, t)!,
      bold28: TextStyle.lerp(bold28, other.bold28, t)!,
      medium24: TextStyle.lerp(medium24, other.medium24, t)!,
      semiBold24: TextStyle.lerp(semiBold24, other.semiBold24, t)!,
      bold24: TextStyle.lerp(bold24, other.bold24, t)!,
      medium20: TextStyle.lerp(medium20, other.medium20, t)!,
      semiBold20: TextStyle.lerp(semiBold20, other.semiBold20, t)!,
      bold20: TextStyle.lerp(bold20, other.bold20, t)!,
      medium18: TextStyle.lerp(medium18, other.medium18, t)!,
      semiBold18: TextStyle.lerp(semiBold18, other.semiBold18, t)!,
      bold18: TextStyle.lerp(bold18, other.bold18, t)!,
      medium16: TextStyle.lerp(medium16, other.medium16, t)!,
      semiBold16: TextStyle.lerp(semiBold16, other.semiBold16, t)!,
      bold16: TextStyle.lerp(bold16, other.bold16, t)!,
      medium14: TextStyle.lerp(medium14, other.medium14, t)!,
      semiBold14: TextStyle.lerp(semiBold14, other.semiBold14, t)!,
      bold14: TextStyle.lerp(bold14, other.bold14, t)!,
      medium14Compact: TextStyle.lerp(medium14Compact, other.medium14Compact, t)!,
      semiBold14Compact: TextStyle.lerp(semiBold14Compact, other.semiBold14Compact, t)!,
      bold14Compact: TextStyle.lerp(bold14Compact, other.bold14Compact, t)!,
      medium12: TextStyle.lerp(medium12, other.medium12, t)!,
      semiBold12: TextStyle.lerp(semiBold12, other.semiBold12, t)!,
      bold12: TextStyle.lerp(bold12, other.bold12, t)!,
    );
  }
}

extension AppTypographyExtension on BuildContext {
  AppTypography get typography =>
      Theme.of(this).extension<AppTypography>() ?? AppTypography.instance;

  AppTypography get typographyScaled {
    final base = typography;
    return AppTypography(
      medium96: _scaleStyle(base.medium96),
      semiBold96: _scaleStyle(base.semiBold96),
      bold96: _scaleStyle(base.bold96),
      medium72: _scaleStyle(base.medium72),
      semiBold72: _scaleStyle(base.semiBold72),
      bold72: _scaleStyle(base.bold72),
      medium60: _scaleStyle(base.medium60),
      semiBold60: _scaleStyle(base.semiBold60),
      bold60: _scaleStyle(base.bold60),
      medium48: _scaleStyle(base.medium48),
      semiBold48: _scaleStyle(base.semiBold48),
      bold48: _scaleStyle(base.bold48),
      medium36: _scaleStyle(base.medium36),
      semiBold36: _scaleStyle(base.semiBold36),
      bold36: _scaleStyle(base.bold36),
      medium32: _scaleStyle(base.medium32),
      semiBold32: _scaleStyle(base.semiBold32),
      bold32: _scaleStyle(base.bold32),
      medium28: _scaleStyle(base.medium28),
      semiBold28: _scaleStyle(base.semiBold28),
      bold28: _scaleStyle(base.bold28),
      medium24: _scaleStyle(base.medium24),
      semiBold24: _scaleStyle(base.semiBold24),
      bold24: _scaleStyle(base.bold24),
      medium20: _scaleStyle(base.medium20),
      semiBold20: _scaleStyle(base.semiBold20),
      bold20: _scaleStyle(base.bold20),
      medium18: _scaleStyle(base.medium18),
      semiBold18: _scaleStyle(base.semiBold18),
      bold18: _scaleStyle(base.bold18),
      medium16: _scaleStyle(base.medium16),
      semiBold16: _scaleStyle(base.semiBold16),
      bold16: _scaleStyle(base.bold16),
      medium14: _scaleStyle(base.medium14),
      semiBold14: _scaleStyle(base.semiBold14),
      bold14: _scaleStyle(base.bold14),
      medium14Compact: _scaleStyle(base.medium14Compact),
      semiBold14Compact: _scaleStyle(base.semiBold14Compact),
      bold14Compact: _scaleStyle(base.bold14Compact),
      medium12: _scaleStyle(base.medium12),
      semiBold12: _scaleStyle(base.semiBold12),
      bold12: _scaleStyle(base.bold12),
    );
  }
}
