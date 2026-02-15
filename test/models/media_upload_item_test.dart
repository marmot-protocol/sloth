import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/models/media_upload_item.dart';
import 'package:whitenoise/src/rust/api/media_files.dart';

import '../test_helpers.dart';

MediaFile _mediaFile({String id = 'media1'}) => MediaFile(
  id: id,
  mlsGroupId: testGroupId,
  accountPubkey: testPubkeyA,
  filePath: '/path/to/file.jpg',
  originalFileHash: 'hash123',
  encryptedFileHash: 'encrypted123',
  mimeType: 'image/jpeg',
  mediaType: 'image',
  blossomUrl: 'https://example.com/media',
  nostrKey: 'nostr123',
  createdAt: DateTime(2024),
);

void main() {
  group('MediaUploadStatus', () {
    test('has uploading state', () {
      expect(MediaUploadStatus.uploading, isNotNull);
    });

    test('has uploaded state', () {
      expect(MediaUploadStatus.uploaded, isNotNull);
    });

    test('has error state', () {
      expect(MediaUploadStatus.error, isNotNull);
    });

    test('has exactly 3 values', () {
      expect(MediaUploadStatus.values.length, 3);
    });
  });

  group('MediaUploadItem', () {
    test('can be created with uploading status', () {
      final item = (
        filePath: '/path/to/image.jpg',
        status: MediaUploadStatus.uploading,
        file: null,
        retry: null,
      );

      expect(item.filePath, '/path/to/image.jpg');
      expect(item.status, MediaUploadStatus.uploading);
      expect(item.file, isNull);
      expect(item.retry, isNull);
    });

    test('can be created with uploaded status and MediaFile', () {
      final mediaFile = _mediaFile();
      final item = (
        filePath: '/path/to/image.jpg',
        status: MediaUploadStatus.uploaded,
        file: mediaFile,
        retry: null,
      );

      expect(item.status, MediaUploadStatus.uploaded);
      expect(item.file, mediaFile);
    });

    test('can be created with error status and retry callback', () {
      var retryCalled = false;
      final item = (
        filePath: '/path/to/image.jpg',
        status: MediaUploadStatus.error,
        file: null,
        retry: () => retryCalled = true,
      );

      expect(item.status, MediaUploadStatus.error);
      expect(item.retry, isNotNull);
      item.retry();
      expect(retryCalled, isTrue);
    });

    test('filePath is always available regardless of status', () {
      const path = '/path/to/image.jpg';

      final uploading = (
        filePath: path,
        status: MediaUploadStatus.uploading,
        file: null,
        retry: null,
      );

      final uploaded = (
        filePath: path,
        status: MediaUploadStatus.uploaded,
        file: _mediaFile(),
        retry: null,
      );

      final error = (
        filePath: path,
        status: MediaUploadStatus.error,
        file: null,
        retry: () {},
      );

      expect(uploading.filePath, path);
      expect(uploaded.filePath, path);
      expect(error.filePath, path);
    });
  });
}
