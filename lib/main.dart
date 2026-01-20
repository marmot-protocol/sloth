import 'dart:io' show Directory;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtilInit;
import 'package:go_router/go_router.dart' show GoRouter;
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show ConsumerStatefulWidget, ConsumerState, ProviderContainer, UncontrolledProviderScope;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'package:sloth/providers/auth_provider.dart' show authProvider;
import 'package:sloth/providers/theme_provider.dart' show themeProvider;
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/src/rust/api.dart' as rust_api;
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  final container = await initializeAppContainer();
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

Future<ProviderContainer> initializeAppContainer() async {
  final dir = await getApplicationDocumentsDirectory();
  final dataDir = '${dir.path}/whitenoise/data';
  final logsDir = '${dir.path}/whitenoise/logs';
  await Directory(dataDir).create(recursive: true);
  await Directory(logsDir).create(recursive: true);
  final config = await rust_api.createWhitenoiseConfig(dataDir: dataDir, logsDir: logsDir);
  await rust_api.initializeWhitenoise(config: config);

  final container = ProviderContainer();
  await container.read(authProvider.future);
  return container;
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = Routes.build(ref);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider).value ?? ThemeMode.system;

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Sloth',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}
