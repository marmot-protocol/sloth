import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';

final _logger = Logger('useLogin');

class LoginState {
  final bool isLoading;
  final String? error;

  const LoginState({
    this.isLoading = false,
    this.error,
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

typedef LoginCallback = Future<void> Function(String nsec);

({
  TextEditingController controller,
  LoginState state,
  Future<void> Function() paste,
  Future<bool> Function() submit,
  void Function() clearError,
})
useLogin(LoginCallback login) {
  final controller = useTextEditingController();
  final state = useState(const LoginState());

  Future<void> paste() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text == null) {
        return;
      }

      final trimmedText = clipboardData!.text!.trim();
      if (trimmedText.isEmpty) {
        state.value = state.value.copyWith(
          error: 'Nothing to paste',
        );
        return;
      }

      controller.text = trimmedText;
      state.value = state.value.copyWith(clearError: true);
    } catch (e) {
      _logger.warning('Failed to paste from clipboard: $e');
      state.value = state.value.copyWith(
        error: 'Failed to paste from clipboard',
      );
    }
  }

  Future<bool> submit() async {
    final nsec = controller.text.trim();
    if (nsec.isEmpty) return false;

    state.value = state.value.copyWith(isLoading: true, clearError: true);

    try {
      await login(nsec);
      state.value = state.value.copyWith(isLoading: false);
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Login failed', e, stackTrace);
      state.value = state.value.copyWith(
        isLoading: false,
        error: 'Oh no! An error occurred, please try again.',
      );
      return false;
    }
  }

  void clearError() {
    if (state.value.error != null) {
      state.value = state.value.copyWith(clearError: true);
    }
  }

  return (
    controller: controller,
    state: state.value,
    paste: paste,
    submit: submit,
    clearError: clearError,
  );
}
