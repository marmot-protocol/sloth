import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:whitenoise/hooks/use_scroll_to_message.dart';

void main() {
  group('useScrollToMessage', () {
    testWidgets('creates AutoScrollController on init', (tester) async {
      late ScrollToMessageResult result;
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              result = useScrollToMessage(
                getReversedMessageIndex: (_) => null,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(result.scrollController, isA<AutoScrollController>());
    });

    testWidgets('disposes controller on unmount', (tester) async {
      late AutoScrollController capturedController;
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final result = useScrollToMessage(
                getReversedMessageIndex: (_) => null,
              );
              capturedController = result.scrollController;
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(
        () => capturedController.position,
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('scrollToMessage does nothing for non-existent messageId', (tester) async {
      late ScrollToMessageResult result;
      String? lookedUpId;
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              result = useScrollToMessage(
                getReversedMessageIndex: (id) {
                  lookedUpId = id;
                  return null;
                },
              );
              return const SizedBox();
            },
          ),
        ),
      );

      unawaited(result.scrollToMessage('unknown-id'));
      await tester.pump();

      expect(lookedUpId, 'unknown-id');
    });

    testWidgets('scrollToMessage calls getReversedMessageIndex with messageId', (tester) async {
      late ScrollToMessageResult result;
      String? lookedUpId;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              result = useScrollToMessage(
                getReversedMessageIndex: (id) {
                  lookedUpId = id;
                  return id == 'msg-1' ? 0 : null;
                },
              );
              return const SizedBox();
            },
          ),
        ),
      );

      unawaited(result.scrollToMessage('msg-1'));
      await tester.pump();

      expect(lookedUpId, 'msg-1');
    });
  });
}
