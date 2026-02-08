import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';
import 'package:whitenoise/services/android_signer_service.dart';

final _logger = Logger('useLoginWithAndroidSigner');

class LoginWithAndroidSignerState {
  final bool isLoading;
  final String? error;

  const LoginWithAndroidSignerState({
    this.isLoading = false,
    this.error,
  });

  LoginWithAndroidSignerState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LoginWithAndroidSignerState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

typedef LoginWithAndroidSignerCallback = Future<void> Function(String pubkey);

({
  bool isAndroidSignerAvailable,
  LoginWithAndroidSignerState loginWithAndroidSignerState,
  Future<bool> Function() submitLoginWithAndroidSigner,
  void Function() clearLoginWithAndroidSignerError,
})
useLoginWithAndroidSigner(LoginWithAndroidSignerCallback login) {
  final isAndroidSignerAvailable = useState(false);
  final state = useState(const LoginWithAndroidSignerState());

  useEffect(() {
    var disposed = false;

    Future<void> checkAvailability() async {
      final available = await const AndroidSignerService().isAvailable();
      if (!disposed) {
        isAndroidSignerAvailable.value = available;
      }
    }

    checkAvailability();
    return () {
      disposed = true;
    };
  }, []);

  void clearLoginWithAndroidSignerError() {
    if (state.value.error != null) {
      state.value = state.value.copyWith(clearError: true);
    }
  }

  Future<bool> submitLoginWithAndroidSigner() async {
    state.value = state.value.copyWith(isLoading: true, clearError: true);
    try {
      final pubkey = await const AndroidSignerService().getPublicKey();
      await login(pubkey);
      state.value = state.value.copyWith(isLoading: false);
      return true;
    } on AndroidSignerException catch (e, stackTrace) {
      _logger.severe('Android signer login failed', e, stackTrace);
      state.value = state.value.copyWith(isLoading: false, error: e.code);
      return false;
    } catch (e, stackTrace) {
      _logger.severe('Android signer login failed', e, stackTrace);
      state.value = state.value.copyWith(
        isLoading: false,
        error: 'CONNECTION_ERROR',
      );
      return false;
    }
  }

  return (
    isAndroidSignerAvailable: isAndroidSignerAvailable.value,
    loginWithAndroidSignerState: state.value,
    submitLoginWithAndroidSigner: submitLoginWithAndroidSigner,
    clearLoginWithAndroidSignerError: clearLoginWithAndroidSignerError,
  );
}
