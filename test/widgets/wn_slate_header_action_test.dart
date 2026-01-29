import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_slate_header_action.dart';
import '../test_helpers.dart';

void main() {
  group('WnSlateHeaderAction', () {
    group('newChat type', () {
      testWidgets('renders newChat icon', (tester) async {
        await mountWidget(
          WnSlateHeaderAction(
            type: WnSlateHeaderActionType.newChat,
            onPressed: () {},
          ),
          tester,
        );

        final iconFinder = find.byType(WnIcon);
        expect(iconFinder, findsOneWidget);
        final icon = tester.widget<WnIcon>(iconFinder);
        expect(icon.icon, WnIcons.newChat);
      });

      testWidgets('calls onPressed when tapped', (tester) async {
        var pressed = false;
        await mountWidget(
          WnSlateHeaderAction(
            type: WnSlateHeaderActionType.newChat,
            onPressed: () => pressed = true,
          ),
          tester,
        );

        await tester.tap(find.byType(WnSlateHeaderAction));
        expect(pressed, isTrue);
      });
    });

    group('close type', () {
      testWidgets('renders close icon', (tester) async {
        await mountWidget(
          WnSlateHeaderAction(
            type: WnSlateHeaderActionType.close,
            onPressed: () {},
          ),
          tester,
        );

        final iconFinder = find.byType(WnIcon);
        expect(iconFinder, findsOneWidget);
        final icon = tester.widget<WnIcon>(iconFinder);
        expect(icon.icon, WnIcons.closeLarge);
      });

      testWidgets('calls onPressed when tapped', (tester) async {
        var pressed = false;
        await mountWidget(
          WnSlateHeaderAction(
            type: WnSlateHeaderActionType.close,
            onPressed: () => pressed = true,
          ),
          tester,
        );

        await tester.tap(find.byType(WnSlateHeaderAction));
        expect(pressed, isTrue);
      });
    });

    group('back type', () {
      testWidgets('renders back icon', (tester) async {
        await mountWidget(
          WnSlateHeaderAction(
            type: WnSlateHeaderActionType.back,
            onPressed: () {},
          ),
          tester,
        );

        final iconFinder = find.byType(WnIcon);
        expect(iconFinder, findsOneWidget);
        final icon = tester.widget<WnIcon>(iconFinder);
        expect(icon.icon, WnIcons.chevronLeft);
      });

      testWidgets('calls onPressed when tapped', (tester) async {
        var pressed = false;
        await mountWidget(
          WnSlateHeaderAction(
            type: WnSlateHeaderActionType.back,
            onPressed: () => pressed = true,
          ),
          tester,
        );

        await tester.tap(find.byType(WnSlateHeaderAction));
        expect(pressed, isTrue);
      });
    });
  });
}
