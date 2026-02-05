import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/models/reply_preview.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import '../test_helpers.dart';

void main() {
  group('ReplyPreview', () {
    test('has authorPubkey', () {
      const ReplyPreview preview = (
        authorPubkey: testPubkeyA,
        authorMetadata: null,
        content: 'hi',
        isNotFound: false,
      );
      expect(preview.authorPubkey, testPubkeyA);
    });

    test('has authorMetadata', () {
      const meta = FlutterMetadata(displayName: 'Author', custom: {});
      const preview = (
        authorPubkey: testPubkeyA,
        authorMetadata: meta,
        content: 'hi',
        isNotFound: false,
      );
      expect(preview.authorMetadata, meta);
    });

    test('allows null authorMetadata', () {
      const preview = (
        authorPubkey: testPubkeyA,
        authorMetadata: null,
        content: 'hi',
        isNotFound: false,
      );
      expect(preview.authorMetadata, isNull);
    });

    test('has content', () {
      const preview = (
        authorPubkey: testPubkeyA,
        authorMetadata: null,
        content: 'Reply text',
        isNotFound: false,
      );
      expect(preview.content, 'Reply text');
    });

    test('has isNotFound boolean', () {
      const preview = (
        authorPubkey: testPubkeyA,
        authorMetadata: null,
        content: 'hi',
        isNotFound: true,
      );
      expect(preview.isNotFound, isTrue);
    });
  });
}
