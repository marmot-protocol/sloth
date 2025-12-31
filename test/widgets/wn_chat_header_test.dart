import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_chat_header.dart';

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
      String displayName = 'Test User',
      String? pictureUrl,
    }) async {
      await mountWidget(
        WnChatHeader(
          displayName: displayName,
          pictureUrl: pictureUrl,
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

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('displays menu button', (tester) async {
      await pumpHeader(tester);

      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
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
