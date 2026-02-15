import 'package:flutter/material.dart';
import 'package:whitenoise/src/rust/api/media_files.dart';

enum MediaUploadStatus { uploading, uploaded, error }

typedef MediaUploadItem = ({
  String filePath,
  MediaUploadStatus status,
  MediaFile? file,
  VoidCallback? retry,
});
