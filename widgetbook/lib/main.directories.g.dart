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
import 'package:sloth_widgetbook/components/wn_avatar.dart'
    as _sloth_widgetbook_components_wn_avatar;
import 'package:sloth_widgetbook/components/wn_copy_card.dart'
    as _sloth_widgetbook_components_wn_copy_card;
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
            name: 'WnAvatarStory',
            builder: _sloth_widgetbook_components_wn_avatar.wnAvatarShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnButtonStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Button',
            builder: _sloth_widgetbook_components_buttons.wnButtonShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnCalloutStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Callout',
            builder: _sloth_widgetbook_components_feedback.wnCalloutShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnCopyCardStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'WnCopyCardStory',
            builder:
                _sloth_widgetbook_components_wn_copy_card.wnCopyCardShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnIconStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Icons',
            builder: _sloth_widgetbook_components_icons.wnIconShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnInputPasswordStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Password Input',
            builder:
                _sloth_widgetbook_components_inputs.wnInputPasswordShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnInputStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Text Input',
            builder: _sloth_widgetbook_components_inputs.wnInputShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnInputTextAreaStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Text Area',
            builder:
                _sloth_widgetbook_components_inputs.wnInputTextAreaShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnMenuItemStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Menu Item',
            builder: _sloth_widgetbook_components_menu.wnMenuItemShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnMenuStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Menu Container',
            builder: _sloth_widgetbook_components_menu.wnMenuShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnOverlayStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Overlay',
            builder: _sloth_widgetbook_components_structure.wnOverlayShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnScrollEdgeEffectStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Scroll Edge Effect',
            builder: _sloth_widgetbook_components_structure
                .wnScrollEdgeEffectShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnSeparatorStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Separator',
            builder: _sloth_widgetbook_components_structure.wnSeparatorShowcase,
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
