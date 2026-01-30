import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'main.directories.g.dart';

@widgetbook.App()
void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      initialRoute: '?path=introduction/resources',
      addons: [
        ViewportAddon(Viewports.all),
        ThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: lightTheme),
            WidgetbookTheme(name: 'Dark', data: darkTheme),
          ],
          themeBuilder: (context, theme, child) {
            return Theme(data: theme, child: child);
          },
        ),
        BuilderAddon(
          name: 'ScreenUtil',
          builder: (context, child) {
            return ScreenUtilInit(
              designSize: const Size(390, 844),
              minTextAdapt: true,
              splitScreenMode: true,
              useInheritedMediaQuery: true,
              builder: (context, child) {
                ScreenUtil.configure(data: MediaQuery.of(context));
                return child!;
              },
              child: child,
            );
          },
        ),
      ],
      directories: directories,
    );
  }
}
