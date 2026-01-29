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
  late _MockApi mockApi;

  setUpAll(() {
    mockApi = _MockApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.shouldThrow = false;
  });

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
