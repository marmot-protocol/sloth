import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:sloth/src/rust/api/accounts.dart' as accounts_api;
import 'package:sloth/src/rust/api/error.dart';
import 'package:sloth/src/rust/api/users.dart' as users_api;

const _storageKey = 'active_account_pubkey';
final _logger = Logger('AuthNotifier');

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

class AuthNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final storage = ref.read(secureStorageProvider);
    final pubkey = await storage.read(key: _storageKey);
    if (pubkey == null || pubkey.isEmpty) return null;

    try {
      await accounts_api.getAccount(pubkey: pubkey);
    } catch (e) {
      if (e is ApiError && e.message.contains('Account not found')) {
        await storage.delete(key: _storageKey);
        return null;
      }
    }
    return pubkey;
  }

  Future<void> login(String nsec) async {
    _logger.info('Login attempt started');
    final storage = ref.read(secureStorageProvider);
    final account = await accounts_api.login(nsecOrHexPrivkey: nsec);
    users_api.userMetadata(pubkey: account.pubkey, blockingDataSync: false);
    await storage.write(key: _storageKey, value: account.pubkey);
    state = AsyncData(account.pubkey);
    ref.read(isAddingAccountProvider.notifier).set(false);
    _logger.info('Login successful');
  }

  Future<String> signup() async {
    _logger.info('Signup started');
    final storage = ref.read(secureStorageProvider);
    final account = await accounts_api.createIdentity();
    await storage.write(key: _storageKey, value: account.pubkey);
    state = AsyncData(account.pubkey);
    ref.read(isAddingAccountProvider.notifier).set(false);
    _logger.info('Signup successful - identity created');
    return account.pubkey;
  }

  Future<String?> logout() async {
    final pubkey = state.value;
    if (pubkey == null) return null;

    _logger.info('Logout started');
    final storage = ref.read(secureStorageProvider);
    await accounts_api.logout(pubkey: pubkey);
    await storage.delete(key: _storageKey);

    try {
      final remainingAccounts = await accounts_api.getAccounts();
      final otherAccounts = remainingAccounts.where((a) => a.pubkey != pubkey).toList();
      if (otherAccounts.isNotEmpty) {
        final nextAccount = otherAccounts.first;
        await storage.write(key: _storageKey, value: nextAccount.pubkey);
        state = AsyncData(nextAccount.pubkey);
        _logger.info('Logout successful - switched to another account');
        return nextAccount.pubkey;
      }
    } catch (e, stackTrace) {
      _logger.severe('Failed to switch to next account after logout', e, stackTrace);
    }

    state = const AsyncData(null);
    _logger.info('Logout successful - no remaining accounts');
    return null;
  }

  Future<void> switchProfile(String pubkey) async {
    _logger.info('Switching profile');
    final storage = ref.read(secureStorageProvider);
    try {
      await accounts_api.getAccount(pubkey: pubkey);
      await storage.write(key: _storageKey, value: pubkey);
      state = AsyncData(pubkey);
      _logger.info('Profile switched successfully');
    } catch (e) {
      if (e is ApiError && e.message.contains('Account not found')) {
        _logger.warning('Account not found during switch');
        await storage.delete(key: _storageKey);
        state = const AsyncData(null);
      } else {
        rethrow;
      }
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, String?>(AuthNotifier.new);

class IsAddingAccountNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final isAddingAccountProvider = NotifierProvider<IsAddingAccountNotifier, bool>(
  IsAddingAccountNotifier.new,
);
