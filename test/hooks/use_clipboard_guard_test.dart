import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/hooks/use_clipboard_guard.dart';

import '../mocks/mock_clipboard.dart';

void main() {
  group('useClipboardGuard', () {
    late String? Function() getClipboard;

    setUp(() {
      getClipboard = mockClipboard();
    });

    tearDown(() {
      cancelClipboardGuardTimer();
      clearClipboardMock();
    });

    testWidgets('returns a function', (tester) async {
      late void Function() capturedSchedule;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              capturedSchedule = useClipboardGuard();
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedSchedule, isA<void Function()>());
    });

    testWidgets('clears clipboard after 60 seconds', (tester) async {
      late void Function() capturedSchedule;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              capturedSchedule = useClipboardGuard();
              return const SizedBox();
            },
          ),
        ),
      );

      capturedSchedule();

      await tester.pump(const Duration(seconds: 59));
      expect(getClipboard(), isNull);

      await tester.pump(const Duration(seconds: 1));
      expect(getClipboard(), '');
    });

    testWidgets('resets timer when called again before expiry', (tester) async {
      late void Function() capturedSchedule;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              capturedSchedule = useClipboardGuard();
              return const SizedBox();
            },
          ),
        ),
      );

      capturedSchedule();

      await tester.pump(const Duration(seconds: 30));
      expect(getClipboard(), isNull);

      capturedSchedule();

      await tester.pump(const Duration(seconds: 30));
      expect(getClipboard(), isNull);

      await tester.pump(const Duration(seconds: 30));
      expect(getClipboard(), '');
    });

    testWidgets('handles clipboard failure gracefully', (tester) async {
      late void Function() capturedSchedule;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              capturedSchedule = useClipboardGuard();
              return const SizedBox();
            },
          ),
        ),
      );

      clearClipboardMock();
      mockClipboardFailing();
      capturedSchedule();

      await tester.pump(const Duration(seconds: 60));

      clearClipboardMock();
      getClipboard = mockClipboard();
    });

    testWidgets('timer persists after widget disposal', (tester) async {
      late void Function() capturedSchedule;
      final showHook = ValueNotifier(true);

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<bool>(
            valueListenable: showHook,
            builder: (context, show, _) {
              if (!show) return const SizedBox();
              return HookBuilder(
                builder: (context) {
                  capturedSchedule = useClipboardGuard();
                  return const SizedBox();
                },
              );
            },
          ),
        ),
      );

      capturedSchedule();

      showHook.value = false;
      await tester.pump();

      await tester.pump(const Duration(seconds: 60));
      expect(getClipboard(), '');
    });
  });
}
