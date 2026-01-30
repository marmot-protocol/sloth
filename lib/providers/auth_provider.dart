import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:sloth/providers/is_adding_account_provider.dart';
import 'package:sloth/services/android_signer_service.dart';
import 'package:sloth/src/rust/api/accounts.dart' as accounts_api;
import 'package:sloth/src/rust/api/error.dart';
import 'package:sloth/src/rust/api/signer.dart' as signer_api;
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

  /// Login using an external signer via NIP-55.
  ///
  /// This will open the signer app for the user to authorize this app.
  /// The pubkey is retrieved from the signer and used to find/create an account.
  /// The key package is signed and published using the signer.
  ///
  /// If the account has no key package relays configured, default relays
  /// will be automatically added.
  ///
  /// Parameters:
  /// - [pubkey]: The public key obtained from the signer
  /// - [onDisconnect]: Callback to disconnect from the signer on error
  Future<void> loginWithAndroidSigner({
    required String pubkey,
    required Future<void> Function() onDisconnect,
  }) async {
    _logger.info('Android signer login attempt started');
    final storage = ref.read(secureStorageProvider);
    const signerService = AndroidSignerService();

    Future<void> safeDisconnect() async {
      try {
        await onDisconnect();
      } catch (e) {
        _logger.warning('Android signer disconnect failed: $e');
      }
    }

    try {
      // Login with external signer using callbacks
      final account = await signer_api.loginWithExternalSignerAndCallbacks(
        pubkey: pubkey,
        signEvent: (unsignedEventJson) async {
          _logger.fine('Signing event via Android signer...');
          final response = await signerService.signEvent(
            eventJson: unsignedEventJson,
            currentUser: pubkey,
          );
          if (response.event == null) {
            throw const AndroidSignerException(
              'NO_EVENT',
              'Signer did not return signed event',
            );
          }
          return response.event!;
        },
        nip04Encrypt: (plaintext, recipientPubkey) async {
          _logger.fine('NIP-04 encrypting via Android signer...');
          return signerService.nip04Encrypt(
            plaintext: plaintext,
            pubkey: recipientPubkey,
            currentUser: pubkey,
          );
        },
        nip04Decrypt: (ciphertext, senderPubkey) async {
          _logger.fine('NIP-04 decrypting via Android signer...');
          return signerService.nip04Decrypt(
            encryptedText: ciphertext,
            pubkey: senderPubkey,
            currentUser: pubkey,
          );
        },
        nip44Encrypt: (plaintext, recipientPubkey) async {
          _logger.fine('NIP-44 encrypting via Android signer...');
          return signerService.nip44Encrypt(
            plaintext: plaintext,
            pubkey: recipientPubkey,
            currentUser: pubkey,
          );
        },
        nip44Decrypt: (ciphertext, senderPubkey) async {
          _logger.fine('NIP-44 decrypting via Android signer...');
          return signerService.nip44Decrypt(
            encryptedText: ciphertext,
            pubkey: senderPubkey,
            currentUser: pubkey,
          );
        },
      );

      users_api.userMetadata(pubkey: account.pubkey, blockingDataSync: false);
      await storage.write(key: _storageKey, value: account.pubkey);
      state = AsyncData(account.pubkey);
      _logger.info('Android signer login successful with key package published');
    } on ApiError catch (e) {
      await safeDisconnect();
      _logger.warning('Android signer login failed: ${e.message}');
      rethrow;
    } on AndroidSignerException catch (e) {
      await safeDisconnect();
      _logger.warning('Android signer signing failed: ${e.message}');
      rethrow;
    } catch (e) {
      await safeDisconnect();
      _logger.warning('Android signer login failed with unexpected error: $e');
      rethrow;
    }
  }

  /// Whether the current session is using an Android signer for signing.
  Future<bool> isUsingAndroidSigner() async {
    final pubkey = state.value;
    if (pubkey == null) return false;

    try {
      final account = await accounts_api.getAccount(pubkey: pubkey);
      return account.accountType == accounts_api.AccountType.external_;
    } on ApiError catch (e) {
      _logger.warning('Failed to read account type: ${e.message}');
      return false;
    }
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

  Future<String?> logout({Future<void> Function()? onAndroidSignerDisconnect}) async {
    final pubkey = state.value;
    if (pubkey == null) return null;

    _logger.info('Logout started');
    final storage = ref.read(secureStorageProvider);

    // Disconnect from Android signer if logged in via signer
    if (await isUsingAndroidSigner() && onAndroidSignerDisconnect != null) {
      await onAndroidSignerDisconnect();
    }

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
