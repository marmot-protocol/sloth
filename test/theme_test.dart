import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/theme.dart';

void main() {
  group('lightTheme', () {
    test('has light brightness', () {
      expect(lightTheme.brightness, Brightness.light);
    });

    test('uses Manrope font family', () {
      expect(lightTheme.textTheme.bodyMedium?.fontFamily, 'Manrope');
    });

    test('includes SemanticColors.light extension', () {
      final semanticColors = lightTheme.extension<SemanticColors>();
      expect(semanticColors, isNotNull);
      expect(
        semanticColors!.backgroundPrimary,
        SemanticColors.light.backgroundPrimary,
      );
    });
  });

  group('darkTheme', () {
    test('has dark brightness', () {
      expect(darkTheme.brightness, Brightness.dark);
    });

    test('uses Manrope font family', () {
      expect(darkTheme.textTheme.bodyMedium?.fontFamily, 'Manrope');
    });

    test('includes SemanticColors.dark extension', () {
      final semanticColors = darkTheme.extension<SemanticColors>();
      expect(semanticColors, isNotNull);
      expect(
        semanticColors!.backgroundPrimary,
        SemanticColors.dark.backgroundPrimary,
      );
    });
  });
}
