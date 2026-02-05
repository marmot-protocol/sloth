import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';
import 'package:sloth/src/rust/api/accounts.dart' as accounts_api;
import 'package:sloth/src/rust/api/error.dart';

final _logger = Logger('useNsec');

enum NsecStorage {
  local,
  externalSigner,
}

class NsecState {
  final String? nsec;
  final bool isLoading;
  final String? error;
  final NsecStorage? nsecStorage;

  const NsecState({
    this.nsec,
    this.isLoading = false,
    this.error,
    this.nsecStorage,
  });

  NsecState copyWith({
    String? nsec,
    bool? isLoading,
    String? error,
    bool clearError = false,
    NsecStorage? nsecStorage,
  }) {
    return NsecState(
      nsec: nsec ?? this.nsec,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      nsecStorage: nsecStorage ?? this.nsecStorage,
    );
  }
}

({NsecState nsecState}) useNsec(String? pubkey) {
  final state = useState(const NsecState());

  Future<NsecStorage> resolveNsecStorage(String pubkey) async {
    try {
      final account = await accounts_api.getAccount(pubkey: pubkey);
      return account.accountType == accounts_api.AccountType.external_
          ? NsecStorage.externalSigner
          : NsecStorage.local;
    } on ApiError catch (e) {
      _logger.warning('Failed to read account type: ${e.message}');
      return NsecStorage.local;
    }
  }

  Future<void> loadNsec([bool Function()? isDisposed]) async {
    if (pubkey == null) return;
    final checkDisposed = isDisposed ?? () => false;

    state.value = state.value.copyWith(isLoading: true, clearError: true);

    final storage = await resolveNsecStorage(pubkey);
    if (checkDisposed()) return;
    state.value = state.value.copyWith(nsecStorage: storage);

    if (storage == NsecStorage.local) {
      try {
        final nsec = await accounts_api.exportAccountNsec(pubkey: pubkey);
        if (checkDisposed()) return;
        state.value = state.value.copyWith(
          nsec: nsec,
          isLoading: false,
        );
      } catch (e) {
        _logger.severe('Failed to load nsec', e);
        if (checkDisposed()) return;
        state.value = state.value.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    } else {
      state.value = state.value.copyWith(isLoading: false);
    }
  }

  useEffect(() {
    state.value = const NsecState();

    if (pubkey == null) return null;

    var disposed = false;
    loadNsec(() => disposed);
    return () {
      disposed = true;
    };
  }, [pubkey]);

  return (nsecState: state.value);
}
