import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';
import 'package:whitenoise/src/rust/api/accounts.dart' as accounts_api;

final _logger = Logger('useNsec');

class NsecState {
  final String? nsec;
  final bool isLoading;
  final String? error;

  const NsecState({
    this.nsec,
    this.isLoading = false,
    this.error,
  });

  NsecState copyWith({
    String? nsec,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return NsecState(
      nsec: nsec ?? this.nsec,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

({
  NsecState state,
  Future<void> Function() loadNsec,
})
useNsec(String? pubkey) {
  final state = useState(const NsecState());

  useEffect(() {
    state.value = const NsecState();
    return null;
  }, [pubkey]);

  Future<void> loadNsec() async {
    if (pubkey == null) return;
    state.value = state.value.copyWith(isLoading: true, clearError: true);
    try {
      final nsec = await accounts_api.exportAccountNsec(pubkey: pubkey);
      state.value = state.value.copyWith(
        nsec: nsec,
        isLoading: false,
      );
    } catch (e) {
      _logger.severe('Failed to load nsec', e);
      state.value = state.value.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  return (
    state: state.value,
    loadNsec: loadNsec,
  );
}
