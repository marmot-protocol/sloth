import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_avatar.dart';
import 'package:whitenoise/widgets/wn_slate_chat_header.dart';

import '../test_helpers.dart';

void main() {
  group('WnSlateChatHeader', () {
    late bool backPressed;
    late bool avatarTapped;

    setUp(() {
      backPressed = false;
      avatarTapped = false;
    });

    Future<void> pumpHeader(
      WidgetTester tester, {
      String displayName = 'Test User',
      AvatarColor avatarColor = AvatarColor.violet,
      String? pictureUrl,
    }) async {
      await mountWidget(
        WnSlateChatHeader(
          displayName: displayName,
          avatarColor: avatarColor,
          pictureUrl: pictureUrl,
          onBack: () => backPressed = true,
          onAvatarTap: () => avatarTapped = true,
        ),
        tester,
      );
    }

    testWidgets('displays displayName', (tester) async {
      await pumpHeader(tester, displayName: 'Alice');

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('displays back button', (tester) async {
      await pumpHeader(tester);

      expect(find.byKey(const Key('back_button')), findsOneWidget);
    });

    testWidgets('displays avatar', (tester) async {
      await pumpHeader(tester);

      expect(find.byType(WnAvatar), findsOneWidget);
    });

    testWidgets('passes pictureUrl to avatar', (tester) async {
      await pumpHeader(tester, pictureUrl: 'https://example.com/avatar.png');

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.pictureUrl, 'https://example.com/avatar.png');
    });

    testWidgets('passes displayName to avatar', (tester) async {
      await pumpHeader(tester, displayName: 'Bob');

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.displayName, 'Bob');
    });

    testWidgets('passes color to avatar', (tester) async {
      await pumpHeader(tester, avatarColor: AvatarColor.amber);

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.color, AvatarColor.amber);
    });

    group('back button', () {
      testWidgets('triggers onBack callback', (tester) async {
        await pumpHeader(tester);
        await tester.tap(find.byKey(const Key('back_button')));

        expect(backPressed, isTrue);
      });
    });

    group('avatar tap', () {
      testWidgets('triggers onAvatarTap callback', (tester) async {
        await pumpHeader(tester);
        await tester.tap(find.byKey(const Key('header_avatar_tap_area')));

        expect(avatarTapped, isTrue);
      });
    });
  });
}
