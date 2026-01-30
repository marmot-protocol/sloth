import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_icon.dart' show WnIcon;
import 'package:sloth/widgets/wn_system_notice.dart';

import '../test_helpers.dart';

void main() {
  testWidgets(
    'WnSystemNotice renders correctly with default properties',
    (tester) async {
      await mountWidget(
        const WnSystemNotice(title: 'Test Notice'),
        tester,
      );

      expect(find.text('Test Notice'), findsOneWidget);
      expect(find.byType(WnSystemNotice), findsOneWidget);
      expect(
        find.byKey(const ValueKey('systemNotice_leadingIcon')),
        findsOneWidget,
      );
    },
  );

  group('WnSystemNotice Types', () {
    testWidgets('renders success type correctly', (tester) async {
      await mountWidget(
        const WnSystemNotice(
          title: 'Success',
        ),
        tester,
      );

      expect(
        find.byKey(const ValueKey('systemNotice_leadingIcon')),
        findsOneWidget,
      );
    });

    testWidgets('renders info type correctly', (tester) async {
      await mountWidget(
        const WnSystemNotice(
          title: 'Info',
          type: WnSystemNoticeType.info,
        ),
        tester,
      );
      expect(
        find.byKey(const ValueKey('systemNotice_leadingIcon')),
        findsOneWidget,
      );
    });

    testWidgets('renders warning type correctly', (tester) async {
      await mountWidget(
        const WnSystemNotice(
          title: 'Warning',
          type: WnSystemNoticeType.warning,
        ),
        tester,
      );
      expect(
        find.byKey(const ValueKey('systemNotice_leadingIcon')),
        findsOneWidget,
      );
    });

    testWidgets('renders error type correctly', (tester) async {
      await mountWidget(
        const WnSystemNotice(
          title: 'Error',
          type: WnSystemNoticeType.error,
        ),
        tester,
      );
      expect(
        find.byKey(const ValueKey('systemNotice_leadingIcon')),
        findsOneWidget,
      );
    });

    testWidgets('renders neutral type correctly', (tester) async {
      await mountWidget(
        const WnSystemNotice(
          title: 'Neutral',
          type: WnSystemNoticeType.neutral,
        ),
        tester,
      );
      expect(find.byType(WnIcon), findsNothing);
    });
  });

  group('WnSystemNotice Variants', () {
    testWidgets('Temporary variant renders title only', (tester) async {
      await mountWidget(
        const WnSystemNotice(
          title: 'Temporary',
          description: 'Should not show',
        ),
        tester,
      );

      expect(find.text('Temporary'), findsOneWidget);
      expect(find.text('Should not show'), findsNothing);
      expect(
        find.byKey(const ValueKey('systemNotice_actionIcon')),
        findsNothing,
      );
    });

    testWidgets('Dismissible variant renders dismiss icon', (tester) async {
      await mountWidget(
        WnSystemNotice(
          title: 'Dismissible',
          variant: WnSystemNoticeVariant.dismissible,
          onDismiss: () {},
        ),
        tester,
      );

      expect(
        find.byKey(const ValueKey('systemNotice_actionIcon')),
        findsOneWidget,
      );
    });

    testWidgets(
      'Collapsed variant renders chevron down and hides content',
      (tester) async {
        await mountWidget(
          WnSystemNotice(
            title: 'Collapsed',
            variant: WnSystemNoticeVariant.collapsed,
            description: 'Hidden Content',
            onToggle: () {},
          ),
          tester,
        );

        expect(
          find.byKey(const ValueKey('systemNotice_actionIcon')),
          findsOneWidget,
        );
        expect(find.text('Hidden Content'), findsNothing);
      },
    );

    testWidgets(
      'Expanded variant renders chevron up and shows content',
      (tester) async {
        await mountWidget(
          WnSystemNotice(
            title: 'Expanded',
            variant: WnSystemNoticeVariant.expanded,
            description: 'Visible Content',
            onToggle: () {},
          ),
          tester,
        );

        expect(
          find.byKey(const ValueKey('systemNotice_actionIcon')),
          findsOneWidget,
        );
        expect(find.text('Visible Content'), findsOneWidget);
      },
    );
  });

  group('Content and Actions', () {
    testWidgets('renders description when appropriate', (tester) async {
      await mountWidget(
        WnSystemNotice(
          title: 'Notice',
          description: 'Description text',
          variant: WnSystemNoticeVariant.dismissible,
          onDismiss: () {},
        ),
        tester,
      );

      expect(find.text('Description text'), findsOneWidget);
    });

    testWidgets('renders actions when present', (tester) async {
      await mountWidget(
        WnSystemNotice(
          title: 'Notice',
          variant: WnSystemNoticeVariant.expanded,
          primaryAction: const WnButton(text: 'Primary', onPressed: null),
          secondaryAction: const WnButton(text: 'Secondary', onPressed: null),
          onToggle: () {},
        ),
        tester,
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
    });
  });

  group('Interactions', () {
    testWidgets('onDismiss callback is called', (tester) async {
      var dismissed = false;
      await mountWidget(
        WnSystemNotice(
          title: 'Dismiss me',
          variant: WnSystemNoticeVariant.dismissible,
          onDismiss: () => dismissed = true,
        ),
        tester,
      );

      await tester.tap(find.byKey(const ValueKey('systemNotice_actionIcon')));
      expect(dismissed, isTrue);
    });

    testWidgets('onToggle callback is called', (tester) async {
      var toggled = false;
      await mountWidget(
        WnSystemNotice(
          title: 'Toggle me',
          variant: WnSystemNoticeVariant.collapsed,
          onToggle: () => toggled = true,
        ),
        tester,
      );

      await tester.tap(find.byKey(const ValueKey('systemNotice_actionIcon')));
      expect(toggled, isTrue);
    });
  });

  group('Action icon only renders when callback exists', () {
    testWidgets(
      'dismissible without onDismiss does not show action icon',
      (tester) async {
        await mountWidget(
          const WnSystemNotice(
            title: 'No callback',
            variant: WnSystemNoticeVariant.dismissible,
          ),
          tester,
        );

        expect(
          find.byKey(const ValueKey('systemNotice_actionIcon')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'collapsed without onToggle does not show action icon',
      (tester) async {
        await mountWidget(
          const WnSystemNotice(
            title: 'No callback',
            variant: WnSystemNoticeVariant.collapsed,
          ),
          tester,
        );

        expect(
          find.byKey(const ValueKey('systemNotice_actionIcon')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'expanded without onToggle does not show action icon',
      (tester) async {
        await mountWidget(
          const WnSystemNotice(
            title: 'No callback',
            variant: WnSystemNoticeVariant.expanded,
          ),
          tester,
        );

        expect(
          find.byKey(const ValueKey('systemNotice_actionIcon')),
          findsNothing,
        );
      },
    );
  });
}
