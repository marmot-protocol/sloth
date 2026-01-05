import 'dart:io'
    show
        File,
        FileSystemException,
        IOOverrides,
        HttpOverrides,
        HttpClient,
        HttpClientRequest,
        SocketException;

import 'package:flutter/material.dart' show Image, Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sloth/widgets/wn_image_picker.dart' show WnImagePicker;
import '../test_helpers.dart' show mountWidget;

class MockImagePickerPlatform extends ImagePickerPlatform with MockPlatformInterfaceMixin {
  XFile? imageToReturn;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return imageToReturn;
  }
}

class _ErrorFile extends Fake implements File {
  _ErrorFile(this.path);

  @override
  final String path;

  @override
  Never readAsBytesSync() => throw const FileSystemException('Failed to read');
}

class _MockFailingHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    throw const SocketException('Simulated network error');
  }
}

void main() {
  group('WnImagePicker', () {
    group('without imagePath', () {
      testWidgets('shows user icon when displayName is null', (tester) async {
        await mountWidget(const WnImagePicker(), tester);
        expect(find.byKey(const Key('user_icon')), findsOneWidget);
      });

      testWidgets('shows user icon when displayName is empty', (tester) async {
        await mountWidget(const WnImagePicker(displayName: ''), tester);
        expect(find.byKey(const Key('user_icon')), findsOneWidget);
      });

      testWidgets('shows first letter for single word', (tester) async {
        await mountWidget(const WnImagePicker(displayName: 'alice'), tester);
        expect(find.text('A'), findsOneWidget);
      });

      testWidgets('shows two initials for two words', (tester) async {
        await mountWidget(const WnImagePicker(displayName: 'alice bob'), tester);
        expect(find.text('AB'), findsOneWidget);
      });
    });

    group('with invalid imagePath', () {
      testWidgets('shows initials when local file fails to load', (tester) async {
        await IOOverrides.runZoned(
          () async {
            await mountWidget(
              const WnImagePicker(
                imagePath: '/fake/path/image.jpg',
                displayName: 'John Doe',
              ),
              tester,
            );
            await tester.pumpAndSettle();

            expect(find.text('JD'), findsOneWidget);
          },
          createFile: (path) => _ErrorFile(path),
        );
      });

      testWidgets('shows user icon when local file fails and no displayName', (tester) async {
        await IOOverrides.runZoned(
          () async {
            await mountWidget(
              const WnImagePicker(imagePath: '/fake/path/image.jpg'),
              tester,
            );
            await tester.pumpAndSettle();

            expect(find.byKey(const Key('user_icon')), findsOneWidget);
          },
          createFile: (path) => _ErrorFile(path),
        );
      });

      testWidgets('shows initials when URL fails to load', (tester) async {
        await HttpOverrides.runZoned(
          () async {
            await mountWidget(
              const WnImagePicker(
                imagePath: 'https://example.com/image.jpg',
                displayName: 'John Doe',
              ),
              tester,
            );
            await tester.pumpAndSettle();

            expect(find.text('JD'), findsOneWidget);
          },
          createHttpClient: (_) => _MockFailingHttpClient(),
        );
      });

      testWidgets('shows user icon when URL fails and no displayName', (tester) async {
        await HttpOverrides.runZoned(
          () async {
            await mountWidget(
              const WnImagePicker(imagePath: 'https://example.com/image.jpg'),
              tester,
            );
            await tester.pumpAndSettle();

            expect(find.byKey(const Key('user_icon')), findsOneWidget);
          },
          createHttpClient: (_) => _MockFailingHttpClient(),
        );
      });
    });

    group('with valid URL imagePath', () {
      testWidgets('renders Image widget for http URLs', (tester) async {
        await mountWidget(
          const WnImagePicker(
            imagePath: 'http://example.com/image.jpg',
            displayName: 'Test',
          ),
          tester,
        );
        await tester.pump();

        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('renders Image widget for https URLs', (tester) async {
        await mountWidget(
          const WnImagePicker(
            imagePath: 'https://example.com/image.jpg',
            displayName: 'Test',
          ),
          tester,
        );
        await tester.pump();

        expect(find.byType(Image), findsOneWidget);
      });
    });

    group('when enabled', () {
      testWidgets('shows edit icon', (tester) async {
        await mountWidget(const WnImagePicker(), tester);
        expect(find.byKey(const Key('edit_icon')), findsOneWidget);
      });
    });

    group('when disabled', () {
      testWidgets('hides edit icon', (tester) async {
        await mountWidget(const WnImagePicker(disabled: true), tester);
        expect(find.byKey(const Key('edit_icon')), findsNothing);
      });
    });

    group('when image is picked', () {
      late MockImagePickerPlatform mockPicker;

      setUp(() {
        mockPicker = MockImagePickerPlatform();
        ImagePickerPlatform.instance = mockPicker;
      });

      testWidgets('shows animation overlay when changing existing image', (tester) async {
        mockPicker.imageToReturn = XFile('/fake/path/new_image.jpg');

        String? currentPath = '/fake/path/old_image.jpg';
        await mountWidget(
          WnImagePicker(
            imagePath: currentPath,
            onImageSelected: (path) => currentPath = path,
          ),
          tester,
        );

        await tester.tap(find.byKey(const Key('edit_icon')));
        await tester.pump();

        expect(find.byKey(const Key('image_picker_animation')), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 500));
      });

      testWidgets('calls onImageSelected callback with image path', (tester) async {
        const fakePath = '/fake/path/image.jpg';
        mockPicker.imageToReturn = XFile(fakePath);

        String? selectedPath;
        await mountWidget(
          WnImagePicker(
            onImageSelected: (path) => selectedPath = path,
          ),
          tester,
        );

        await tester.tap(find.byKey(const Key('edit_icon')));
        await tester.pump();

        expect(selectedPath, equals(fakePath));

        await tester.pump(const Duration(milliseconds: 500));
      });

      testWidgets('does not call callback when no image is selected', (tester) async {
        mockPicker.imageToReturn = null;

        String? selectedPath;
        await mountWidget(
          WnImagePicker(
            onImageSelected: (path) => selectedPath = path,
          ),
          tester,
        );

        await tester.tap(find.byKey(const Key('edit_icon')));
        await tester.pump();

        expect(selectedPath, isNull);
      });
    });
  });
}
