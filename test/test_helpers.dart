import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtilInit;
import 'package:flutter_test/flutter_test.dart' show WidgetTester;

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
