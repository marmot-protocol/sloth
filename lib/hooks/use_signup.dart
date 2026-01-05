import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sloth/providers/auth_provider.dart' show authProvider;
import 'package:sloth/services/profile_service.dart' show ProfileService;

final _logger = Logger('useSignup');

class SignupState {
  final bool isLoading;
  final String? error;
  final String? displayNameError;
  final String? selectedImagePath;

  const SignupState({
    this.isLoading = false,
    this.error,
    this.displayNameError,
    this.selectedImagePath,
  });

  SignupState copyWith({
    bool? isLoading,
    String? error,
    String? displayNameError,
    bool clearError = false,
    String? selectedImagePath,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      displayNameError: clearError ? null : (displayNameError ?? this.displayNameError),
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
    );
  }
}

typedef SignupCallback =
    Future<bool> Function({
      required String displayName,
      String? bio,
    });

typedef OnImageSelectedCallback = void Function(String imagePath);

typedef ClearErrorsCallback = void Function();

({
  SignupState state,
  SignupCallback submit,
  OnImageSelectedCallback onImageSelected,
  ClearErrorsCallback clearErrors,
})
useSignup(WidgetRef ref) {
  final state = useState(const SignupState());

  void onImageSelected(String imagePath) {
    state.value = state.value.copyWith(
      selectedImagePath: imagePath,
      clearError: true,
    );
  }

  Future<bool> submit({
    required String displayName,
    String? bio,
  }) async {
    if (displayName.trim().isEmpty) {
      state.value = state.value.copyWith(
        displayNameError: 'Please enter your name',
      );
      return false;
    }

    state.value = state.value.copyWith(isLoading: true, clearError: true);

    try {
      final pubkey = await ref.read(authProvider.notifier).signup();
      final profileService = ProfileService(pubkey);

      String? pictureUrl;
      if (state.value.selectedImagePath != null) {
        pictureUrl = await profileService.uploadProfilePicture(
          filePath: state.value.selectedImagePath!,
        );
      }

      await profileService.setProfile(
        displayName: displayName.trim(),
        about: bio?.isNotEmpty == true ? bio : null,
        pictureUrl: pictureUrl,
      );

      state.value = state.value.copyWith(isLoading: false);
      _logger.info('Signup flow completed successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Signup failed', e, stackTrace);
      state.value = state.value.copyWith(
        isLoading: false,
        error: 'Oh no! An error occurred, please try again.',
      );
      return false;
    }
  }

  void clearErrors() {
    if (state.value.error != null || state.value.displayNameError != null) {
      state.value = state.value.copyWith(clearError: true);
    }
  }

  return (
    state: state.value,
    submit: submit,
    onImageSelected: onImageSelected,
    clearErrors: clearErrors,
  );
}
