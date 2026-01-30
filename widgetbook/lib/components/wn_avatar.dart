import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _sampleImageUrl = 'https://www.whitenoise.chat/images/mask-man.webp';

class WnAvatarStory extends StatelessWidget {
  const WnAvatarStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'All Variants', type: WnAvatarStory)
Widget allVariants(BuildContext context) {
  final colors = context.colors;

  final displayName = context.knobs.stringOrNull(
    label: 'Display Name',
    initialValue: 'John Doe',
  );

  final hasImage = context.knobs.boolean(
    label: 'Has Image',
    initialValue: false,
  );

  final size = context.knobs.object.dropdown<WnAvatarSize>(
    label: 'Size',
    options: WnAvatarSize.values,
    initialOption: WnAvatarSize.large,
    labelBuilder: (size) => size.name,
  );

  final color = context.knobs.objectOrNull.dropdown<AccentColor>(
    label: 'Color',
    options: AccentColor.values,
    initialOption: AccentColor.blue,
    labelBuilder: (color) => color.name,
  );

  final editable = context.knobs.boolean(
    label: 'Editable',
    initialValue: false,
  );

  return Scaffold(
    backgroundColor: colors.backgroundPrimary,
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avatar',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colors.backgroundContentPrimary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Playground',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.backgroundContentPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: WnAvatar(
              displayName: displayName,
              pictureUrl: hasImage ? _sampleImageUrl : null,
              size: size,
              color: color,
              onEditTap: editable ? () {} : null,
            ),
          ),
          const SizedBox(height: 32),
          Divider(color: colors.borderTertiary),
          const SizedBox(height: 32),
          Text(
            'All Variants',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.backgroundContentPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Image avatars use neutral border. Initials/icon avatars use accent colors.',
            style: TextStyle(
              fontSize: 14,
              color: colors.backgroundContentSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _buildHeader(colors),
          const SizedBox(height: 16),
          _buildImageRow(colors),
          const SizedBox(height: 8),
          ...AccentColor.values.expand(
            (color) => [_buildInitialsRow(color, colors), _buildIconRow(color)],
          ),
        ],
      ),
    ),
  );
}

Widget _buildHeader(SemanticColors colors) {
  return Row(
    children: [
      SizedBox(
        width: 80,
        child: Text(
          'Color',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.backgroundContentSecondary,
          ),
        ),
      ),
      Expanded(
        child: Text(
          'Small (48px)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.backgroundContentSecondary,
          ),
        ),
      ),
      Expanded(
        child: Text(
          'Medium (56px)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.backgroundContentSecondary,
          ),
        ),
      ),
      Expanded(
        child: Text(
          'Large (96px)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.backgroundContentSecondary,
          ),
        ),
      ),
      Expanded(
        child: Text(
          'Editable & Large (96px)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.backgroundContentSecondary,
          ),
        ),
      ),
    ],
  );
}

Widget _buildInitialsRow(AccentColor color, SemanticColors colors) {
  final colorName = color.name[0].toUpperCase() + color.name.substring(1);

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            colorName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.backgroundContentPrimary,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: WnAvatar(
              displayName: 'A',
              color: color,
              size: WnAvatarSize.small,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: WnAvatar(
              displayName: 'A',
              color: color,
              size: WnAvatarSize.medium,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: WnAvatar(
              displayName: 'A',
              color: color,
              size: WnAvatarSize.large,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: WnAvatar(
              displayName: 'A',
              color: color,
              size: WnAvatarSize.large,
              onEditTap: () {},
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildIconRow(AccentColor color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        const SizedBox(width: 80),
        Expanded(
          child: Center(
            child: WnAvatar(color: color, size: WnAvatarSize.small),
          ),
        ),
        Expanded(
          child: Center(
            child: WnAvatar(color: color, size: WnAvatarSize.medium),
          ),
        ),
        Expanded(
          child: Center(
            child: WnAvatar(color: color, size: WnAvatarSize.large),
          ),
        ),
        Expanded(
          child: Center(
            child: WnAvatar(
              color: color,
              size: WnAvatarSize.large,
              onEditTap: () {},
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildImageRow(SemanticColors colors) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            'Image',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.backgroundContentPrimary,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: WnAvatar(
              pictureUrl: _sampleImageUrl,
              displayName: 'A',
              size: WnAvatarSize.small,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: WnAvatar(
              pictureUrl: _sampleImageUrl,
              displayName: 'A',
              size: WnAvatarSize.medium,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: WnAvatar(
              pictureUrl: _sampleImageUrl,
              displayName: 'A',
              size: WnAvatarSize.large,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: WnAvatar(
              pictureUrl: _sampleImageUrl,
              displayName: 'A',
              size: WnAvatarSize.large,
              onEditTap: () {},
            ),
          ),
        ),
      ],
    ),
  );
}
