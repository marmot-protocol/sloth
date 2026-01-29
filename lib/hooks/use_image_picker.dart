import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;

Future<void> Function() useImagePicker({
  required void Function(String path) onImageSelected,
}) {
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    onImageSelected(image.path);
  }

  return pickImage;
}
