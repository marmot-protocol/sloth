import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_avatar.dart';
import 'package:whitenoise/widgets/wn_chat_header.dart';

import '../test_helpers.dart';

void main() {
  group('WnChatHeader', () {
    late bool backPressed;
    late bool menuPressed;

    setUp(() {
      backPressed = false;
      menuPressed = false;
    });

    Future<void> pumpHeader(
      WidgetTester tester, {
      String mlsGroupId = testGroupId,
      String displayName = 'Test User',
      String? pictureUrl,
      String? peerPubkey,
    }) async {
      await mountWidget(
        WnChatHeader(
          mlsGroupId: mlsGroupId,
          displayName: displayName,
          pictureUrl: pictureUrl,
          peerPubkey: peerPubkey,
          onBack: () => backPressed = true,
          onMenuTap: () => menuPressed = true,
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

    testWidgets('displays menu button', (tester) async {
      await pumpHeader(tester);

      expect(find.byKey(const Key('menu_button')), findsOneWidget);
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

    testWidgets('uses mlsGroupId for color when peerPubkey is null', (tester) async {
      await pumpHeader(tester);

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.color, AvatarColor.fromPubkey(testGroupId));
    });

    testWidgets('uses peerPubkey for color when provided', (tester) async {
      await pumpHeader(tester, peerPubkey: testPubkeyB);

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.color, AvatarColor.fromPubkey(testPubkeyB));
    });

    testWidgets('different mlsGroupId produces different color when no peerPubkey', (tester) async {
      await pumpHeader(tester);
      final avatar1 = tester.widget<WnAvatar>(find.byType(WnAvatar));
      final color1 = avatar1.color;

      await pumpHeader(tester, mlsGroupId: testNostrGroupId);
      final avatar2 = tester.widget<WnAvatar>(find.byType(WnAvatar));
      final color2 = avatar2.color;

      expect(color1, isNot(equals(color2)));
    });

    group('back button', () {
      testWidgets('triggers onBack callback', (tester) async {
        await pumpHeader(tester);
        await tester.tap(find.byKey(const Key('back_button')));

        expect(backPressed, isTrue);
      });
    });

    group('menu button', () {
      testWidgets('triggers onMenuTap callback', (tester) async {
        await pumpHeader(tester);
        await tester.tap(find.byKey(const Key('menu_button')));

        expect(menuPressed, isTrue);
      });
    });
  });
}
