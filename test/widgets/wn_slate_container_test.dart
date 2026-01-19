import 'package:flutter/material.dart' show Container, EdgeInsets, Hero, Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_slate_container.dart' show WnSlateContainer;
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnSlateContainer tests', () {
    testWidgets('renders child', (WidgetTester tester) async {
      final widget = const WnSlateContainer(
        child: Text('Hi I am a child!'),
      );
      await mountWidget(widget, tester);
      expect(find.text('Hi I am a child!'), findsOneWidget);
    });

    group('without tag', () {
      testWidgets('renders hero with default tag', (WidgetTester tester) async {
        final widget = const WnSlateContainer(
          child: Text('Hi I am a child!'),
        );
        await mountWidget(widget, tester);
        expect(find.byType(Hero), findsOneWidget);
        final hero = tester.widget<Hero>(find.byType(Hero));
        expect(hero.tag, 'wn-slate-container');
      });
    });

    group('with tag', () {
      testWidgets('renders hero with custom tag', (WidgetTester tester) async {
        final widget = const WnSlateContainer(
          tag: 'custom-tag',
          child: Text('Hi I am a child!'),
        );
        await mountWidget(widget, tester);
        expect(find.byType(Hero), findsOneWidget);
        final hero = tester.widget<Hero>(find.byType(Hero));
        expect(hero.tag, 'custom-tag');
      });
    });

    group('with custom padding', () {
      testWidgets('applies custom padding to container', (WidgetTester tester) async {
        const customPadding = EdgeInsets.only(left: 10, right: 10, top: 10);
        final widget = const WnSlateContainer(
          padding: customPadding,
          child: Text('Custom padding child'),
        );
        await mountWidget(widget, tester);

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(WnSlateContainer),
                matching: find.byType(Container),
              )
              .last,
        );
        expect(container.padding, customPadding);
      });
    });
  });
}
