import 'package:flutter/material.dart';

// ============================================================================
// Primitive Colors
// ============================================================================

class _BaseColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00FFFFFF);
}

class _NeutralColors {
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral150 = Color(0xFFEDEDEE);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral850 = Color(0xFF1E1E1F);
  static const Color neutral900 = Color(0xFF171717);
  static const Color neutral950 = Color(0xFF0A0A0A);
}

class _RedColors {
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
}

class _OrangeColors {
  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange200 = Color(0xFFFED7AA);
  static const Color orange500 = Color(0xFFF97316);
  static const Color orange900 = Color(0xFF7C2D12);
  static const Color orange950 = Color(0xFF431407);
}

class _AmberColors {
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber900 = Color(0xFF78350F);
  static const Color amber950 = Color(0xFF451A03);
}

class _LimeColors {
  static const Color lime50 = Color(0xFFF7FEE7);
  static const Color lime200 = Color(0xFFD9F99D);
  static const Color lime500 = Color(0xFF84CC16);
  static const Color lime900 = Color(0xFF365314);
  static const Color lime950 = Color(0xFF1A2E05);
}

class _GreenColors {
  static const Color green500 = Color(0xFF22C55E);
}

class _EmeraldColors {
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald900 = Color(0xFF064E3B);
  static const Color emerald950 = Color(0xFF022C22);
}

class _TealColors {
  static const Color teal50 = Color(0xFFF0FDFA);
  static const Color teal200 = Color(0xFF99F6E4);
  static const Color teal500 = Color(0xFF14B8A6);
  static const Color teal900 = Color(0xFF134E4A);
  static const Color teal950 = Color(0xFF042F2E);
}

class _CyanColors {
  static const Color cyan50 = Color(0xFFECFEFF);
  static const Color cyan200 = Color(0xFFA5F3FC);
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color cyan900 = Color(0xFF164E63);
  static const Color cyan950 = Color(0xFF083344);
}

class _SkyColors {
  static const Color sky50 = Color(0xFFF0F9FF);
  static const Color sky200 = Color(0xFFBAE6FD);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color sky900 = Color(0xFF0C4A6E);
  static const Color sky950 = Color(0xFF082F49);
}

class _BlueColors {
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color blue950 = Color(0xFF172554);
}

class _IndigoColors {
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo900 = Color(0xFF312E81);
  static const Color indigo950 = Color(0xFF1E1B4B);
}

class _VioletColors {
  static const Color violet50 = Color(0xFFF5F3FF);
  static const Color violet200 = Color(0xFFDDD6FE);
  static const Color violet500 = Color(0xFF8B5CF6);
  static const Color violet900 = Color(0xFF4C1D95);
  static const Color violet950 = Color(0xFF2E1065);
}

class _FuchsiaColors {
  static const Color fuchsia50 = Color(0xFFFDF4FF);
  static const Color fuchsia200 = Color(0xFFF5D0FE);
  static const Color fuchsia500 = Color(0xFFD946EF);
  static const Color fuchsia900 = Color(0xFF701A75);
  static const Color fuchsia950 = Color(0xFF4A044E);
}

class _RoseColors {
  static const Color rose50 = Color(0xFFFFF1F2);
  static const Color rose200 = Color(0xFFFECDD3);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose900 = Color(0xFF881337);
  static const Color rose950 = Color(0xFF4C0519);
}

// ============================================================================
// Accent Color Set
// ============================================================================

@immutable
class AccentColorSet {
  final Color fill;
  final Color contentPrimary;
  final Color contentSecondary;
  final Color border;

  const AccentColorSet({
    required this.fill,
    required this.contentPrimary,
    required this.contentSecondary,
    required this.border,
  });

  AccentColorSet copyWith({
    Color? fill,
    Color? contentPrimary,
    Color? contentSecondary,
    Color? border,
  }) {
    return AccentColorSet(
      fill: fill ?? this.fill,
      contentPrimary: contentPrimary ?? this.contentPrimary,
      contentSecondary: contentSecondary ?? this.contentSecondary,
      border: border ?? this.border,
    );
  }

  static AccentColorSet lerp(AccentColorSet a, AccentColorSet b, double t) {
    return AccentColorSet(
      fill: Color.lerp(a.fill, b.fill, t)!,
      contentPrimary: Color.lerp(a.contentPrimary, b.contentPrimary, t)!,
      contentSecondary: Color.lerp(a.contentSecondary, b.contentSecondary, t)!,
      border: Color.lerp(a.border, b.border, t)!,
    );
  }
}

// ============================================================================
// Semantic Accent Colors
// ============================================================================

@immutable
class SemanticAccentColors {
  final AccentColorSet blue;
  final AccentColorSet cyan;
  final AccentColorSet emerald;
  final AccentColorSet fuchsia;
  final AccentColorSet indigo;
  final AccentColorSet lime;
  final AccentColorSet orange;
  final AccentColorSet rose;
  final AccentColorSet sky;
  final AccentColorSet teal;
  final AccentColorSet violet;
  final AccentColorSet amber;

  const SemanticAccentColors({
    required this.blue,
    required this.cyan,
    required this.emerald,
    required this.fuchsia,
    required this.indigo,
    required this.lime,
    required this.orange,
    required this.rose,
    required this.sky,
    required this.teal,
    required this.violet,
    required this.amber,
  });

  static SemanticAccentColors lerp(
    SemanticAccentColors a,
    SemanticAccentColors b,
    double t,
  ) {
    return SemanticAccentColors(
      blue: AccentColorSet.lerp(a.blue, b.blue, t),
      cyan: AccentColorSet.lerp(a.cyan, b.cyan, t),
      emerald: AccentColorSet.lerp(a.emerald, b.emerald, t),
      fuchsia: AccentColorSet.lerp(a.fuchsia, b.fuchsia, t),
      indigo: AccentColorSet.lerp(a.indigo, b.indigo, t),
      lime: AccentColorSet.lerp(a.lime, b.lime, t),
      orange: AccentColorSet.lerp(a.orange, b.orange, t),
      rose: AccentColorSet.lerp(a.rose, b.rose, t),
      sky: AccentColorSet.lerp(a.sky, b.sky, t),
      teal: AccentColorSet.lerp(a.teal, b.teal, t),
      violet: AccentColorSet.lerp(a.violet, b.violet, t),
      amber: AccentColorSet.lerp(a.amber, b.amber, t),
    );
  }
}

// ============================================================================
// Light Accent Colors
// ============================================================================

const _lightAccentColors = SemanticAccentColors(
  blue: AccentColorSet(
    fill: _BlueColors.blue50,
    contentPrimary: _BlueColors.blue900,
    contentSecondary: _BlueColors.blue500,
    border: _BlueColors.blue200,
  ),
  cyan: AccentColorSet(
    fill: _CyanColors.cyan50,
    contentPrimary: _CyanColors.cyan900,
    contentSecondary: _CyanColors.cyan500,
    border: _CyanColors.cyan200,
  ),
  emerald: AccentColorSet(
    fill: _EmeraldColors.emerald50,
    contentPrimary: _EmeraldColors.emerald900,
    contentSecondary: _EmeraldColors.emerald500,
    border: _EmeraldColors.emerald200,
  ),
  fuchsia: AccentColorSet(
    fill: _FuchsiaColors.fuchsia50,
    contentPrimary: _FuchsiaColors.fuchsia900,
    contentSecondary: _FuchsiaColors.fuchsia500,
    border: _FuchsiaColors.fuchsia200,
  ),
  indigo: AccentColorSet(
    fill: _IndigoColors.indigo50,
    contentPrimary: _IndigoColors.indigo900,
    contentSecondary: _IndigoColors.indigo500,
    border: _IndigoColors.indigo200,
  ),
  lime: AccentColorSet(
    fill: _LimeColors.lime50,
    contentPrimary: _LimeColors.lime900,
    contentSecondary: _LimeColors.lime500,
    border: _LimeColors.lime200,
  ),
  orange: AccentColorSet(
    fill: _OrangeColors.orange50,
    contentPrimary: _OrangeColors.orange900,
    contentSecondary: _OrangeColors.orange500,
    border: _OrangeColors.orange200,
  ),
  rose: AccentColorSet(
    fill: _RoseColors.rose50,
    contentPrimary: _RoseColors.rose900,
    contentSecondary: _RoseColors.rose500,
    border: _RoseColors.rose200,
  ),
  sky: AccentColorSet(
    fill: _SkyColors.sky50,
    contentPrimary: _SkyColors.sky900,
    contentSecondary: _SkyColors.sky500,
    border: _SkyColors.sky200,
  ),
  teal: AccentColorSet(
    fill: _TealColors.teal50,
    contentPrimary: _TealColors.teal900,
    contentSecondary: _TealColors.teal500,
    border: _TealColors.teal200,
  ),
  violet: AccentColorSet(
    fill: _VioletColors.violet50,
    contentPrimary: _VioletColors.violet900,
    contentSecondary: _VioletColors.violet500,
    border: _VioletColors.violet200,
  ),
  amber: AccentColorSet(
    fill: _AmberColors.amber50,
    contentPrimary: _AmberColors.amber900,
    contentSecondary: _AmberColors.amber500,
    border: _AmberColors.amber200,
  ),
);

// ============================================================================
// Dark Accent Colors
// ============================================================================

const _darkAccentColors = SemanticAccentColors(
  blue: AccentColorSet(
    fill: _BlueColors.blue950,
    contentPrimary: _BlueColors.blue50,
    contentSecondary: _BlueColors.blue500,
    border: _BlueColors.blue200,
  ),
  cyan: AccentColorSet(
    fill: _CyanColors.cyan950,
    contentPrimary: _CyanColors.cyan50,
    contentSecondary: _CyanColors.cyan500,
    border: _CyanColors.cyan200,
  ),
  emerald: AccentColorSet(
    fill: _EmeraldColors.emerald950,
    contentPrimary: _EmeraldColors.emerald50,
    contentSecondary: _EmeraldColors.emerald500,
    border: _EmeraldColors.emerald200,
  ),
  fuchsia: AccentColorSet(
    fill: _FuchsiaColors.fuchsia950,
    contentPrimary: _FuchsiaColors.fuchsia50,
    contentSecondary: _FuchsiaColors.fuchsia500,
    border: _FuchsiaColors.fuchsia200,
  ),
  indigo: AccentColorSet(
    fill: _IndigoColors.indigo950,
    contentPrimary: _IndigoColors.indigo50,
    contentSecondary: _IndigoColors.indigo500,
    border: _IndigoColors.indigo200,
  ),
  lime: AccentColorSet(
    fill: _LimeColors.lime950,
    contentPrimary: _LimeColors.lime50,
    contentSecondary: _LimeColors.lime500,
    border: _LimeColors.lime200,
  ),
  orange: AccentColorSet(
    fill: _OrangeColors.orange950,
    contentPrimary: _OrangeColors.orange50,
    contentSecondary: _OrangeColors.orange500,
    border: _OrangeColors.orange200,
  ),
  rose: AccentColorSet(
    fill: _RoseColors.rose950,
    contentPrimary: _RoseColors.rose50,
    contentSecondary: _RoseColors.rose500,
    border: _RoseColors.rose200,
  ),
  sky: AccentColorSet(
    fill: _SkyColors.sky950,
    contentPrimary: _SkyColors.sky50,
    contentSecondary: _SkyColors.sky500,
    border: _SkyColors.sky200,
  ),
  teal: AccentColorSet(
    fill: _TealColors.teal950,
    contentPrimary: _TealColors.teal50,
    contentSecondary: _TealColors.teal500,
    border: _TealColors.teal200,
  ),
  violet: AccentColorSet(
    fill: _VioletColors.violet950,
    contentPrimary: _VioletColors.violet50,
    contentSecondary: _VioletColors.violet500,
    border: _VioletColors.violet200,
  ),
  amber: AccentColorSet(
    fill: _AmberColors.amber950,
    contentPrimary: _AmberColors.amber50,
    contentSecondary: _AmberColors.amber500,
    border: _AmberColors.amber200,
  ),
);

// ============================================================================
// Semantic Colors Theme Extension
// ============================================================================

@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  // Background Colors
  final Color backgroundPrimary;
  final Color backgroundSecondary;
  final Color backgroundTertiary;
  final Color backgroundContentPrimary;
  final Color backgroundContentSecondary;
  final Color backgroundContentTertiary;
  final Color backgroundContentDestructive;
  final Color backgroundContentDestructiveSecondary;

  // Fill Colors
  final Color fillPrimary;
  final Color fillPrimaryHover;
  final Color fillPrimaryActive;
  final Color fillSecondary;
  final Color fillSecondaryHover;
  final Color fillSecondaryActive;
  final Color fillTertiary;
  final Color fillTertiaryHover;
  final Color fillTertiaryActive;
  final Color fillDestructive;
  final Color fillDestructiveHover;
  final Color fillDestructiveActive;

  // Fill Content Colors
  final Color fillContentPrimary;
  final Color fillContentSecondary;
  final Color fillContentDestructive;

  // Border Colors
  final Color borderPrimary;
  final Color borderSecondary;
  final Color borderTertiary;
  final Color borderDestructivePrimary;
  final Color borderDestructiveSecondary;
  final Color borderInfo;
  final Color borderSuccess;
  final Color borderWarning;

  // Shadow Colors
  final Color shadow;

  // Accent Colors
  final SemanticAccentColors accent;

  const SemanticColors({
    // Background Colors
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.backgroundTertiary,
    required this.backgroundContentPrimary,
    required this.backgroundContentSecondary,
    required this.backgroundContentTertiary,
    required this.backgroundContentDestructive,
    required this.backgroundContentDestructiveSecondary,
    // Fill Colors
    required this.fillPrimary,
    required this.fillPrimaryHover,
    required this.fillPrimaryActive,
    required this.fillSecondary,
    required this.fillSecondaryHover,
    required this.fillSecondaryActive,
    required this.fillTertiary,
    required this.fillTertiaryHover,
    required this.fillTertiaryActive,
    required this.fillDestructive,
    required this.fillDestructiveHover,
    required this.fillDestructiveActive,
    // Fill Content Colors
    required this.fillContentPrimary,
    required this.fillContentSecondary,
    required this.fillContentDestructive,
    // Border Colors
    required this.borderPrimary,
    required this.borderSecondary,
    required this.borderTertiary,
    required this.borderDestructivePrimary,
    required this.borderDestructiveSecondary,
    required this.borderInfo,
    required this.borderSuccess,
    required this.borderWarning,
    // Shadow Colors
    required this.shadow,
    // Accent Colors
    required this.accent,
  });

  // Light theme colors
  static const light = SemanticColors(
    // Background Colors
    backgroundPrimary: _BaseColors.white,
    backgroundSecondary: _NeutralColors.neutral50,
    backgroundTertiary: _NeutralColors.neutral100,
    backgroundContentPrimary: _NeutralColors.neutral950,
    backgroundContentSecondary: _NeutralColors.neutral500,
    backgroundContentTertiary: _NeutralColors.neutral400,
    backgroundContentDestructive: _RedColors.red500,
    backgroundContentDestructiveSecondary: _RedColors.red600,
    // Fill Colors
    fillPrimary: _NeutralColors.neutral950,
    fillPrimaryHover: _NeutralColors.neutral800,
    fillPrimaryActive: _NeutralColors.neutral800,
    fillSecondary: _NeutralColors.neutral100,
    fillSecondaryHover: _NeutralColors.neutral150,
    fillSecondaryActive: _NeutralColors.neutral150,
    fillTertiary: _BaseColors.transparent,
    fillTertiaryHover: _NeutralColors.neutral100,
    fillTertiaryActive: _NeutralColors.neutral100,
    fillDestructive: _RedColors.red500,
    fillDestructiveHover: _RedColors.red600,
    fillDestructiveActive: _RedColors.red600,
    // Fill Content Colors
    fillContentPrimary: _BaseColors.white,
    fillContentSecondary: _NeutralColors.neutral950,
    fillContentDestructive: _BaseColors.white,
    // Border Colors
    borderPrimary: _NeutralColors.neutral950,
    borderSecondary: _NeutralColors.neutral500,
    borderTertiary: _NeutralColors.neutral200,
    borderDestructivePrimary: _RedColors.red500,
    borderDestructiveSecondary: _RedColors.red600,
    borderInfo: _BlueColors.blue500,
    borderSuccess: _GreenColors.green500,
    borderWarning: _OrangeColors.orange500,
    shadow: _BaseColors.black,
    // Accent Colors
    accent: _lightAccentColors,
  );

  // Dark theme colors
  static const dark = SemanticColors(
    // Background Colors
    backgroundPrimary: _BaseColors.black,
    backgroundSecondary: _NeutralColors.neutral950,
    backgroundTertiary: _NeutralColors.neutral900,
    backgroundContentPrimary: _BaseColors.white,
    backgroundContentSecondary: _NeutralColors.neutral400,
    backgroundContentTertiary: _NeutralColors.neutral500,
    backgroundContentDestructive: _RedColors.red500,
    backgroundContentDestructiveSecondary: _RedColors.red600,
    // Fill Colors
    fillPrimary: _BaseColors.white,
    fillPrimaryHover: _NeutralColors.neutral200,
    fillPrimaryActive: _NeutralColors.neutral200,
    fillSecondary: _NeutralColors.neutral900,
    fillSecondaryHover: _NeutralColors.neutral850,
    fillSecondaryActive: _NeutralColors.neutral850,
    fillTertiary: _BaseColors.transparent,
    fillTertiaryHover: _NeutralColors.neutral900,
    fillTertiaryActive: _NeutralColors.neutral900,
    fillDestructive: _RedColors.red500,
    fillDestructiveHover: _RedColors.red600,
    fillDestructiveActive: _RedColors.red600,
    // Fill Content Colors
    fillContentPrimary: _NeutralColors.neutral950,
    fillContentSecondary: _BaseColors.white,
    fillContentDestructive: _BaseColors.white,
    // Border Colors
    borderPrimary: _BaseColors.white,
    borderSecondary: _NeutralColors.neutral400,
    borderTertiary: _NeutralColors.neutral800,
    borderDestructivePrimary: _RedColors.red500,
    borderDestructiveSecondary: _RedColors.red600,
    borderInfo: _BlueColors.blue500,
    borderSuccess: _GreenColors.green500,
    borderWarning: _OrangeColors.orange500,
    // Shadow Colors
    shadow: _BaseColors.black,
    // Accent Colors
    accent: _darkAccentColors,
  );

  @override
  SemanticColors copyWith({
    // Background Colors
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? backgroundTertiary,
    Color? backgroundContentPrimary,
    Color? backgroundContentSecondary,
    Color? backgroundContentTertiary,
    Color? backgroundContentDestructive,
    Color? backgroundContentDestructiveSecondary,
    // Fill Colors
    Color? fillPrimary,
    Color? fillPrimaryHover,
    Color? fillPrimaryActive,
    Color? fillSecondary,
    Color? fillSecondaryHover,
    Color? fillSecondaryActive,
    Color? fillTertiary,
    Color? fillTertiaryHover,
    Color? fillTertiaryActive,
    Color? fillDestructive,
    Color? fillDestructiveHover,
    Color? fillDestructiveActive,
    // Fill Content Colors
    Color? fillContentPrimary,
    Color? fillContentSecondary,
    Color? fillContentDestructive,
    // Border Colors
    Color? borderPrimary,
    Color? borderSecondary,
    Color? borderTertiary,
    Color? borderDestructivePrimary,
    Color? borderDestructiveSecondary,
    Color? borderInfo,
    Color? borderSuccess,
    Color? borderWarning,
    // Shadow Colors
    Color? shadow,
    // Accent Colors
    SemanticAccentColors? accent,
  }) {
    return SemanticColors(
      // Background Colors
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      backgroundTertiary: backgroundTertiary ?? this.backgroundTertiary,
      backgroundContentPrimary: backgroundContentPrimary ?? this.backgroundContentPrimary,
      backgroundContentSecondary: backgroundContentSecondary ?? this.backgroundContentSecondary,
      backgroundContentTertiary: backgroundContentTertiary ?? this.backgroundContentTertiary,
      backgroundContentDestructive:
          backgroundContentDestructive ?? this.backgroundContentDestructive,
      backgroundContentDestructiveSecondary:
          backgroundContentDestructiveSecondary ?? this.backgroundContentDestructiveSecondary,
      // Fill Colors
      fillPrimary: fillPrimary ?? this.fillPrimary,
      fillPrimaryHover: fillPrimaryHover ?? this.fillPrimaryHover,
      fillPrimaryActive: fillPrimaryActive ?? this.fillPrimaryActive,
      fillSecondary: fillSecondary ?? this.fillSecondary,
      fillSecondaryHover: fillSecondaryHover ?? this.fillSecondaryHover,
      fillSecondaryActive: fillSecondaryActive ?? this.fillSecondaryActive,
      fillTertiary: fillTertiary ?? this.fillTertiary,
      fillTertiaryHover: fillTertiaryHover ?? this.fillTertiaryHover,
      fillTertiaryActive: fillTertiaryActive ?? this.fillTertiaryActive,
      fillDestructive: fillDestructive ?? this.fillDestructive,
      fillDestructiveHover: fillDestructiveHover ?? this.fillDestructiveHover,
      fillDestructiveActive: fillDestructiveActive ?? this.fillDestructiveActive,
      // Fill Content Colors
      fillContentPrimary: fillContentPrimary ?? this.fillContentPrimary,
      fillContentSecondary: fillContentSecondary ?? this.fillContentSecondary,
      fillContentDestructive: fillContentDestructive ?? this.fillContentDestructive,
      // Border Colors
      borderPrimary: borderPrimary ?? this.borderPrimary,
      borderSecondary: borderSecondary ?? this.borderSecondary,
      borderTertiary: borderTertiary ?? this.borderTertiary,
      borderDestructivePrimary: borderDestructivePrimary ?? this.borderDestructivePrimary,
      borderDestructiveSecondary: borderDestructiveSecondary ?? this.borderDestructiveSecondary,
      borderInfo: borderInfo ?? this.borderInfo,
      borderSuccess: borderSuccess ?? this.borderSuccess,
      borderWarning: borderWarning ?? this.borderWarning,
      // Shadow Colors
      shadow: shadow ?? this.shadow,
      // Accent Colors
      accent: accent ?? this.accent,
    );
  }

  @override
  SemanticColors lerp(SemanticColors? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      // Background Colors
      backgroundPrimary: Color.lerp(backgroundPrimary, other.backgroundPrimary, t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      backgroundTertiary: Color.lerp(backgroundTertiary, other.backgroundTertiary, t)!,
      backgroundContentPrimary: Color.lerp(
        backgroundContentPrimary,
        other.backgroundContentPrimary,
        t,
      )!,
      backgroundContentSecondary: Color.lerp(
        backgroundContentSecondary,
        other.backgroundContentSecondary,
        t,
      )!,
      backgroundContentTertiary: Color.lerp(
        backgroundContentTertiary,
        other.backgroundContentTertiary,
        t,
      )!,
      backgroundContentDestructive: Color.lerp(
        backgroundContentDestructive,
        other.backgroundContentDestructive,
        t,
      )!,
      backgroundContentDestructiveSecondary: Color.lerp(
        backgroundContentDestructiveSecondary,
        other.backgroundContentDestructiveSecondary,
        t,
      )!,
      // Fill Colors
      fillPrimary: Color.lerp(fillPrimary, other.fillPrimary, t)!,
      fillPrimaryHover: Color.lerp(fillPrimaryHover, other.fillPrimaryHover, t)!,
      fillPrimaryActive: Color.lerp(fillPrimaryActive, other.fillPrimaryActive, t)!,
      fillSecondary: Color.lerp(fillSecondary, other.fillSecondary, t)!,
      fillSecondaryHover: Color.lerp(fillSecondaryHover, other.fillSecondaryHover, t)!,
      fillSecondaryActive: Color.lerp(fillSecondaryActive, other.fillSecondaryActive, t)!,
      fillTertiary: Color.lerp(fillTertiary, other.fillTertiary, t)!,
      fillTertiaryHover: Color.lerp(fillTertiaryHover, other.fillTertiaryHover, t)!,
      fillTertiaryActive: Color.lerp(fillTertiaryActive, other.fillTertiaryActive, t)!,
      fillDestructive: Color.lerp(fillDestructive, other.fillDestructive, t)!,
      fillDestructiveHover: Color.lerp(fillDestructiveHover, other.fillDestructiveHover, t)!,
      fillDestructiveActive: Color.lerp(fillDestructiveActive, other.fillDestructiveActive, t)!,
      // Fill Content Colors
      fillContentPrimary: Color.lerp(fillContentPrimary, other.fillContentPrimary, t)!,
      fillContentSecondary: Color.lerp(fillContentSecondary, other.fillContentSecondary, t)!,
      fillContentDestructive: Color.lerp(fillContentDestructive, other.fillContentDestructive, t)!,
      // Border Colors
      borderPrimary: Color.lerp(borderPrimary, other.borderPrimary, t)!,
      borderSecondary: Color.lerp(borderSecondary, other.borderSecondary, t)!,
      borderTertiary: Color.lerp(borderTertiary, other.borderTertiary, t)!,
      borderDestructivePrimary: Color.lerp(
        borderDestructivePrimary,
        other.borderDestructivePrimary,
        t,
      )!,
      borderDestructiveSecondary: Color.lerp(
        borderDestructiveSecondary,
        other.borderDestructiveSecondary,
        t,
      )!,
      borderInfo: Color.lerp(borderInfo, other.borderInfo, t)!,
      borderSuccess: Color.lerp(borderSuccess, other.borderSuccess, t)!,
      borderWarning: Color.lerp(borderWarning, other.borderWarning, t)!,
      // Shadow Colors
      shadow: Color.lerp(shadow, other.shadow, t)!,
      // Accent Colors
      accent: SemanticAccentColors.lerp(accent, other.accent, t),
    );
  }
}

// ============================================================================
// BuildContext Extension
// ============================================================================

extension SemanticColorsExtension on BuildContext {
  SemanticColors get colors => Theme.of(this).extension<SemanticColors>() ?? SemanticColors.light;
}
