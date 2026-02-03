import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/theme/semantic_colors.dart' show SemanticColors;
import 'package:whitenoise/utils/avatar_color.dart';

void main() {
  group('AvatarColor.fromPubkey', () {
    group('maps hex digits 0-9 to colors', () {
      test('0 returns blue', () {
        expect(
          AvatarColor.fromPubkey(
            '0000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.blue,
        );
      });

      test('1 returns cyan', () {
        expect(
          AvatarColor.fromPubkey(
            '1000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.cyan,
        );
      });

      test('2 returns emerald', () {
        expect(
          AvatarColor.fromPubkey(
            '2000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.emerald,
        );
      });

      test('3 returns fuchsia', () {
        expect(
          AvatarColor.fromPubkey(
            '3000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.fuchsia,
        );
      });

      test('4 returns indigo', () {
        expect(
          AvatarColor.fromPubkey(
            '4000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.indigo,
        );
      });

      test('5 returns lime', () {
        expect(
          AvatarColor.fromPubkey(
            '5000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.lime,
        );
      });

      test('6 returns orange', () {
        expect(
          AvatarColor.fromPubkey(
            '6000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.orange,
        );
      });

      test('7 returns rose', () {
        expect(
          AvatarColor.fromPubkey(
            '7000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.rose,
        );
      });

      test('8 returns sky', () {
        expect(
          AvatarColor.fromPubkey(
            '8000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.sky,
        );
      });

      test('9 returns teal', () {
        expect(
          AvatarColor.fromPubkey(
            '9000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.teal,
        );
      });
    });

    group('maps hex letters a-f to colors', () {
      test('a returns violet', () {
        expect(
          AvatarColor.fromPubkey(
            'a000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.violet,
        );
      });

      test('b returns amber', () {
        expect(
          AvatarColor.fromPubkey(
            'b000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.amber,
        );
      });

      test('c wraps to blue', () {
        expect(
          AvatarColor.fromPubkey(
            'c000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.blue,
        );
      });

      test('d wraps to cyan', () {
        expect(
          AvatarColor.fromPubkey(
            'd000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.cyan,
        );
      });

      test('e wraps to emerald', () {
        expect(
          AvatarColor.fromPubkey(
            'e000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.emerald,
        );
      });

      test('f wraps to fuchsia', () {
        expect(
          AvatarColor.fromPubkey(
            'f000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.fuchsia,
        );
      });
    });

    group('handles uppercase', () {
      test('A returns violet', () {
        expect(
          AvatarColor.fromPubkey(
            'A000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.violet,
        );
      });

      test('F returns fuchsia', () {
        expect(
          AvatarColor.fromPubkey(
            'F000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.fuchsia,
        );
      });
    });

    group('edge cases', () {
      test('empty string returns neutral', () {
        expect(AvatarColor.fromPubkey(''), AvatarColor.neutral);
      });

      test('non-hex character g returns neutral', () {
        expect(
          AvatarColor.fromPubkey(
            'g000000000000000000000000000000000000000000000000000000000000000',
          ),
          AvatarColor.neutral,
        );
      });
    });
  });

  group('AvatarColor enum', () {
    test('has 13 values', () {
      expect(AvatarColor.values.length, 13);
    });

    test('neutral is first value', () {
      expect(AvatarColor.values.first, AvatarColor.neutral);
    });

    test('accent colors follow neutral', () {
      expect(AvatarColor.values[1], AvatarColor.blue);
      expect(AvatarColor.values[12], AvatarColor.amber);
    });
  });

  group('AvatarColor equality', () {
    test('same enum values are equal', () {
      expect(AvatarColor.rose, AvatarColor.rose);
    });

    test('different enum values are not equal', () {
      expect(AvatarColor.rose, isNot(AvatarColor.cyan));
    });

    test('accent color does not equal neutral', () {
      expect(AvatarColor.rose, isNot(AvatarColor.neutral));
    });
  });

  group('AvatarColor.toColorSet', () {
    late SemanticColors colors;

    setUp(() {
      colors = SemanticColors.light;
    });

    group('neutral', () {
      test('background returns fillSecondary', () {
        expect(AvatarColor.neutral.toColorSet(colors).background, colors.fillSecondary);
      });

      test('border returns borderSecondary', () {
        expect(AvatarColor.neutral.toColorSet(colors).border, colors.borderSecondary);
      });

      test('content returns fillContentSecondary', () {
        expect(AvatarColor.neutral.toColorSet(colors).content, colors.fillContentSecondary);
      });
    });

    group('accent colors', () {
      group('blue', () {
        test('background returns accent fill', () {
          expect(AvatarColor.blue.toColorSet(colors).background, colors.accent.blue.fill);
        });

        test('border returns accent border', () {
          expect(AvatarColor.blue.toColorSet(colors).border, colors.accent.blue.border);
        });

        test('content returns accent contentPrimary', () {
          expect(AvatarColor.blue.toColorSet(colors).content, colors.accent.blue.contentPrimary);
        });
      });

      group('cyan', () {
        test('background returns accent fill', () {
          expect(AvatarColor.cyan.toColorSet(colors).background, colors.accent.cyan.fill);
        });

        test('border returns accent border', () {
          expect(AvatarColor.cyan.toColorSet(colors).border, colors.accent.cyan.border);
        });

        test('content returns accent contentPrimary', () {
          expect(AvatarColor.cyan.toColorSet(colors).content, colors.accent.cyan.contentPrimary);
        });
      });

      group('emerald', () {
        test('background returns accent fill', () {
          expect(AvatarColor.emerald.toColorSet(colors).background, colors.accent.emerald.fill);
        });

        test('border returns accent border', () {
          expect(AvatarColor.emerald.toColorSet(colors).border, colors.accent.emerald.border);
        });

        test('content returns accent contentPrimary', () {
          expect(
            AvatarColor.emerald.toColorSet(colors).content,
            colors.accent.emerald.contentPrimary,
          );
        });
      });

      group('fuchsia', () {
        test('background returns accent fill', () {
          expect(AvatarColor.fuchsia.toColorSet(colors).background, colors.accent.fuchsia.fill);
        });

        test('border returns accent border', () {
          expect(AvatarColor.fuchsia.toColorSet(colors).border, colors.accent.fuchsia.border);
        });

        test('content returns accent contentPrimary', () {
          expect(
            AvatarColor.fuchsia.toColorSet(colors).content,
            colors.accent.fuchsia.contentPrimary,
          );
        });
      });

      group('indigo', () {
        test('background returns accent fill', () {
          expect(AvatarColor.indigo.toColorSet(colors).background, colors.accent.indigo.fill);
        });

        test('border returns accent border', () {
          expect(AvatarColor.indigo.toColorSet(colors).border, colors.accent.indigo.border);
        });

        test('content returns accent contentPrimary', () {
          expect(
            AvatarColor.indigo.toColorSet(colors).content,
            colors.accent.indigo.contentPrimary,
          );
        });
      });

      group('lime', () {
        test('background returns accent fill', () {
          expect(AvatarColor.lime.toColorSet(colors).background, colors.accent.lime.fill);
        });

        test('border returns accent border', () {
          expect(AvatarColor.lime.toColorSet(colors).border, colors.accent.lime.border);
        });

        test('content returns accent contentPrimary', () {
          expect(AvatarColor.lime.toColorSet(colors).content, colors.accent.lime.contentPrimary);
        });
      });

      group('orange', () {
        test('background returns accent fill', () {
          expect(AvatarColor.orange.toColorSet(colors).background, colors.accent.orange.fill);
        });

        test('border returns accent border', () {
          expect(AvatarColor.orange.toColorSet(colors).border, colors.accent.orange.border);
        });

        test('content returns accent contentPrimary', () {
          expect(
            AvatarColor.orange.toColorSet(colors).content,
            colors.accent.orange.contentPrimary,
          );
        });
      });

      group('rose', () {
        test('background returns accent fill', () {
          expect(AvatarColor.rose.toColorSet(colors).background, colors.accent.rose.fill);
        });

        test('border returns accent border', () {
          expect(AvatarColor.rose.toColorSet(colors).border, colors.accent.rose.border);
        });

        test('content returns accent contentPrimary', () {
          expect(AvatarColor.rose.toColorSet(colors).content, colors.accent.rose.contentPrimary);
        });
      });

      group('sky', () {
        test('background returns accent fill', () {
          expect(AvatarColor.sky.toColorSet(colors).background, colors.accent.sky.fill);
        });

        test('border returns accent border', () {
          expect(AvatarColor.sky.toColorSet(colors).border, colors.accent.sky.border);
        });

        test('content returns accent contentPrimary', () {
          expect(AvatarColor.sky.toColorSet(colors).content, colors.accent.sky.contentPrimary);
        });
      });

      group('teal', () {
        test('background returns accent fill', () {
          expect(AvatarColor.teal.toColorSet(colors).background, colors.accent.teal.fill);
        });

        test('border returns accent border', () {
          expect(AvatarColor.teal.toColorSet(colors).border, colors.accent.teal.border);
        });

        test('content returns accent contentPrimary', () {
          expect(AvatarColor.teal.toColorSet(colors).content, colors.accent.teal.contentPrimary);
        });
      });

      group('violet', () {
        test('background returns accent fill', () {
          expect(AvatarColor.violet.toColorSet(colors).background, colors.accent.violet.fill);
        });

        test('border returns accent border', () {
          expect(AvatarColor.violet.toColorSet(colors).border, colors.accent.violet.border);
        });

        test('content returns accent contentPrimary', () {
          expect(
            AvatarColor.violet.toColorSet(colors).content,
            colors.accent.violet.contentPrimary,
          );
        });
      });

      group('amber', () {
        test('background returns accent fill', () {
          expect(AvatarColor.amber.toColorSet(colors).background, colors.accent.amber.fill);
        });

        test('border returns accent border', () {
          expect(AvatarColor.amber.toColorSet(colors).border, colors.accent.amber.border);
        });

        test('content returns accent contentPrimary', () {
          expect(AvatarColor.amber.toColorSet(colors).content, colors.accent.amber.contentPrimary);
        });
      });
    });
  });
}
