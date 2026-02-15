import 'package:flutter/material.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_avatar.dart';
import 'package:whitenoise/widgets/wn_icon.dart';
import 'package:whitenoise/widgets/wn_slate.dart';
import 'package:whitenoise/widgets/wn_slate_avatar_header.dart';
import 'package:whitenoise/widgets/wn_slate_chat_header.dart';
import 'package:whitenoise/widgets/wn_slate_navigation_header.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../foundations/design_width_container.dart';

const _sampleImageUrl = 'https://www.whitenoise.chat/images/mask-man.webp';

enum _HeaderType { chat, navigation, avatar }

class WnSlateHeadersStory extends StatelessWidget {
  const WnSlateHeadersStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Slate Headers', type: WnSlateHeadersStory)
Widget wnSlateHeadersShowcase(BuildContext context) {
  final colors = context.colors;

  final headerType = context.knobs.object.dropdown<_HeaderType>(
    label: 'Header Type',
    options: _HeaderType.values,
    initialOption: _HeaderType.chat,
    labelBuilder: (type) => switch (type) {
      _HeaderType.chat => 'Chat Header',
      _HeaderType.navigation => 'Navigation Header',
      _HeaderType.avatar => 'Avatar Header',
    },
  );

  final displayName = context.knobs.string(
    label: 'Display Name / Title',
    initialValue: 'John Doe',
  );

  return Scaffold(
    backgroundColor: colors.backgroundPrimary,
    body: Center(
      child: DesignWidthContainer(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
          children: [
            _sectionTitle('Playground', colors),
            const SizedBox(height: 8),
            Text(
              'Use the knobs to switch between header types.',
              style: TextStyle(
                fontSize: 14,
                color: colors.backgroundContentSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _buildPlayground(headerType, displayName),
            const SizedBox(height: 32),
            Divider(color: colors.borderTertiary),
            const SizedBox(height: 24),
            _sectionTitle('WnSlateAvatarHeader', colors),
            const SizedBox(height: 8),
            Text(
              'Used on the main page as the baseline Slate state.',
              style: TextStyle(
                fontSize: 14,
                color: colors.backgroundContentSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _variantLabel('With display name', colors),
            WnSlate(
              tag: 'story-avatar-alice',
              animateContent: false,
              header: WnSlateAvatarHeader(
                displayName: 'Alice',
                onAvatarTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            _variantLabel('With image', colors),
            WnSlate(
              tag: 'story-avatar-bob',
              animateContent: false,
              header: WnSlateAvatarHeader(
                avatarUrl: _sampleImageUrl,
                displayName: 'Bob',
                onAvatarTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            _variantLabel('With action', colors),
            WnSlate(
              tag: 'story-avatar-charlie',
              animateContent: false,
              header: WnSlateAvatarHeader(
                displayName: 'Charlie',
                onAvatarTap: () {},
                action: IconButton(
                  onPressed: () {},
                  icon: WnIcon(
                    WnIcons.newChat,
                    size: 24,
                    color: colors.backgroundContentPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _sectionTitle('WnSlateChatHeader', colors),
            const SizedBox(height: 8),
            Text(
              'Used in chat threads.',
              style: TextStyle(
                fontSize: 14,
                color: colors.backgroundContentSecondary,
              ),
            ),
            const SizedBox(height: 16),
            WnSlate(
              tag: 'story-chat-alice',
              animateContent: false,
              header: WnSlateChatHeader(
                displayName: 'Alice',
                avatarColor: AvatarColor.violet,
                onBack: () {},
                onAvatarTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            WnSlate(
              tag: 'story-chat-bob',
              animateContent: false,
              header: WnSlateChatHeader(
                displayName: 'Bob',
                avatarColor: AvatarColor.cyan,
                pictureUrl: _sampleImageUrl,
                onBack: () {},
                onAvatarTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            WnSlate(
              tag: 'story-chat-long',
              animateContent: false,
              header: WnSlateChatHeader(
                displayName:
                    'A Very Long Display Name That Should Truncate With Ellipsis',
                avatarColor: AvatarColor.rose,
                onBack: () {},
                onAvatarTap: () {},
              ),
            ),
            const SizedBox(height: 32),
            Divider(color: colors.borderTertiary),
            const SizedBox(height: 24),
            _sectionTitle('WnSlateNavigationHeader', colors),
            const SizedBox(height: 8),
            Text(
              'Used in settings, profile, and modal screens. Centered title with a close or back action.',
              style: TextStyle(
                fontSize: 14,
                color: colors.backgroundContentSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _variantLabel('Close (default)', colors),
            Text(
              'Used for Slate pages opened from the Canvas level that can be closed immediately.',
              style: TextStyle(
                fontSize: 12,
                color: colors.backgroundContentSecondary,
              ),
            ),
            const SizedBox(height: 16),
            WnSlate(
              tag: 'story-nav-close',
              animateContent: false,
              header: WnSlateNavigationHeader(
                title: 'Settings',
                onNavigate: () {},
              ),
            ),
            const SizedBox(height: 12),
            _variantLabel('Back', colors),
            Text(
              'Used for Slate pages opened from the Canvas level that can be closed immediately.',
              style: TextStyle(
                fontSize: 12,
                color: colors.backgroundContentSecondary,
              ),
            ),
            WnSlate(
              tag: 'story-nav-back',
              animateContent: false,
              header: WnSlateNavigationHeader(
                title: 'Edit Profile',
                type: WnSlateNavigationType.back,
                onNavigate: () {},
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPlayground(_HeaderType type, String displayName) {
  return WnSlate(
    tag: 'story-playground',
    animateContent: false,
    header: switch (type) {
      _HeaderType.chat => WnSlateChatHeader(
        displayName: displayName,
        avatarColor: AvatarColor.violet,
        onBack: () {},
        onAvatarTap: () {},
      ),
      _HeaderType.navigation => WnSlateNavigationHeader(
        title: displayName,
        type: WnSlateNavigationType.back,
        onNavigate: () {},
      ),
      _HeaderType.avatar => WnSlateAvatarHeader(
        displayName: displayName,
        onAvatarTap: () {},
      ),
    },
  );
}

Widget _sectionTitle(String text, SemanticColors colors) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: colors.backgroundContentPrimary,
    ),
  );
}

Widget _variantLabel(String text, SemanticColors colors) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: colors.backgroundContentSecondary,
      ),
    ),
  );
}
