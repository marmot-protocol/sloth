import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/services/foreground_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ForegroundService', () {
    test('disabled service stop is no-op', () async {
      final service = ForegroundService(enabled: false);
      // Should not throw
      await service.stop();
    });

    test('disabled service isRunning returns false', () async {
      final service = ForegroundService(enabled: false);
      final isRunning = await service.isRunning;
      expect(isRunning, isFalse);
    });

    test('disabled service requestBatteryOptimizationExemption is no-op', () async {
      final service = ForegroundService(enabled: false);
      // Should not throw
      await service.requestBatteryOptimizationExemption();
    });
  });
}
