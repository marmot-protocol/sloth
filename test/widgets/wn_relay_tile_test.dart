import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/src/rust/api/relays.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_relay_tile.dart';
import '../test_helpers.dart';

void main() {
  group('WnRelayTile', () {
    testWidgets('displays relay URL', (tester) async {
      final relay = Relay(
        url: 'wss://relay.example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final widget = WnRelayTile(relay: relay);
      await mountWidget(widget, tester);
      expect(find.text('wss://relay.example.com'), findsOneWidget);
    });

    testWidgets('displays status when provided', (tester) async {
      final relay = Relay(
        url: 'wss://relay.example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final widget = WnRelayTile(
        relay: relay,
        status: 'Connected',
      );
      await mountWidget(widget, tester);
      expect(find.text('Connected'), findsOneWidget);
    });

    testWidgets('does not display status when not provided', (tester) async {
      final relay = Relay(
        url: 'wss://relay.example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final widget = WnRelayTile(relay: relay);
      await mountWidget(widget, tester);
      expect(find.text('Connected'), findsNothing);
    });

    testWidgets('displays delete icon when showOptions is true', (tester) async {
      final relay = Relay(
        url: 'wss://relay.example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final widget = WnRelayTile(
        relay: relay,
        onDelete: () {},
      );
      await mountWidget(widget, tester);
      expect(find.byKey(const Key('delete_relay_wss://relay.example.com')), findsOneWidget);
    });

    testWidgets('does not display delete icon when showOptions is false', (tester) async {
      final relay = Relay(
        url: 'wss://relay.example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final widget = WnRelayTile(
        relay: relay,
        showOptions: false,
        onDelete: () {},
      );
      await mountWidget(widget, tester);
      expect(find.byKey(const Key('delete_relay_wss://relay.example.com')), findsNothing);
    });

    testWidgets('does not display delete icon when onDelete is null', (tester) async {
      final relay = Relay(
        url: 'wss://relay.example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final widget = WnRelayTile(
        relay: relay,
      );
      await mountWidget(widget, tester);
      expect(find.byKey(const Key('delete_relay_wss://relay.example.com')), findsNothing);
    });

    group('delete confirmation dialog', () {
      testWidgets('shows confirmation dialog when delete icon is tapped', (tester) async {
        final relay = Relay(
          url: 'wss://relay.example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final widget = WnRelayTile(
          relay: relay,
          onDelete: () {},
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byKey(const Key('delete_relay_wss://relay.example.com')));
        await tester.pumpAndSettle();

        expect(find.text('Remove Relay?'), findsOneWidget);
        expect(
          find.text('Are you sure you want to remove this relay? This action cannot be undone.'),
          findsOneWidget,
        );
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Remove'), findsOneWidget);
      });

      testWidgets('calls onDelete when confirm button is tapped', (tester) async {
        var deleteCalled = false;
        final relay = Relay(
          url: 'wss://relay.example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final widget = WnRelayTile(
          relay: relay,
          onDelete: () => deleteCalled = true,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byKey(const Key('delete_relay_wss://relay.example.com')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('confirm_delete_button')));
        await tester.pumpAndSettle();

        expect(deleteCalled, isTrue);
        expect(find.text('Remove Relay?'), findsNothing);
      });

      testWidgets('does not call onDelete when cancel button is tapped', (tester) async {
        var deleteCalled = false;
        final relay = Relay(
          url: 'wss://relay.example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final widget = WnRelayTile(
          relay: relay,
          onDelete: () => deleteCalled = true,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byKey(const Key('delete_relay_wss://relay.example.com')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('cancel_delete_button')));
        await tester.pumpAndSettle();

        expect(deleteCalled, isFalse);
        expect(find.text('Remove Relay?'), findsNothing);
      });

      testWidgets('does not call onDelete when close button is tapped', (tester) async {
        var deleteCalled = false;
        final relay = Relay(
          url: 'wss://relay.example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final widget = WnRelayTile(
          relay: relay,
          onDelete: () => deleteCalled = true,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byKey(const Key('delete_relay_wss://relay.example.com')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('close_delete_dialog')));
        await tester.pumpAndSettle();

        expect(deleteCalled, isFalse);
        expect(find.text('Remove Relay?'), findsNothing);
      });
    });

    testWidgets('displays green indicator for connected status', (tester) async {
      final relay = Relay(
        url: 'wss://relay.example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final widget = WnRelayTile(
        relay: relay,
        status: 'Connected',
      );
      await mountWidget(widget, tester);
      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, SemanticColors.light.borderSuccess);
    });

    testWidgets('displays status indicator for disconnected relays', (tester) async {
      final relay = Relay(
        url: 'wss://relay.example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final widget = WnRelayTile(
        relay: relay,
        status: 'Disconnected',
      );
      await mountWidget(widget, tester);
      final containers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(containers, findsOneWidget);
    });
  });
}
