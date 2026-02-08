import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:whitenoise/providers/is_adding_account_provider.dart';
import 'package:whitenoise/services/android_signer_service.dart';
import 'package:whitenoise/src/rust/api/accounts.dart' as accounts_api;
import 'package:whitenoise/src/rust/api/error.dart';
import 'package:whitenoise/src/rust/api/users.dart' as users_api;

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
      final account = await accounts_api.getAccount(pubkey: pubkey);
      if (account.accountType == accounts_api.AccountType.external_) {
        await const AndroidSignerService().registerExternalSigner(pubkey);
      }
    } catch (e) {
      if (e is ApiError && e.message.contains('Account not found')) {
        await storage.delete(key: _storageKey);
        return null;
      }
    }
    return pubkey;
  }

  /// Login with a private key (nsec) or hex key.
  Future<void> loginWithNsec(String nsec) async {
    _logger.info('Login attempt started');
    final storage = ref.read(secureStorageProvider);
    final account = await accounts_api.login(nsecOrHexPrivkey: nsec);
    users_api.userMetadata(pubkey: account.pubkey, blockingDataSync: false);
    await storage.write(key: _storageKey, value: account.pubkey);
    state = AsyncData(account.pubkey);
    ref.read(isAddingAccountProvider.notifier).set(false);
    _logger.info('Login successful');
  }

  //  NIP-55 (https://github.com/nostr-protocol/nips/blob/master/55.md)
  Future<void> loginWithAndroidSigner({
    required String pubkey,
  }) async {
    _logger.info('Android signer login attempt started');
    final storage = ref.read(secureStorageProvider);
    final signerService = const AndroidSignerService();

    try {
      final account = await signerService.loginWithExternalSigner(pubkey);

      users_api.userMetadata(pubkey: account.pubkey, blockingDataSync: false);
      await storage.write(key: _storageKey, value: account.pubkey);
      state = AsyncData(account.pubkey);
      ref.read(isAddingAccountProvider.notifier).set(false);
      _logger.info('Android signer login successful with key package published');
    } catch (e) {
      _logger.warning('Android signer login failed with unexpected error: $e');
      rethrow;
    }
  }

  /// Create a new identity (signup).
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

  /// Switch the active profile to the given pubkey.
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
