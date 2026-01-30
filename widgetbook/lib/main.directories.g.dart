// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:sloth_widgetbook/components/wn_avatar.dart'
    as _sloth_widgetbook_components_wn_avatar;
import 'package:sloth_widgetbook/foundations/semantic_colors.dart'
    as _sloth_widgetbook_foundations_semantic_colors;
import 'package:sloth_widgetbook/introduction.dart'
    as _sloth_widgetbook_introduction;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookComponent(
    name: 'Introduction',
    useCases: [
      _widgetbook.WidgetbookUseCase(
        name: 'Resources',
        builder: _sloth_widgetbook_introduction.introduction,
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'components',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'WnAvatarStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All Variants',
            builder: _sloth_widgetbook_components_wn_avatar.allVariants,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'foundations',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'SemanticColorsStory',
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
