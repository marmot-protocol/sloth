import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Consumer, ProviderScope;
import 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtilInit;
import 'package:flutter_test/flutter_test.dart' show WidgetTester, addTearDown;
import 'package:sloth/l10n/generated/app_localizations.dart';
import 'package:sloth/routes.dart';

const testDesignSize = Size(390, 844);

void setUpTestView(WidgetTester tester) {
  tester.view.physicalSize = testDesignSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

const _localizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Future<void> mountTestApp(
  WidgetTester tester, {
  List overrides = const [],
}) async {
  setUpTestView(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...overrides],
      child: ScreenUtilInit(
        designSize: testDesignSize,
        builder: (_, _) => Consumer(
          builder: (context, ref, _) {
            return MaterialApp.router(
              routerConfig: Routes.build(ref),
              locale: const Locale('en'),
              localizationsDelegates: _localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      ),
    ),
  );
}

Future<T Function()> mountHook<T>(
  WidgetTester tester,
  T Function() useHook,
) async {
  late T result;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: _localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _HookTestWidget<T>(useHook, (r) => result = r),
    ),
  );
  return () => result;
}

class _HookTestWidget<T> extends HookWidget {
  const _HookTestWidget(this.useHook, this.onBuild);
  final T Function() useHook;
  final void Function(T) onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild(useHook());
    return const SizedBox();
  }
}

Future<void> mountWidget(Widget child, WidgetTester tester) async {
  setUpTestView(tester);
  final widget = ProviderScope(
    child: ScreenUtilInit(
      designSize: testDesignSize,
      builder: (_, _) {
        return MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: _localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: child),
        );
      },
    ),
  );
  await tester.pumpWidget(widget);
}

Future<void> mountStackedWidget(Widget child, WidgetTester tester) async {
  setUpTestView(tester);
  final widget = ScreenUtilInit(
    designSize: testDesignSize,
    builder: (_, _) {
      return MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: _localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Stack(children: [child])),
      );
    },
  );
  await tester.pumpWidget(widget);
}
