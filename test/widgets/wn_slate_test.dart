import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_scroll_edge_effect.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_header.dart';
import '../test_helpers.dart';

void main() {
  group('WnSlate', () {
    group('defaultType', () {
      testWidgets('renders header with defaultType', (tester) async {
        await mountWidget(
          const WnSlate(),
          tester,
        );

        final headerFinder = find.byType(WnSlateHeader);
        expect(headerFinder, findsOneWidget);
        final header = tester.widget<WnSlateHeader>(headerFinder);
        expect(header.type, WnSlateHeaderType.defaultType);
      });

      testWidgets('passes callbacks to header', (tester) async {
        var avatarTapped = false;
        var newChatTapped = false;

        await mountWidget(
          WnSlate(
            onAvatarTap: () => avatarTapped = true,
            onNewChatTap: () => newChatTapped = true,
          ),
          tester,
        );

        final header = tester.widget<WnSlateHeader>(find.byType(WnSlateHeader));
        header.onAvatarTap?.call();
        header.onNewChatTap?.call();

        expect(avatarTapped, isTrue);
        expect(newChatTapped, isTrue);
      });
    });

    group('close type', () {
      testWidgets('renders header with close type', (tester) async {
        await mountWidget(
          const WnSlate(type: WnSlateType.close, title: 'Test Title'),
          tester,
        );

        final headerFinder = find.byType(WnSlateHeader);
        expect(headerFinder, findsOneWidget);
        final header = tester.widget<WnSlateHeader>(headerFinder);
        expect(header.type, WnSlateHeaderType.close);
        expect(header.title, 'Test Title');
      });

      testWidgets('passes onCloseTap callback to header', (tester) async {
        var closeTapped = false;

        await mountWidget(
          WnSlate(
            type: WnSlateType.close,
            title: 'Test',
            onCloseTap: () => closeTapped = true,
          ),
          tester,
        );

        final header = tester.widget<WnSlateHeader>(find.byType(WnSlateHeader));
        header.onCloseTap?.call();

        expect(closeTapped, isTrue);
      });
    });

    group('back type', () {
      testWidgets('renders header with back type', (tester) async {
        await mountWidget(
          const WnSlate(type: WnSlateType.back, title: 'Back Title'),
          tester,
        );

        final headerFinder = find.byType(WnSlateHeader);
        expect(headerFinder, findsOneWidget);
        final header = tester.widget<WnSlateHeader>(headerFinder);
        expect(header.type, WnSlateHeaderType.back);
        expect(header.title, 'Back Title');
      });

      testWidgets('passes onBackTap callback to header', (tester) async {
        var backTapped = false;

        await mountWidget(
          WnSlate(
            type: WnSlateType.back,
            title: 'Test',
            onBackTap: () => backTapped = true,
          ),
          tester,
        );

        final header = tester.widget<WnSlateHeader>(find.byType(WnSlateHeader));
        header.onBackTap?.call();

        expect(backTapped, isTrue);
      });
    });

    group('noHeader type', () {
      testWidgets('does not render header', (tester) async {
        await mountWidget(
          const WnSlate(type: WnSlateType.noHeader),
          tester,
        );

        expect(find.byType(WnSlateHeader), findsNothing);
      });
    });

    group('child', () {
      testWidgets('renders child widget', (tester) async {
        await mountWidget(
          const WnSlate(
            child: Text('Child Content'),
          ),
          tester,
        );

        expect(find.text('Child Content'), findsOneWidget);
      });

      testWidgets('renders child without header when noHeader type', (tester) async {
        await mountWidget(
          const WnSlate(
            type: WnSlateType.noHeader,
            child: Text('Only Child'),
          ),
          tester,
        );

        expect(find.text('Only Child'), findsOneWidget);
        expect(find.byType(WnSlateHeader), findsNothing);
      });
    });

    group('scroll edge effects', () {
      testWidgets('shows top scroll effect when enabled', (tester) async {
        await mountStackedWidget(
          const WnSlate(
            showTopScrollEffect: true,
          ),
          tester,
        );

        final effectFinders = find.byType(WnScrollEdgeEffect);
        expect(effectFinders, findsOneWidget);

        final effect = tester.widget<WnScrollEdgeEffect>(effectFinders);
        expect(effect.position, ScrollEdgePosition.top);
        expect(effect.type, ScrollEdgeEffectType.slate);
      });

      testWidgets('shows bottom scroll effect when enabled', (tester) async {
        await mountStackedWidget(
          const WnSlate(
            showBottomScrollEffect: true,
          ),
          tester,
        );

        final effectFinders = find.byType(WnScrollEdgeEffect);
        expect(effectFinders, findsOneWidget);

        final effect = tester.widget<WnScrollEdgeEffect>(effectFinders);
        expect(effect.position, ScrollEdgePosition.bottom);
        expect(effect.type, ScrollEdgeEffectType.slate);
      });

      testWidgets('shows both scroll effects when both enabled', (tester) async {
        await mountStackedWidget(
          const WnSlate(
            showTopScrollEffect: true,
            showBottomScrollEffect: true,
          ),
          tester,
        );

        final effectFinders = find.byType(WnScrollEdgeEffect);
        expect(effectFinders, findsNWidgets(2));
      });

      testWidgets('hides scroll effects by default', (tester) async {
        await mountWidget(
          const WnSlate(),
          tester,
        );

        expect(find.byType(WnScrollEdgeEffect), findsNothing);
      });
    });

    group('styling', () {
      testWidgets('renders with rounded corners', (tester) async {
        await mountWidget(
          const WnSlate(),
          tester,
        );

        final containerFinder = find.byType(Container).first;
        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.borderRadius, isNotNull);
      });

      testWidgets('renders with box shadow', (tester) async {
        await mountWidget(
          const WnSlate(),
          tester,
        );

        final containerFinder = find.byType(Container).first;
        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.length, 2);
      });

      testWidgets('renders with horizontal margin', (tester) async {
        await mountWidget(
          const WnSlate(),
          tester,
        );

        final containerFinder = find.byType(Container).first;
        final container = tester.widget<Container>(containerFinder);

        expect(container.margin, isNotNull);
        expect(
          container.margin,
          isA<EdgeInsets>().having((m) => m.left, 'left', greaterThan(0)),
        );
        expect(
          container.margin,
          isA<EdgeInsets>().having((m) => m.right, 'right', greaterThan(0)),
        );
      });

      testWidgets('applies custom padding when provided', (tester) async {
        await mountWidget(
          const WnSlate(
            padding: EdgeInsets.all(20),
          ),
          tester,
        );

        final containerFinder = find.byType(Container).first;
        final container = tester.widget<Container>(containerFinder);

        expect(container.padding, const EdgeInsets.all(20));
      });
    });

    group('hero animation', () {
      testWidgets('wraps content in Hero widget', (tester) async {
        await mountWidget(
          const WnSlate(),
          tester,
        );

        expect(find.byType(Hero), findsOneWidget);
      });

      testWidgets('uses default tag', (tester) async {
        await mountWidget(
          const WnSlate(),
          tester,
        );

        final hero = tester.widget<Hero>(find.byType(Hero));
        expect(hero.tag, 'wn-slate');
      });

      testWidgets('uses custom tag when provided', (tester) async {
        await mountWidget(
          const WnSlate(tag: 'custom-tag'),
          tester,
        );

        final hero = tester.widget<Hero>(find.byType(Hero));
        expect(hero.tag, 'custom-tag');
      });

      testWidgets('has flightShuttleBuilder for animation', (tester) async {
        await mountWidget(
          const WnSlate(),
          tester,
        );

        final hero = tester.widget<Hero>(find.byType(Hero));
        expect(hero.flightShuttleBuilder, isNotNull);
      });
    });
  });
}
