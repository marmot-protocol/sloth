import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/models/reply_preview.dart';
import 'package:whitenoise/src/rust/api/metadata.dart';
import '../test_helpers.dart';

void main() {
  group('ReplyPreview', () {
    test('has messageId', () {
      const ReplyPreview preview = (
        messageId: 'msg-123',
        authorPubkey: testPubkeyA,
        authorMetadata: null,
        content: 'hi',
        hasMedia: false,
        isNotFound: false,
      );
      expect(preview.messageId, 'msg-123');
    });

    test('has authorPubkey', () {
      const ReplyPreview preview = (
        messageId: 'msg-123',
        authorPubkey: testPubkeyA,
        authorMetadata: null,
        content: 'hi',
        hasMedia: false,
        isNotFound: false,
      );
      expect(preview.authorPubkey, testPubkeyA);
    });

    test('has authorMetadata', () {
      const meta = FlutterMetadata(displayName: 'Author', custom: {});
      const preview = (
        messageId: 'msg-123',
        authorPubkey: testPubkeyA,
        authorMetadata: meta,
        content: 'hi',
        hasMedia: false,
        isNotFound: false,
      );
      expect(preview.authorMetadata, meta);
    });

    test('allows null authorMetadata', () {
      const preview = (
        messageId: 'msg-123',
        authorPubkey: testPubkeyA,
        authorMetadata: null,
        content: 'hi',
        hasMedia: false,
        isNotFound: false,
      );
      expect(preview.authorMetadata, isNull);
    });

    test('has content', () {
      const preview = (
        messageId: 'msg-123',
        authorPubkey: testPubkeyA,
        authorMetadata: null,
        content: 'Reply text',
        hasMedia: false,
        isNotFound: false,
      );
      expect(preview.content, 'Reply text');
    });

    test('has hasMedia', () {
      const preview = (
        messageId: 'msg-123',
        authorPubkey: testPubkeyA,
        authorMetadata: null,
        content: 'hi',
        hasMedia: true,
        isNotFound: false,
      );
      expect(preview.hasMedia, isTrue);
    });

    test('has isNotFound boolean', () {
      const preview = (
        messageId: 'msg-123',
        authorPubkey: testPubkeyA,
        authorMetadata: null,
        content: 'hi',
        hasMedia: false,
        isNotFound: true,
      );
      expect(preview.isNotFound, isTrue);
    });
  });
}
