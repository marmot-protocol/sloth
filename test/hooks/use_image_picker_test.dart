import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:whitenoise/hooks/use_image_picker.dart';

class MockImagePickerPlatform extends ImagePickerPlatform with MockPlatformInterfaceMixin {
  XFile? imageToReturn;
  int pickImageCallCount = 0;
  Exception? exceptionToThrow;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    pickImageCallCount++;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return imageToReturn;
  }
}

void main() {
  late MockImagePickerPlatform mockPicker;
  late ImagePickerPlatform originalPlatform;

  setUp(() {
    originalPlatform = ImagePickerPlatform.instance;
    mockPicker = MockImagePickerPlatform();
    ImagePickerPlatform.instance = mockPicker;
  });

  tearDown(() {
    ImagePickerPlatform.instance = originalPlatform;
  });

  group('useImagePicker', () {
    testWidgets('calls onImageSelected when image is picked', (tester) async {
      const fakePath = '/fake/path/image.jpg';
      mockPicker.imageToReturn = XFile(fakePath);

      String? selectedPath;
      late ImagePickerState state;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              state = useImagePicker(
                onImageSelected: (path) => selectedPath = path,
              );
              return ElevatedButton(
                onPressed: state.pickImage,
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
      late ImagePickerState state;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              state = useImagePicker(
                onImageSelected: (path) => selectedPath = path,
              );
              return ElevatedButton(
                onPressed: state.pickImage,
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

    testWidgets('sets error state when picker throws exception', (tester) async {
      mockPicker.exceptionToThrow = Exception('Permission denied');

      String? selectedPath;
      String? capturedError;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final state = useImagePicker(
                onImageSelected: (path) => selectedPath = path,
              );
              capturedError = state.error;
              return ElevatedButton(
                onPressed: state.pickImage,
                child: const Text('pick'),
              );
            },
          ),
        ),
      );

      expect(capturedError, isNull);

      await tester.tap(find.text('pick'));
      await tester.pump();

      expect(selectedPath, isNull);
      expect(capturedError, contains('Permission denied'));
    });

    testWidgets('clearError resets error to null', (tester) async {
      mockPicker.exceptionToThrow = Exception('Permission denied');

      String? capturedError;
      late void Function() clearError;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final state = useImagePicker(
                onImageSelected: (_) {},
              );
              capturedError = state.error;
              clearError = state.clearError;
              return ElevatedButton(
                onPressed: state.pickImage,
                child: const Text('pick'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('pick'));
      await tester.pump();

      expect(capturedError, contains('Permission denied'));

      clearError();
      await tester.pump();

      expect(capturedError, isNull);
    });

    testWidgets('error is cleared before each pick attempt', (tester) async {
      mockPicker.exceptionToThrow = Exception('Permission denied');

      String? capturedError;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final state = useImagePicker(
                onImageSelected: (_) {},
              );
              capturedError = state.error;
              return ElevatedButton(
                onPressed: state.pickImage,
                child: const Text('pick'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('pick'));
      await tester.pump();

      expect(capturedError, contains('Permission denied'));

      mockPicker.exceptionToThrow = null;
      mockPicker.imageToReturn = XFile('/path/to/image.jpg');

      await tester.tap(find.text('pick'));
      await tester.pump();

      expect(capturedError, isNull);
    });
  });
}
