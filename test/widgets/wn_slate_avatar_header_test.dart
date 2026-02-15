import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_avatar.dart';
import 'package:whitenoise/widgets/wn_slate_avatar_header.dart';
import '../test_helpers.dart';

void main() {
  group('WnSlateAvatarHeader', () {
    testWidgets('renders avatar', (tester) async {
      await mountWidget(
        const WnSlateAvatarHeader(),
        tester,
      );

      expect(find.byType(WnAvatar), findsOneWidget);
    });

    testWidgets('calls onAvatarTap when avatar is tapped', (tester) async {
      var tapped = false;
      await mountWidget(
        WnSlateAvatarHeader(
          onAvatarTap: () => tapped = true,
        ),
        tester,
      );

      await tester.tap(find.byType(WnAvatar));
      expect(tapped, isTrue);
    });

    testWidgets('renders action widget when provided', (tester) async {
      await mountWidget(
        const WnSlateAvatarHeader(
          action: Text('Action'),
        ),
        tester,
      );

      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('does not render action when not provided', (tester) async {
      await mountWidget(
        const WnSlateAvatarHeader(),
        tester,
      );

      expect(find.text('Action'), findsNothing);
    });

    testWidgets('passes avatarUrl to WnAvatar', (tester) async {
      await mountWidget(
        const WnSlateAvatarHeader(
          avatarUrl: 'https://example.com/avatar.png',
        ),
        tester,
      );

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.pictureUrl, 'https://example.com/avatar.png');
    });

    testWidgets('passes avatarColor to WnAvatar', (tester) async {
      await mountWidget(
        const WnSlateAvatarHeader(
          avatarColor: AvatarColor.violet,
        ),
        tester,
      );

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.color, AvatarColor.violet);
    });

    testWidgets('passes avatarKey to GestureDetector', (tester) async {
      await mountWidget(
        const WnSlateAvatarHeader(
          avatarKey: Key('test_avatar_key'),
        ),
        tester,
      );

      expect(find.byKey(const Key('test_avatar_key')), findsOneWidget);
    });

    testWidgets('wraps action in padded container', (tester) async {
      await mountWidget(
        const WnSlateAvatarHeader(
          action: Icon(Icons.add, key: Key('wn_slate_avatar_action')),
        ),
        tester,
      );

      final icon = find.byKey(const Key('wn_slate_avatar_action'));
      expect(icon, findsOneWidget);

      final container = tester.widget<Container>(
        find.ancestor(of: icon, matching: find.byType(Container)).first,
      );
      final padding = container.padding! as EdgeInsets;
      expect(padding.right, greaterThan(0));
    });
  });
}
