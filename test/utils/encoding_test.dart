import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/utils/encoding.dart';

class _MockApi implements RustLibApi {
  bool shouldThrowNpubFromHex = false;
  bool shouldThrowHexFromNpub = false;

  @override
  String crateApiUtilsNpubFromHexPubkey({required String hexPubkey}) {
    if (shouldThrowNpubFromHex) {
      throw Exception('Invalid hex pubkey');
    }
    return 'npub1test${hexPubkey.substring(0, 10)}';
  }

  @override
  String crateApiUtilsHexPubkeyFromNpub({required String npub}) {
    if (shouldThrowHexFromNpub) {
      throw Exception('Invalid npub');
    }
    return 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890';
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
    mockApi.shouldThrowNpubFromHex = false;
    mockApi.shouldThrowHexFromNpub = false;
  });

  group('npubFromHex', () {
    test('returns npub string for valid hex pubkey', () {
      final result = npubFromHex(
        'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
      );
      expect(result, isNotNull);
      expect(result, startsWith('npub1'));
      expect(result, contains('abcdef1234'));
    });

    test('returns null when API throws error', () {
      mockApi.shouldThrowNpubFromHex = true;
      final result = npubFromHex('invalid_pubkey');
      expect(result, isNull);
    });
  });

  group('hexFromNpub', () {
    test('returns hex string for valid npub', () {
      final result = hexFromNpub('npub1abc123');
      expect(result, isNotNull);
      expect(result, hasLength(64));
    });

    test('returns null when API throws error', () {
      mockApi.shouldThrowHexFromNpub = true;
      final result = hexFromNpub('invalid_npub');
      expect(result, isNull);
    });
  });
}
