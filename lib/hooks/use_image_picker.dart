import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:logging/logging.dart';

final _logger = Logger('useImagePicker');

typedef ImagePickerState = ({
  Future<void> Function() pickImage,
  String? error,
  void Function() clearError,
});

ImagePickerState useImagePicker({
  required void Function(String path) onImageSelected,
}) {
  final error = useState<String?>(null);

  Future<void> pickImage() async {
    error.value = null;
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      onImageSelected(image.path);
    } catch (e, stackTrace) {
      _logger.severe('Failed to pick image', e, stackTrace);
      error.value = e.toString();
    }
  }

  void clearError() {
    error.value = null;
  }

  return (
    pickImage: pickImage,
    error: error.value,
    clearError: clearError,
  );
}
