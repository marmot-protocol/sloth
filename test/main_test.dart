import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show AsyncData, ProviderContainer, ProviderScope;
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/main.dart';
import 'package:whitenoise/providers/auth_provider.dart';
import 'package:whitenoise/providers/theme_provider.dart';
import 'package:whitenoise/src/rust/api.dart' as rust_api;
import 'package:whitenoise/src/rust/frb_generated.dart';

import 'mocks/mock_secure_storage.dart';
import 'mocks/mock_wn_api.dart';
import 'test_helpers.dart';

({Directory tempDir, void Function() reset}) _mockPathProvider() {
  final tempDir = Directory.systemTemp.createTempSync('whitenoise_test');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    },
  );

  return (
    tempDir: tempDir,
    reset: () {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    },
  );
}

void Function() _mockSecureStorage() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (call) async {
      if (call.method == 'read') {
        return null;
      }
      return null;
    },
  );

  return () {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      null,
    );
  };
}

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async {
    state = const AsyncData(testPubkeyA);
    return testPubkeyA;
  }
}

class _MockThemeNotifier extends ThemeNotifier {
  ThemeMode _mode = ThemeMode.system;

  @override
  Future<ThemeMode> build() async {
    state = AsyncData(_mode);
    return _mode;
  }

  void setMode(ThemeMode mode) {
    _mode = mode;
    state = AsyncData(mode);
  }
}

class _MockInitApi extends MockWnApi {
  String? createdConfigDataDir;
  String? createdConfigLogsDir;
  rust_api.WhitenoiseConfig? initializedConfig;

  @override
  Future<rust_api.WhitenoiseConfig> crateApiCreateWhitenoiseConfig({
    required String dataDir,
    required String logsDir,
  }) async {
    createdConfigDataDir = dataDir;
    createdConfigLogsDir = logsDir;
    return rust_api.WhitenoiseConfig(dataDir: dataDir, logsDir: logsDir);
  }

  @override
  Future<void> crateApiInitializeWhitenoise({
    required rust_api.WhitenoiseConfig config,
  }) async {
    initializedConfig = config;
  }

  @override
  void reset() {
    super.reset();
    createdConfigDataDir = null;
    createdConfigLogsDir = null;
    initializedConfig = null;
  }
}

void main() {
  late _MockInitApi mockApi;

  setUpAll(() {
    mockApi = _MockInitApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.reset();
  });

  group('MyApp', () {
    late _MockThemeNotifier mockTheme;

    Future<void> pumpMyApp(WidgetTester tester) async {
      setUpTestView(tester);
      mockTheme = _MockThemeNotifier();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _MockAuthNotifier()),
            themeProvider.overrideWith(() => mockTheme),
            secureStorageProvider.overrideWithValue(MockSecureStorage()),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('has app title', (tester) async {
      await pumpMyApp(tester);
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.title, 'White Noise');
    });

    testWidgets('defaults to system theme mode', (tester) async {
      await pumpMyApp(tester);
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.system);
    });

    testWidgets('responds to theme mode changes', (tester) async {
      await pumpMyApp(tester);

      mockTheme.setMode(ThemeMode.dark);
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
    });

    testWidgets('has routes configured', (tester) async {
      await pumpMyApp(tester);
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.routerConfig, isNotNull);
    });
  });

  group('initializeAppContainer', () {
    late ({Directory tempDir, void Function() reset}) pathProvider;
    late void Function() resetSecureStorage;

    setUp(() {
      pathProvider = _mockPathProvider();
      resetSecureStorage = _mockSecureStorage();
    });

    tearDown(() {
      pathProvider.reset();
      resetSecureStorage();
    });

    test('creates data directory', () async {
      await initializeAppContainer();

      expect(Directory('${pathProvider.tempDir.path}/whitenoise/data').existsSync(), isTrue);
    });

    test('creates logs directory', () async {
      await initializeAppContainer();

      expect(Directory('${pathProvider.tempDir.path}/whitenoise/logs').existsSync(), isTrue);
    });

    test('calls createWhitenoiseConfig with data directory', () async {
      await initializeAppContainer();

      expect(mockApi.createdConfigDataDir, '${pathProvider.tempDir.path}/whitenoise/data');
    });

    test('calls createWhitenoiseConfig with logs directory', () async {
      await initializeAppContainer();

      expect(mockApi.createdConfigLogsDir, '${pathProvider.tempDir.path}/whitenoise/logs');
    });

    test('calls initializeWhitenoise with config', () async {
      await initializeAppContainer();

      expect(mockApi.initializedConfig, isNotNull);
    });

    test('returns a ProviderContainer', () async {
      final container = await initializeAppContainer();

      expect(container, isA<ProviderContainer>());
    });

    test('awaits authProvider', () async {
      final container = await initializeAppContainer();

      expect(container.read(authProvider), isA<AsyncData>());
    });
  });
}
