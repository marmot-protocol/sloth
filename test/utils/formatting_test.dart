import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/utils/formatting.dart';

void main() {
  group('formatPublicKey', () {
    test('adds space every 4 chars', () {
      expect(formatPublicKey('abcdefghijkl'), 'abcd efgh ijkl');
    });

    test('leaves remainder without trailing space', () {
      expect(formatPublicKey('abcdefghij'), 'abcd efgh ij');
    });

    test('returns empty for empty input', () {
      expect(formatPublicKey(''), '');
    });

    test('returns unchanged if less than 4 chars', () {
      expect(formatPublicKey('abc'), 'abc');
    });
  });

  group('formatInitials', () {
    test('returns null for null input', () {
      expect(formatInitials(null), isNull);
    });

    test('returns null for empty string', () {
      expect(formatInitials(''), isNull);
    });

    test('returns single initial for single word', () {
      expect(formatInitials('Alice'), 'A');
    });

    test('returns first initial for two words', () {
      expect(formatInitials('Alice Bob'), 'A');
    });

    test('uses only first initial when more words provided', () {
      expect(formatInitials('Alice Bob Charlie'), 'A');
    });

    test('converts to uppercase', () {
      expect(formatInitials('alice bob'), 'A');
    });

    test('handles multiple consecutive spaces', () {
      expect(formatInitials('John  Doe'), 'J');
    });

    test('handles leading and trailing whitespace', () {
      expect(formatInitials('  Alice  '), 'A');
    });

    test('returns null for whitespace-only string', () {
      expect(formatInitials('   '), isNull);
    });
  });
}
