import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/src/rust/api/accounts.dart' as accounts_api;

final _logger = Logger('useKeyPackages');

class KeyPackagesState {
  final bool isLoading;
  final List<accounts_api.FlutterEvent> packages;
  final String? error;

  const KeyPackagesState({
    this.isLoading = false,
    this.packages = const [],
    this.error,
  });

  KeyPackagesState copyWith({
    bool? isLoading,
    List<accounts_api.FlutterEvent>? packages,
    String? error,
    bool clearError = false,
  }) {
    return KeyPackagesState(
      isLoading: isLoading ?? this.isLoading,
      packages: packages ?? this.packages,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

({
  KeyPackagesState state,
  Future<void> Function() fetch,
  Future<void> Function() publish,
  Future<void> Function(String id) delete,
  Future<void> Function() deleteAll,
})
useKeyPackages(WidgetRef ref) {
  final pubkey = ref.watch(accountPubkeyProvider);
  final state = useState(const KeyPackagesState());

  Future<void> fetch() async {
    state.value = state.value.copyWith(isLoading: true, clearError: true);
    try {
      final packages = await accounts_api.accountKeyPackages(accountPubkey: pubkey);
      state.value = state.value.copyWith(isLoading: false, packages: packages);
    } catch (e) {
      _logger.severe('Failed to fetch key packages', e);
      state.value = state.value.copyWith(isLoading: false, error: 'Failed to fetch key packages');
    }
  }

  Future<void> publish() async {
    state.value = state.value.copyWith(isLoading: true, clearError: true);
    try {
      await accounts_api.publishAccountKeyPackage(accountPubkey: pubkey);
      final packages = await accounts_api.accountKeyPackages(accountPubkey: pubkey);
      state.value = state.value.copyWith(isLoading: false, packages: packages);
    } catch (e) {
      _logger.severe('Failed to publish key package', e);
      state.value = state.value.copyWith(isLoading: false, error: 'Failed to publish key package');
    }
  }

  Future<void> delete(String id) async {
    if (state.value.isLoading) return;
    state.value = state.value.copyWith(isLoading: true, clearError: true);
    try {
      await accounts_api.deleteAccountKeyPackage(accountPubkey: pubkey, keyPackageId: id);
      final packages = await accounts_api.accountKeyPackages(accountPubkey: pubkey);
      state.value = state.value.copyWith(isLoading: false, packages: packages);
    } catch (e) {
      _logger.severe('Failed to delete key package', e);
      state.value = state.value.copyWith(isLoading: false, error: 'Failed to delete key package');
    }
  }

  Future<void> deleteAll() async {
    state.value = state.value.copyWith(isLoading: true, clearError: true);
    try {
      await accounts_api.deleteAccountKeyPackages(accountPubkey: pubkey);
      state.value = state.value.copyWith(isLoading: false, packages: []);
    } catch (e) {
      _logger.severe('Failed to delete all key packages', e);
      state.value = state.value.copyWith(isLoading: false, error: 'Failed to delete key packages');
    }
  }

  return (
    state: state.value,
    fetch: fetch,
    publish: publish,
    delete: delete,
    deleteAll: deleteAll,
  );
}
