import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_slate_header_action.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';
import '../test_helpers.dart';

void main() {
  group('WnSlateNavigationHeader', () {
    testWidgets('renders title', (tester) async {
      await mountWidget(
        const WnSlateNavigationHeader(
          title: 'Test Title',
        ),
        tester,
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('does not render action when onNavigate is null', (tester) async {
      await mountWidget(
        const WnSlateNavigationHeader(
          title: 'Test Title',
        ),
        tester,
      );

      expect(find.byType(WnSlateHeaderAction), findsNothing);
    });

    group('close type', () {
      testWidgets('renders close icon on right side when onNavigate provided', (tester) async {
        await mountWidget(
          WnSlateNavigationHeader(
            title: 'Test Title',
            onNavigate: () {},
          ),
          tester,
        );

        final actionFinder = find.byType(WnSlateHeaderAction);
        expect(actionFinder, findsOneWidget);
        final icon = tester.widget<WnIcon>(find.byType(WnIcon));
        expect(icon.icon, WnIcons.closeLarge);
      });

      testWidgets('calls onNavigate when close button tapped', (tester) async {
        var tapped = false;
        await mountWidget(
          WnSlateNavigationHeader(
            title: 'Test Title',
            onNavigate: () => tapped = true,
          ),
          tester,
        );

        await tester.tap(find.byType(WnSlateHeaderAction));
        expect(tapped, isTrue);
      });
    });

    group('back type', () {
      testWidgets('renders back icon on left side when onNavigate provided', (tester) async {
        await mountWidget(
          WnSlateNavigationHeader(
            title: 'Test Title',
            type: WnSlateNavigationType.back,
            onNavigate: () {},
          ),
          tester,
        );

        final actionFinder = find.byType(WnSlateHeaderAction);
        expect(actionFinder, findsOneWidget);
        final icon = tester.widget<WnIcon>(find.byType(WnIcon));
        expect(icon.icon, WnIcons.chevronLeft);
      });

      testWidgets('calls onNavigate when back button tapped', (tester) async {
        var tapped = false;
        await mountWidget(
          WnSlateNavigationHeader(
            title: 'Test Title',
            type: WnSlateNavigationType.back,
            onNavigate: () => tapped = true,
          ),
          tester,
        );

        await tester.tap(find.byType(WnSlateHeaderAction));
        expect(tapped, isTrue);
      });
    });
  });
}
