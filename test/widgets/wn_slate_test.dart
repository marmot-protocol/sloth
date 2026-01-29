import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_scroll_edge_effect.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_header.dart';
import '../test_helpers.dart';

void main() {
  group('WnSlate', () {
    group('header', () {
      testWidgets('renders header widget when provided', (tester) async {
        await mountWidget(
          const WnSlate(
            header: WnSlateHeader(
              type: WnSlateHeaderType.close,
              title: 'Test Title',
            ),
          ),
          tester,
        );

        final headerFinder = find.byType(WnSlateHeader);
        expect(headerFinder, findsOneWidget);
        final header = tester.widget<WnSlateHeader>(headerFinder);
        expect(header.type, WnSlateHeaderType.close);
        expect(header.title, 'Test Title');
      });

      testWidgets('renders without header when not provided', (tester) async {
        await mountWidget(
          const WnSlate(),
          tester,
        );

        expect(find.byType(WnSlateHeader), findsNothing);
      });

      testWidgets('accepts any widget as header', (tester) async {
        await mountWidget(
          const WnSlate(
            header: Text('Custom Header'),
          ),
          tester,
        );

        expect(find.text('Custom Header'), findsOneWidget);
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

      testWidgets('renders both header and child', (tester) async {
        await mountWidget(
          const WnSlate(
            header: WnSlateHeader(),
            child: Text('Child Content'),
          ),
          tester,
        );

        expect(find.byType(WnSlateHeader), findsOneWidget);
        expect(find.text('Child Content'), findsOneWidget);
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

      testWidgets('flightShuttleBuilder returns Material with Container', (tester) async {
        await mountWidget(
          const WnSlate(padding: EdgeInsets.all(10)),
          tester,
        );

        final hero = tester.widget<Hero>(find.byType(Hero));
        final flightShuttleBuilder = hero.flightShuttleBuilder!;

        final shuttle = flightShuttleBuilder(
          tester.element(find.byType(Hero)),
          const AlwaysStoppedAnimation(0.5),
          HeroFlightDirection.push,
          tester.element(find.byType(Hero)),
          tester.element(find.byType(Hero)),
        );

        expect(shuttle, isA<Material>());
        final material = shuttle as Material;
        expect(material.type, MaterialType.transparency);
        expect(material.child, isA<Container>());

        final container = material.child! as Container;
        expect(container.margin, isNotNull);
        expect(container.padding, const EdgeInsets.all(10));
        expect(container.decoration, isA<BoxDecoration>());
      });
    });
  });
}
