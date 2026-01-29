import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/theme/semantic_colors.dart';
import 'package:sloth/utils/avatar_color.dart';

void main() {
  group('avatarColorFromPubkey', () {
    group('maps hex digits 0-9 to colors', () {
      test('0 returns blue', () {
        expect(avatarColorFromPubkey('0abc'), AccentColor.blue);
      });

      test('1 returns cyan', () {
        expect(avatarColorFromPubkey('1abc'), AccentColor.cyan);
      });

      test('2 returns emerald', () {
        expect(avatarColorFromPubkey('2abc'), AccentColor.emerald);
      });

      test('3 returns fuchsia', () {
        expect(avatarColorFromPubkey('3abc'), AccentColor.fuchsia);
      });

      test('4 returns indigo', () {
        expect(avatarColorFromPubkey('4abc'), AccentColor.indigo);
      });

      test('5 returns lime', () {
        expect(avatarColorFromPubkey('5abc'), AccentColor.lime);
      });

      test('6 returns orange', () {
        expect(avatarColorFromPubkey('6abc'), AccentColor.orange);
      });

      test('7 returns rose', () {
        expect(avatarColorFromPubkey('7abc'), AccentColor.rose);
      });

      test('8 returns sky', () {
        expect(avatarColorFromPubkey('8abc'), AccentColor.sky);
      });

      test('9 returns teal', () {
        expect(avatarColorFromPubkey('9abc'), AccentColor.teal);
      });
    });

    group('maps hex letters a-f to colors', () {
      test('a returns violet', () {
        expect(avatarColorFromPubkey('aabc'), AccentColor.violet);
      });

      test('b returns amber', () {
        expect(avatarColorFromPubkey('babc'), AccentColor.amber);
      });

      test('c wraps to blue', () {
        expect(avatarColorFromPubkey('cabc'), AccentColor.blue);
      });

      test('d wraps to cyan', () {
        expect(avatarColorFromPubkey('dabc'), AccentColor.cyan);
      });

      test('e wraps to emerald', () {
        expect(avatarColorFromPubkey('eabc'), AccentColor.emerald);
      });

      test('f wraps to fuchsia', () {
        expect(avatarColorFromPubkey('fabc'), AccentColor.fuchsia);
      });
    });

    group('handles uppercase', () {
      test('A returns violet', () {
        expect(avatarColorFromPubkey('Aabc'), AccentColor.violet);
      });

      test('F returns fuchsia', () {
        expect(avatarColorFromPubkey('Fabc'), AccentColor.fuchsia);
      });
    });

    group('edge cases', () {
      test('empty string returns rose', () {
        expect(avatarColorFromPubkey(''), AccentColor.rose);
      });

      test('non-hex character g returns rose', () {
        expect(avatarColorFromPubkey('ghij'), AccentColor.rose);
      });
    });
  });
}
