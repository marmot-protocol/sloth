import 'dart:io' show Directory;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtilInit;
import 'package:go_router/go_router.dart' show GoRouter;
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show ConsumerStatefulWidget, ConsumerState, ProviderContainer, UncontrolledProviderScope;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'package:sloth/providers/auth_provider.dart' show authProvider;
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/src/rust/api.dart' show createWhitenoiseConfig, initializeWhitenoise;
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  await _initializeWhitenoise();

  final container = ProviderContainer();
  await container.read(authProvider.future);

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

Future<void> _initializeWhitenoise() async {
  final dir = await getApplicationDocumentsDirectory();
  final dataDir = '${dir.path}/whitenoise/data';
  final logsDir = '${dir.path}/whitenoise/logs';
  await Directory(dataDir).create(recursive: true);
  await Directory(logsDir).create(recursive: true);
  final config = await createWhitenoiseConfig(dataDir: dataDir, logsDir: logsDir);
  await initializeWhitenoise(config: config);
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
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Sloth',
          theme: lightTheme,
          darkTheme: darkTheme,
          routerConfig: _router,
        );
      },
    );
  }
}
