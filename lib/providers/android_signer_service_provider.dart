import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sloth/services/android_signer_service.dart';

final androidSignerServiceProvider = Provider<AndroidSignerService>((ref) {
  return AndroidSignerService(platformIsAndroid: Platform.isAndroid);
});
