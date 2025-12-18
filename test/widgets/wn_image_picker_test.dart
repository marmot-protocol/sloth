import 'dart:io' show File, FileSystemException, IOOverrides;

import 'package:flutter/material.dart' show Key;
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
      testWidgets('shows initials when image fails to load', (tester) async {
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

      testWidgets('shows user icon when image fails and no displayName', (tester) async {
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
