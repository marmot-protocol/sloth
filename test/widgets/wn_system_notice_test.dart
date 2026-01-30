import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_system_notice.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('WnSystemNotice renders correctly with default properties', (tester) async {
    await mountWidget(
      const WnSystemNotice(title: 'Test Notice'),
      tester,
    );

    expect(find.text('Test Notice'), findsOneWidget);
    expect(find.byType(WnSystemNotice), findsOneWidget);
    expect(find.bySvgPath(WnIcons.checkmarkFilled.path), findsOneWidget);
  });

  group('WnSystemNotice Types', () {
    testWidgets('renders success type correctly', (tester) async {
      await mountWidget(
        const WnSystemNotice(
          title: 'Success',
          type: WnSystemNoticeType.success,
        ),
        tester,
      );

      expect(find.bySvgPath(WnIcons.checkmarkFilled.path), findsOneWidget);
    });

    testWidgets('renders info type correctly', (tester) async {
      await mountWidget(
        const WnSystemNotice(
          title: 'Info',
          type: WnSystemNoticeType.info,
        ),
        tester,
      );
      expect(find.bySvgPath(WnIcons.informationFilled.path), findsOneWidget);
    });

    testWidgets('renders warning type correctly', (tester) async {
      await mountWidget(
        const WnSystemNotice(
          title: 'Warning',
          type: WnSystemNoticeType.warning,
        ),
        tester,
      );
      expect(find.bySvgPath(WnIcons.warningFilled.path), findsOneWidget);
    });

    testWidgets('renders error type correctly', (tester) async {
      await mountWidget(
        const WnSystemNotice(
          title: 'Error',
          type: WnSystemNoticeType.error,
        ),
        tester,
      );
      expect(find.bySvgPath(WnIcons.errorFilled.path), findsOneWidget);
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
          variant: WnSystemNoticeVariant.temporary,
          description: 'Should not show',
        ),
        tester,
      );

      expect(find.text('Temporary'), findsOneWidget);
      expect(find.text('Should not show'), findsNothing);
      expect(find.bySvgPath(WnIcons.closeLarge.path), findsNothing);
    });

    testWidgets('Dismissible variant renders dismiss icon', (tester) async {
      await mountWidget(
        const WnSystemNotice(
          title: 'Dismissible',
          variant: WnSystemNoticeVariant.dismissible,
        ),
        tester,
      );

      expect(find.bySvgPath(WnIcons.closeLarge.path), findsOneWidget);
    });

    testWidgets('Collapsed variant renders chevron down and hides content', (tester) async {
      await mountWidget(
        const WnSystemNotice(
          title: 'Collapsed',
          variant: WnSystemNoticeVariant.collapsed,
          description: 'Hidden Content',
        ),
        tester,
      );

      expect(find.bySvgPath(WnIcons.chevronDown.path), findsOneWidget);
      expect(find.text('Hidden Content'), findsNothing);
    });

    testWidgets('Expanded variant renders chevron up and shows content', (tester) async {
      await mountWidget(
        const WnSystemNotice(
          title: 'Expanded',
          variant: WnSystemNoticeVariant.expanded,
          description: 'Visible Content',
        ),
        tester,
      );

      expect(find.bySvgPath(WnIcons.chevronUp.path), findsOneWidget);
      expect(find.text('Visible Content'), findsOneWidget);
    });
  });

  group('Content and Actions', () {
    testWidgets('renders description when appropriate', (tester) async {
      await mountWidget(
        const WnSystemNotice(
          title: 'Notice',
          description: 'Description text',
          variant: WnSystemNoticeVariant.dismissible,
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

      await tester.tap(find.bySvgPath(WnIcons.closeLarge.path));
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

      await tester.tap(find.bySvgPath(WnIcons.chevronDown.path));
      expect(toggled, isTrue);
    });
  });
}

extension FinderExtensions on CommonFinders {
  Finder bySvgPath(String path) {
    return find.byWidgetPredicate((widget) {
      if (widget is WnIcon) {
        return widget.icon.path == path;
      }
      return false;
    });
  }
}
