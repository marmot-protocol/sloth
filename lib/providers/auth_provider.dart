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
    _logger.info('Login successful');
  }

  Future<String> signup() async {
    _logger.info('Signup started');
    final storage = ref.read(secureStorageProvider);
    final account = await accounts_api.createIdentity();
    await storage.write(key: _storageKey, value: account.pubkey);
    state = AsyncData(account.pubkey);
    _logger.info('Signup successful - identity created');
    return account.pubkey;
  }

  Future<void> logout() async {
    final pubkey = state.value;
    if (pubkey == null) return;

    _logger.info('Logout started');
    final storage = ref.read(secureStorageProvider);
    await accounts_api.logout(pubkey: pubkey);
    await storage.delete(key: _storageKey);
    state = const AsyncData(null);
    _logger.info('Logout successful');
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, String?>(AuthNotifier.new);
