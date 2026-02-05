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
import 'package:sloth_widgetbook/components/chat_status.dart'
    as _sloth_widgetbook_components_chat_status;
import 'package:sloth_widgetbook/components/feedback.dart'
    as _sloth_widgetbook_components_feedback;
import 'package:sloth_widgetbook/components/icons.dart'
    as _sloth_widgetbook_components_icons;
import 'package:sloth_widgetbook/components/inputs.dart'
    as _sloth_widgetbook_components_inputs;
import 'package:sloth_widgetbook/components/key_package_card.dart'
    as _sloth_widgetbook_components_key_package_card;
import 'package:sloth_widgetbook/components/list.dart'
    as _sloth_widgetbook_components_list;
import 'package:sloth_widgetbook/components/menu.dart'
    as _sloth_widgetbook_components_menu;
import 'package:sloth_widgetbook/components/spinner.dart'
    as _sloth_widgetbook_components_spinner;
import 'package:sloth_widgetbook/components/structure.dart'
    as _sloth_widgetbook_components_structure;
import 'package:sloth_widgetbook/components/timestamp.dart'
    as _sloth_widgetbook_components_timestamp;
import 'package:sloth_widgetbook/components/tooltip.dart'
    as _sloth_widgetbook_components_tooltip;
import 'package:sloth_widgetbook/components/wn_avatar.dart'
    as _sloth_widgetbook_components_wn_avatar;
import 'package:sloth_widgetbook/components/wn_copy_card.dart'
    as _sloth_widgetbook_components_wn_copy_card;
import 'package:sloth_widgetbook/foundations/semantic_colors.dart'
    as _sloth_widgetbook_foundations_semantic_colors;
import 'package:sloth_widgetbook/foundations/typography.dart'
    as _sloth_widgetbook_foundations_typography;
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
            name: 'Avatar',
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
        name: 'WnChatStatusStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Chat Status',
            builder:
                _sloth_widgetbook_components_chat_status.wnChatStatusShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnCopyCardStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Copy Card',
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
        name: 'WnKeyPackageCardStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Key Package Card',
            builder: _sloth_widgetbook_components_key_package_card
                .wnKeyPackageCardShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnListStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'List',
            builder: _sloth_widgetbook_components_list.wnListShowcase,
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
      _widgetbook.WidgetbookComponent(
        name: 'WnSpinnerStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Spinner',
            builder: _sloth_widgetbook_components_spinner.wnSpinnerShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnTimestampStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Timestamp',
            builder: _sloth_widgetbook_components_timestamp.wnTimestampShowcase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WnTooltipStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Tooltip',
            builder: _sloth_widgetbook_components_tooltip.wnTooltipShowcase,
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
      _widgetbook.WidgetbookComponent(
        name: 'TypographyStory',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Typography',
            builder: _sloth_widgetbook_foundations_typography.allTypography,
          ),
        ],
      ),
    ],
  ),
];
