import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/utils/formatting.dart';

class _MockApi implements RustLibApi {
  bool shouldThrow = false;

  @override
  String crateApiUtilsNpubFromHexPubkey({required String hexPubkey}) {
    if (shouldThrow) {
      throw Exception('Invalid hex pubkey');
    }
    return 'npub1test${hexPubkey.substring(0, 10)}';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  group('formatPublicKey', () {
    test('adds space every 5 chars', () {
      expect(formatPublicKey('abcdefghij'), 'abcde fghij ');
    });

    test('leaves remainder without trailing space', () {
      expect(formatPublicKey('abcdefgh'), 'abcde fgh');
    });

    test('returns empty for empty input', () {
      expect(formatPublicKey(''), '');
    });

    test('returns unchanged if less than 5 chars', () {
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

    test('returns two initials for two words', () {
      expect(formatInitials('Alice Bob'), 'AB');
    });

    test('uses only first two words when more provided', () {
      expect(formatInitials('Alice Bob Charlie'), 'AB');
    });

    test('converts to uppercase', () {
      expect(formatInitials('alice bob'), 'AB');
    });

    test('handles multiple consecutive spaces', () {
      expect(formatInitials('John  Doe'), 'JD');
    });

    test('handles leading and trailing whitespace', () {
      expect(formatInitials('  Alice  '), 'A');
    });

    test('returns null for whitespace-only string', () {
      expect(formatInitials('   '), isNull);
    });
  });

  group('npubFromPubkey', () {
    late _MockApi mockApi;

    setUpAll(() {
      mockApi = _MockApi();
      RustLib.initMock(api: mockApi);
    });

    setUp(() {
      mockApi.shouldThrow = false;
    });

    test('returns npub string for valid hex pubkey', () {
      final result = npubFromPubkey('abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890');
      expect(result, isNotNull);
      expect(result, startsWith('npub1'));
      expect(result, contains('abcdef1234'));
    });

    test('returns null when API throws error', () {
      mockApi.shouldThrow = true;
      final result = npubFromPubkey('invalid_pubkey');
      expect(result, isNull);
    });

    test('handles empty string', () {
      mockApi.shouldThrow = true;
      final result = npubFromPubkey('');
      expect(result, isNull);
    });
  });
}
