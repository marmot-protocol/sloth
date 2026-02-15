import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whitenoise/services/foreground_service.dart';

final foregroundServiceProvider = Provider<ForegroundService>((ref) {
  return ForegroundService();
});
