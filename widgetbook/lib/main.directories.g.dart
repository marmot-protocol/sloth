// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:sloth_widgetbook/components/buttons.dart'
    as _sloth_widgetbook_components_buttons;
import 'package:sloth_widgetbook/components/feedback.dart'
    as _sloth_widgetbook_components_feedback;
import 'package:sloth_widgetbook/components/icons.dart'
    as _sloth_widgetbook_components_icons;
import 'package:sloth_widgetbook/components/inputs.dart'
    as _sloth_widgetbook_components_inputs;
import 'package:sloth_widgetbook/components/menu.dart'
    as _sloth_widgetbook_components_menu;
import 'package:sloth_widgetbook/components/structure.dart'
    as _sloth_widgetbook_components_structure;
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
  _widgetbook.WidgetbookFolder(
    name: 'widgets',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'WnButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _sloth_widgetbook_components_buttons.wnButtonUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnCallout',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _sloth_widgetbook_components_feedback.wnCalloutUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnIcon',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _sloth_widgetbook_components_icons.wnIconUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnInput',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _sloth_widgetbook_components_inputs.wnInputUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnInputPassword',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Password',
            builder: _sloth_widgetbook_components_inputs.wnInputPasswordUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnInputTextArea',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Text Area',
            builder: _sloth_widgetbook_components_inputs.wnInputTextAreaUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnMenu',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Menu Container',
            builder: _sloth_widgetbook_components_menu.wnMenuUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnMenuItem',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _sloth_widgetbook_components_menu.wnMenuItemUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnOverlay',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _sloth_widgetbook_components_structure.wnOverlayUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnScrollEdgeEffect',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _sloth_widgetbook_components_structure
                .wnScrollEdgeEffectUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnSeparator',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _sloth_widgetbook_components_structure.wnSeparatorUseCase,
          ),
        ],
      ),
    ],
  ),
];
