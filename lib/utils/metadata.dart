import 'package:sloth/src/rust/api/metadata.dart';

String? presentName(FlutterMetadata? metadata) {
  if (metadata == null) return null;
  if (metadata.displayName?.isNotEmpty == true) return metadata.displayName;
  if (metadata.name?.isNotEmpty == true) return metadata.name;
  return null;
}
