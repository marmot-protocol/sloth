import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/utils/mime_type.dart' show getMimeType;

void main() {
  group('getMimeType', () {
    group('when file does not exist', () {
      test('returns null', () async {
        const nonExistentPath = '/path/to/nonexistent/file.jpg';

        final result = await getMimeType(nonExistentPath);

        expect(result, isNull);
      });
    });

    group('with empty path', () {
      test('returns null', () async {
        const emptyPath = '';
        final result = await getMimeType(emptyPath);
        expect(result, isNull);
      });
    });

    group('when file exists', () {
      late File jpegFile;
      late File pngFile;

      setUp(() async {
        final tempDir = await Directory.systemTemp.createTemp('image_utils_test');
        jpegFile = File('${tempDir.path}/test.jpg');
        pngFile = File('${tempDir.path}/test.png');
        const jpegHeader = [0xFF, 0xD8, 0xFF, 0xE0];
        const pngHeader = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
        await jpegFile.writeAsBytes(jpegHeader);
        await pngFile.writeAsBytes(pngHeader);
      });

      test('returns correct MIME type for JPEG file', () async {
        final mimeType = await getMimeType(jpegFile.path);
        expect(mimeType, equals('image/jpeg'));
      });

      test('returns correct MIME type for PNG file', () async {
        final mimeType = await getMimeType(pngFile.path);
        expect(mimeType, equals('image/png'));
      });
    });
  });
}
