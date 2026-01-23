// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
<<<<<<< HEAD
import 'package:sloth_widgetbook/foundations/colors.dart'
    as _sloth_widgetbook_foundations_colors;
=======
import 'package:sloth_widgetbook/foundations/semantic_colors.dart'
    as _sloth_widgetbook_foundations_semantic_colors;
import 'package:sloth_widgetbook/introduction.dart'
    as _sloth_widgetbook_introduction;
>>>>>>> bb3bfc4 (fixup! docs: add colors story)
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'foundations',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'Semantic Colors',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Semantic Colors',
            builder: _sloth_widgetbook_foundations_semantic_colors.allColors,
          ),
        ],
      ),
    ],
  ),
];
