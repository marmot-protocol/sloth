import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/utils/metadata.dart';

void main() {
  group('presentName', () {
    test('returns null when metadata is null', () {
      expect(presentName(null), isNull);
    });

    test('returns displayName when non-empty', () {
      const metadata = FlutterMetadata(
        displayName: 'Alice',
        name: 'alice123',
        custom: {},
      );
      expect(presentName(metadata), equals('Alice'));
    });

    test('returns name when displayName is null', () {
      const metadata = FlutterMetadata(
        name: 'alice123',
        custom: {},
      );
      expect(presentName(metadata), equals('alice123'));
    });

    test('returns name when displayName is empty', () {
      const metadata = FlutterMetadata(
        displayName: '',
        name: 'alice123',
        custom: {},
      );
      expect(presentName(metadata), equals('alice123'));
    });

    test('returns null when both displayName and name are null', () {
      const metadata = FlutterMetadata(custom: {});
      expect(presentName(metadata), isNull);
    });

    test('returns null when both displayName and name are empty', () {
      const metadata = FlutterMetadata(
        displayName: '',
        name: '',
        custom: {},
      );
      expect(presentName(metadata), isNull);
    });
  });
}
