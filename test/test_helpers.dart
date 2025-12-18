import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtilInit;
import 'package:flutter_test/flutter_test.dart' show WidgetTester;

Future<T Function()> mountHook<T>(
  WidgetTester tester,
  T Function() useHook,
) async {
  late T result;
  await tester.pumpWidget(
    MaterialApp(home: _HookTestWidget<T>(useHook, (r) => result = r)),
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
  final widget = ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, _) {
      return MaterialApp(
        home: Scaffold(body: child),
      );
    },
  );
  await tester.pumpWidget(widget);
}

Future<void> mountStackedWidget(Widget child, WidgetTester tester) async {
  final widget = ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, _) {
      return MaterialApp(
        home: Scaffold(body: Stack(children: [child])),
      );
    },
  );
  await tester.pumpWidget(widget);
}
