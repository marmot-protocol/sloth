import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sloth/hooks/use_image_picker.dart';

class MockImagePickerPlatform extends ImagePickerPlatform with MockPlatformInterfaceMixin {
  XFile? imageToReturn;
  int pickImageCallCount = 0;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    pickImageCallCount++;
    return imageToReturn;
  }
}

void main() {
  late MockImagePickerPlatform mockPicker;

  setUp(() {
    mockPicker = MockImagePickerPlatform();
    ImagePickerPlatform.instance = mockPicker;
  });

  group('useImagePicker', () {
    testWidgets('calls onImageSelected when image is picked', (tester) async {
      const fakePath = '/fake/path/image.jpg';
      mockPicker.imageToReturn = XFile(fakePath);

      String? selectedPath;
      late Future<void> Function() pickImage;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              pickImage = useImagePicker(
                onImageSelected: (path) => selectedPath = path,
              );
              return ElevatedButton(
                onPressed: pickImage,
                child: const Text('pick'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('pick'));
      await tester.pump();

      expect(selectedPath, equals(fakePath));
      expect(mockPicker.pickImageCallCount, 1);
    });

    testWidgets('does not call onImageSelected when no image is selected', (tester) async {
      mockPicker.imageToReturn = null;

      String? selectedPath;
      late Future<void> Function() pickImage;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              pickImage = useImagePicker(
                onImageSelected: (path) => selectedPath = path,
              );
              return ElevatedButton(
                onPressed: pickImage,
                child: const Text('pick'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('pick'));
      await tester.pump();

      expect(selectedPath, isNull);
    });
  });
}
