import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_slate_header.dart';
import 'package:sloth/widgets/wn_slate_header_action.dart';
import '../test_helpers.dart';

void main() {
  group('WnSlateHeader', () {
    group('defaultType', () {
      testWidgets('renders avatar', (tester) async {
        await mountWidget(
          const WnSlateHeader(),
          tester,
        );

        expect(find.byType(WnAvatar), findsOneWidget);
      });

      testWidgets('renders newChat action when callback provided', (tester) async {
        await mountWidget(
          WnSlateHeader(
            onNewChatTap: () {},
          ),
          tester,
        );

        final actionFinder = find.byType(WnSlateHeaderAction);
        expect(actionFinder, findsOneWidget);
        final action = tester.widget<WnSlateHeaderAction>(actionFinder);
        expect(action.type, WnSlateHeaderActionType.newChat);
      });

      testWidgets('calls onAvatarTap when avatar is tapped', (tester) async {
        var tapped = false;
        await mountWidget(
          WnSlateHeader(
            onAvatarTap: () => tapped = true,
          ),
          tester,
        );

        await tester.tap(find.byType(WnAvatar));
        expect(tapped, isTrue);
      });

      testWidgets('calls onNewChatTap when newChat action is tapped', (tester) async {
        var tapped = false;
        await mountWidget(
          WnSlateHeader(
            onNewChatTap: () => tapped = true,
          ),
          tester,
        );

        await tester.tap(find.byType(WnSlateHeaderAction));
        expect(tapped, isTrue);
      });
    });

    group('close type', () {
      testWidgets('renders title', (tester) async {
        await mountWidget(
          const WnSlateHeader(
            type: WnSlateHeaderType.close,
            title: 'Test Title',
          ),
          tester,
        );

        expect(find.text('Test Title'), findsOneWidget);
      });

      testWidgets('renders close action when callback provided', (tester) async {
        await mountWidget(
          WnSlateHeader(
            type: WnSlateHeaderType.close,
            title: 'Test',
            onCloseTap: () {},
          ),
          tester,
        );

        final actionFinder = find.byType(WnSlateHeaderAction);
        expect(actionFinder, findsOneWidget);
        final action = tester.widget<WnSlateHeaderAction>(actionFinder);
        expect(action.type, WnSlateHeaderActionType.close);
      });

      testWidgets('calls onCloseTap when close action is tapped', (tester) async {
        var tapped = false;
        await mountWidget(
          WnSlateHeader(
            type: WnSlateHeaderType.close,
            title: 'Test',
            onCloseTap: () => tapped = true,
          ),
          tester,
        );

        await tester.tap(find.byType(WnSlateHeaderAction));
        expect(tapped, isTrue);
      });

      testWidgets('does not render avatar', (tester) async {
        await mountWidget(
          WnSlateHeader(
            type: WnSlateHeaderType.close,
            title: 'Test',
            onCloseTap: () {},
          ),
          tester,
        );

        expect(find.byType(WnAvatar), findsNothing);
      });
    });

    group('back type', () {
      testWidgets('renders title', (tester) async {
        await mountWidget(
          const WnSlateHeader(
            type: WnSlateHeaderType.back,
            title: 'Back Title',
          ),
          tester,
        );

        expect(find.text('Back Title'), findsOneWidget);
      });

      testWidgets('renders back action when callback provided', (tester) async {
        await mountWidget(
          WnSlateHeader(
            type: WnSlateHeaderType.back,
            title: 'Test',
            onBackTap: () {},
          ),
          tester,
        );

        final actionFinder = find.byType(WnSlateHeaderAction);
        expect(actionFinder, findsOneWidget);
        final action = tester.widget<WnSlateHeaderAction>(actionFinder);
        expect(action.type, WnSlateHeaderActionType.back);
      });

      testWidgets('calls onBackTap when back action is tapped', (tester) async {
        var tapped = false;
        await mountWidget(
          WnSlateHeader(
            type: WnSlateHeaderType.back,
            title: 'Test',
            onBackTap: () => tapped = true,
          ),
          tester,
        );

        await tester.tap(find.byType(WnSlateHeaderAction));
        expect(tapped, isTrue);
      });

      testWidgets('does not render avatar', (tester) async {
        await mountWidget(
          WnSlateHeader(
            type: WnSlateHeaderType.back,
            title: 'Test',
            onBackTap: () {},
          ),
          tester,
        );

        expect(find.byType(WnAvatar), findsNothing);
      });
    });
  });
}
