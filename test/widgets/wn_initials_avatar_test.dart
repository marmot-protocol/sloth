import 'package:flutter/material.dart' show Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_initials_avatar.dart' show WnInitialsAvatar;
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnInitialsAvatar', () {
    testWidgets('shows fallback icon when displayName is null', (tester) async {
      await mountWidget(const WnInitialsAvatar(), tester);
      expect(find.byKey(const Key('avatar_fallback_icon')), findsOneWidget);
    });

    testWidgets('shows fallback icon when displayName is empty', (tester) async {
      await mountWidget(const WnInitialsAvatar(displayName: ''), tester);
      expect(find.byKey(const Key('avatar_fallback_icon')), findsOneWidget);
    });

    testWidgets('shows single initial for one word name', (tester) async {
      await mountWidget(const WnInitialsAvatar(displayName: 'alice'), tester);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('shows two initials for two word name', (tester) async {
      await mountWidget(const WnInitialsAvatar(displayName: 'alice bob'), tester);
      expect(find.text('AB'), findsOneWidget);
    });

    group('when showContent is false', () {
      testWidgets('hides initials', (tester) async {
        await mountWidget(
          const WnInitialsAvatar(displayName: 'alice', showContent: false),
          tester,
        );
        expect(find.text('A'), findsNothing);
      });

      testWidgets('hides fallback icon', (tester) async {
        await mountWidget(const WnInitialsAvatar(showContent: false), tester);
        expect(find.byKey(const Key('avatar_fallback_icon')), findsNothing);
      });
    });
  });
}
