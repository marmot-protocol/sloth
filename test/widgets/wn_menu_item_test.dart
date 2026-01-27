import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_menu_item.dart';

import '../test_helpers.dart';

void main() {
  group('WnMenuItem', () {
    testWidgets('displays label and icon for primary type', (tester) async {
      setUpTestView(tester);

      await mountWidget(
        WnMenuItem(
          icon: WnIcons.user,
          label: 'Test Label',
          onTap: () {},
        ),
        tester,
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.byType(WnIcon), findsOneWidget);
    });

    testWidgets('displays label and icon for secondary type', (tester) async {
      setUpTestView(tester);

      await mountWidget(
        WnMenuItem(
          icon: WnIcons.heart,
          label: 'Secondary Label',
          onTap: () {},
          type: WnMenuItemType.secondary,
        ),
        tester,
      );

      expect(find.text('Secondary Label'), findsOneWidget);
      expect(find.byType(WnIcon), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      setUpTestView(tester);
      bool tapped = false;

      await mountWidget(
        WnMenuItem(
          icon: WnIcons.settings,
          label: 'Tap Me',
          onTap: () => tapped = true,
        ),
        tester,
      );

      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });
  });
}
