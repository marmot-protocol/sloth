import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/hooks/use_login.dart';
import '../mocks/mock_clipboard_paste.dart';
import '../test_helpers.dart';

class _TestWidget extends HookWidget {
  final Future<void> Function(String) loginCallback;
  final void Function(
    TextEditingController controller,
    LoginState state,
    Future<void> Function() paste,
    Future<bool> Function() submit,
    void Function() clearError,
  )
  onBuild;

  const _TestWidget({
    required this.loginCallback,
    required this.onBuild,
  });

  @override
  Widget build(BuildContext context) {
    final (:controller, :state, :paste, :submit, :clearError) = useLogin(
      loginCallback,
    );
    onBuild(controller, state, paste, submit, clearError);
    return Column(
      children: [
        TextField(controller: controller),
        Text('loading: ${state.isLoading}'),
        Text('error: ${state.error ?? 'none'}'),
        ElevatedButton(onPressed: paste, child: const Text('Paste')),
        ElevatedButton(onPressed: submit, child: const Text('Submit')),
        ElevatedButton(onPressed: clearError, child: const Text('Clear')),
      ],
    );
  }
}

void main() {
  group('useLogin', () {
    testWidgets('initializes with empty controller', (tester) async {
      late TextEditingController capturedController;

      final widget = _TestWidget(
        loginCallback: (_) async {},
        onBuild: (controller, state, paste, submit, clearError) {
          capturedController = controller;
        },
      );
      await mountWidget(widget, tester);

      expect(capturedController.text, isEmpty);
    });

    testWidgets('starts with not loading', (tester) async {
      late bool capturedIsLoading;

      final widget = _TestWidget(
        loginCallback: (_) async {},
        onBuild: (controller, state, paste, submit, clearError) {
          capturedIsLoading = state.isLoading;
        },
      );
      await mountWidget(widget, tester);

      expect(capturedIsLoading, false);
    });

    testWidgets('starts with no error', (tester) async {
      late String? capturedError;

      final widget = _TestWidget(
        loginCallback: (_) async {},
        onBuild: (controller, state, paste, submit, clearError) {
          capturedError = state.error;
        },
      );
      await mountWidget(widget, tester);

      expect(capturedError, isNull);
    });

    group('submit', () {
      testWidgets('returns false when nsec is empty', (tester) async {
        late Future<bool> Function() capturedSubmit;

        final widget = _TestWidget(
          loginCallback: (_) async {},
          onBuild: (controller, state, paste, submit, clearError) {
            capturedSubmit = submit;
          },
        );
        await mountWidget(widget, tester);

        final result = await capturedSubmit();
        expect(result, false);
      });

      testWidgets('calls login callback with nsec', (tester) async {
        String? capturedNsec;
        late Future<bool> Function() capturedSubmit;

        final widget = _TestWidget(
          loginCallback: (nsec) async {
            capturedNsec = nsec;
          },
          onBuild: (controller, state, paste, submit, clearError) {
            capturedSubmit = submit;
          },
        );
        await mountWidget(widget, tester);

        await tester.enterText(find.byType(TextField), 'nsec1test');
        final result = await capturedSubmit();

        expect(capturedNsec, 'nsec1test');
        expect(result, true);
      });

      testWidgets('sets loading state during submit', (tester) async {
        bool loginCalled = false;
        late Completer<void> loginCompleter;
        late Future<bool> Function() capturedSubmit;
        late LoginState capturedState;

        final widget = _TestWidget(
          loginCallback: (_) async {
            loginCalled = true;
            await loginCompleter.future;
          },
          onBuild: (controller, state, paste, submit, clearError) {
            capturedSubmit = submit;
            capturedState = state;
          },
        );
        await mountWidget(widget, tester);

        loginCompleter = Completer<void>();
        await tester.enterText(find.byType(TextField), 'nsec1test');

        final submitFuture = capturedSubmit();
        await tester.pump();

        expect(capturedState.isLoading, true);
        expect(loginCalled, true);

        loginCompleter.complete();
        await submitFuture;
        await tester.pump();

        expect(capturedState.isLoading, false);
      });

      testWidgets('sets error message on failure', (tester) async {
        late Future<bool> Function() capturedSubmit;
        late LoginState capturedState;

        final widget = _TestWidget(
          loginCallback: (_) async {
            throw Exception('Invalid key');
          },
          onBuild: (controller, state, paste, submit, clearError) {
            capturedSubmit = submit;
            capturedState = state;
          },
        );
        await mountWidget(widget, tester);

        await tester.enterText(find.byType(TextField), 'nsec1test');

        final result = await capturedSubmit();
        await tester.pump();

        expect(result, false);
        expect(capturedState.error, 'Oh no! An error occurred, please try again.');
      });

      testWidgets('returns true on success', (tester) async {
        late Future<bool> Function() capturedSubmit;

        final widget = _TestWidget(
          loginCallback: (_) async {},
          onBuild: (controller, state, paste, submit, clearError) {
            capturedSubmit = submit;
          },
        );
        await mountWidget(widget, tester);

        await tester.enterText(find.byType(TextField), 'nsec1test');

        final result = await capturedSubmit();
        expect(result, true);
      });
    });

    group('paste', () {
      late void Function(Map<String, dynamic>?) setClipboardData;
      late void Function(Object) setClipboardException;
      late void Function() resetClipboard;

      setUp(() {
        final mock = mockClipboardPaste();
        setClipboardData = mock.setData;
        setClipboardException = mock.setException;
        resetClipboard = mock.reset;
      });

      tearDown(() {
        resetClipboard();
      });

      testWidgets('pastes clipboard text into controller', (tester) async {
        late TextEditingController capturedController;
        late Future<void> Function() capturedPaste;

        final widget = _TestWidget(
          loginCallback: (_) async {},
          onBuild: (controller, state, paste, submit, clearError) {
            capturedController = controller;
            capturedPaste = paste;
          },
        );
        await mountWidget(widget, tester);

        setClipboardData({'text': 'nsec1pasted'});

        await capturedPaste();
        await tester.pumpAndSettle();

        expect(capturedController.text, 'nsec1pasted');
      });

      testWidgets('clears error when pasting', (tester) async {
        late Future<void> Function() capturedPaste;
        late Future<bool> Function() capturedSubmit;
        late LoginState capturedState;

        final widget = _TestWidget(
          loginCallback: (_) async {
            throw Exception('Invalid key');
          },
          onBuild: (controller, state, paste, submit, clearError) {
            capturedPaste = paste;
            capturedSubmit = submit;
            capturedState = state;
          },
        );
        await mountWidget(widget, tester);

        await tester.enterText(find.byType(TextField), 'nsec1test');
        await capturedSubmit();
        await tester.pump();

        expect(capturedState.error, isNotNull);

        setClipboardData({'text': 'nsec1pasted'});
        await capturedPaste();
        await tester.pump();

        expect(capturedState.error, isNull);
      });

      testWidgets('handles null clipboard gracefully', (tester) async {
        late TextEditingController capturedController;
        late Future<void> Function() capturedPaste;

        final widget = _TestWidget(
          loginCallback: (_) async {},
          onBuild: (controller, state, paste, submit, clearError) {
            capturedController = controller;
            capturedPaste = paste;
          },
        );
        await mountWidget(widget, tester);

        setClipboardData(null);

        await capturedPaste();
        await tester.pumpAndSettle();

        expect(capturedController.text, isEmpty);
      });

      testWidgets('trims whitespace from clipboard text', (tester) async {
        late TextEditingController capturedController;
        late Future<void> Function() capturedPaste;

        final widget = _TestWidget(
          loginCallback: (_) async {},
          onBuild: (controller, state, paste, submit, clearError) {
            capturedController = controller;
            capturedPaste = paste;
          },
        );
        await mountWidget(widget, tester);

        setClipboardData({'text': '   nsec1pasted   '});

        await capturedPaste();
        await tester.pumpAndSettle();

        expect(capturedController.text, 'nsec1pasted');
      });

      testWidgets('shows error when clipboard contains only whitespace', (tester) async {
        late LoginState capturedState;
        late Future<void> Function() capturedPaste;

        final widget = _TestWidget(
          loginCallback: (_) async {},
          onBuild: (controller, state, paste, submit, clearError) {
            capturedPaste = paste;
            capturedState = state;
          },
        );
        await mountWidget(widget, tester);

        setClipboardData({'text': '   '});

        await capturedPaste();
        await tester.pumpAndSettle();

        expect(capturedState.error, 'Nothing to paste');
      });

      testWidgets('shows error when clipboard is empty string', (tester) async {
        late LoginState capturedState;
        late Future<void> Function() capturedPaste;

        final widget = _TestWidget(
          loginCallback: (_) async {},
          onBuild: (controller, state, paste, submit, clearError) {
            capturedPaste = paste;
            capturedState = state;
          },
        );
        await mountWidget(widget, tester);

        setClipboardData({'text': ''});

        await capturedPaste();
        await tester.pumpAndSettle();

        expect(capturedState.error, 'Nothing to paste');
      });

      testWidgets('handles clipboard exception gracefully', (tester) async {
        late LoginState capturedState;
        late Future<void> Function() capturedPaste;

        final widget = _TestWidget(
          loginCallback: (_) async {},
          onBuild: (controller, state, paste, submit, clearError) {
            capturedPaste = paste;
            capturedState = state;
          },
        );
        await mountWidget(widget, tester);

        setClipboardException(Exception('Clipboard not available'));

        await capturedPaste();
        await tester.pumpAndSettle();

        expect(capturedState.error, 'Failed to paste from clipboard');
      });
    });

    group('clearError', () {
      testWidgets('clears error', (tester) async {
        late Future<bool> Function() capturedSubmit;
        late void Function() capturedClearError;
        late LoginState capturedState;

        final widget = _TestWidget(
          loginCallback: (_) async {
            throw Exception('Invalid key');
          },
          onBuild: (controller, state, paste, submit, clearError) {
            capturedSubmit = submit;
            capturedClearError = clearError;
            capturedState = state;
          },
        );
        await mountWidget(widget, tester);

        await tester.enterText(find.byType(TextField), 'nsec1test');
        await capturedSubmit();
        await tester.pump();

        expect(capturedState.error, isNotNull);

        capturedClearError();
        await tester.pump();

        expect(capturedState.error, isNull);
      });
    });
  });
}
