import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:sloth/services/amber_signer_service.dart';
import 'package:sloth/src/rust/api/accounts.dart' as accounts_api;
import 'package:sloth/src/rust/api/error.dart';
import 'package:sloth/src/rust/api/relays.dart' as relays_api;
import 'package:sloth/src/rust/api/signer.dart' as signer_api;
import 'package:sloth/src/rust/api/users.dart' as users_api;

const _storageKey = 'active_account_pubkey';
const _loginMethodKey = 'login_method';
final _logger = Logger('AuthNotifier');

/// How the user authenticated with the app.
enum LoginMethod {
  /// User provided their nsec directly.
  nsec,

  /// User authenticated via external signer (Amber/NIP-55).
  amber,
}

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
    await storage.write(key: _loginMethodKey, value: LoginMethod.nsec.name);
    state = AsyncData(account.pubkey);
    _logger.info('Login successful');
  }

  /// Login using an external signer (Amber) via NIP-55.
  ///
  /// This will open the Amber app for the user to authorize this app.
  /// The pubkey is retrieved from Amber and used to find/create an account.
  /// The key package is signed and published using Amber.
  ///
  /// If the account has no key package relays configured, default relays
  /// will be automatically added.
  ///
  /// Parameters:
  /// - [pubkey]: The public key obtained from Amber
  /// - [onDisconnect]: Callback to disconnect from Amber on error
  Future<void> loginWithAmber({
    required String pubkey,
    required Future<void> Function() onDisconnect,
  }) async {
    _logger.info('Amber login attempt started');
    final storage = ref.read(secureStorageProvider);
    const amberService = AmberSignerService();

    try {
      // Login with external signer using callbacks that route to Amber
      final account = await signer_api.loginWithExternalSignerAndCallbacks(
        pubkey: pubkey,
        signEvent: (unsignedEventJson) async {
          _logger.fine('Signing event via Amber...');
          final response = await amberService.signEvent(
            eventJson: unsignedEventJson,
            currentUser: pubkey,
          );
          if (response.event == null) {
            throw const AmberSignerException('NO_EVENT', 'Amber did not return signed event');
          }
          return response.event!;
        },
        nip04Encrypt: (plaintext, recipientPubkey) async {
          _logger.fine('NIP-04 encrypting via Amber...');
          return amberService.nip04Encrypt(
            plaintext: plaintext,
            pubkey: recipientPubkey,
            currentUser: pubkey,
          );
        },
        nip04Decrypt: (ciphertext, senderPubkey) async {
          _logger.fine('NIP-04 decrypting via Amber...');
          return amberService.nip04Decrypt(
            encryptedText: ciphertext,
            pubkey: senderPubkey,
            currentUser: pubkey,
          );
        },
        nip44Encrypt: (plaintext, recipientPubkey) async {
          _logger.fine('NIP-44 encrypting via Amber...');
          return amberService.nip44Encrypt(
            plaintext: plaintext,
            pubkey: recipientPubkey,
            currentUser: pubkey,
          );
        },
        nip44Decrypt: (ciphertext, senderPubkey) async {
          _logger.fine('NIP-44 decrypting via Amber...');
          return amberService.nip44Decrypt(
            encryptedText: ciphertext,
            pubkey: senderPubkey,
            currentUser: pubkey,
          );
        },
      );

      // Ensure key package relays are configured
      await _ensureKeyPackageRelays(account.pubkey);

      users_api.userMetadata(pubkey: account.pubkey, blockingDataSync: false);
      await storage.write(key: _storageKey, value: account.pubkey);
      await storage.write(key: _loginMethodKey, value: LoginMethod.amber.name);
      state = AsyncData(account.pubkey);
      _logger.info('Amber login successful with key package published');
    } on ApiError catch (e) {
      // If login fails, disconnect from Amber and rethrow
      await onDisconnect();
      _logger.warning('Amber login failed: ${e.message}');
      rethrow;
    } on AmberSignerException catch (e) {
      // If signing fails, disconnect from Amber and rethrow
      await onDisconnect();
      _logger.warning('Amber signing failed: ${e.message}');
      rethrow;
    } catch (e) {
      // Catch any other unexpected errors and cleanup
      await onDisconnect();
      _logger.warning('Amber login failed with unexpected error: $e');
      rethrow;
    }
  }

  /// Ensures that the account has at least one key package relay configured.
  ///
  /// If no key package relays exist, adds default relays so the user can
  /// be invited to encrypted conversations.
  Future<void> _ensureKeyPackageRelays(String pubkey) async {
    try {
      final keyPackageRelayType = await relays_api.relayTypeKeyPackage();
      final existingRelays = await accounts_api.accountRelays(
        pubkey: pubkey,
        relayType: keyPackageRelayType,
      );

      if (existingRelays.isEmpty) {
        _logger.info('No key package relays found, adding defaults');

        // Default key package relays
        const defaultRelays = [
          'wss://relay.damus.io',
          'wss://nos.lol',
        ];

        for (final relayUrl in defaultRelays) {
          try {
            await accounts_api.addAccountRelay(
              pubkey: pubkey,
              url: relayUrl,
              relayType: keyPackageRelayType,
            );
            _logger.info('Added default key package relay: $relayUrl');
          } catch (e) {
            _logger.warning('Failed to add default relay $relayUrl: $e');
            // Continue adding other relays even if one fails
          }
        }
      } else {
        _logger.info('Key package relays already configured (${existingRelays.length} found)');
      }
    } catch (e) {
      _logger.warning('Failed to ensure key package relays: $e');
      // Don't throw - this is a best-effort enhancement
    }
  }

  /// Gets the current login method.
  Future<LoginMethod?> getLoginMethod() async {
    final storage = ref.read(secureStorageProvider);
    final method = await storage.read(key: _loginMethodKey);
    if (method == null) return null;
    final loginMethod = LoginMethod.values.where((e) => e.name == method).firstOrNull;
    if (loginMethod == null) {
      throw StateError('Unknown login method in storage: $method');
    }
    return loginMethod;
  }

  /// Whether the current session is using Amber for signing.
  Future<bool> isUsingAmber() async {
    final method = await getLoginMethod();
    return method == LoginMethod.amber;
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

  Future<void> logout({Future<void> Function()? onAmberDisconnect}) async {
    final pubkey = state.value;
    if (pubkey == null) return;

    _logger.info('Logout started');
    final storage = ref.read(secureStorageProvider);

    // Disconnect from Amber if logged in via Amber
    if (await isUsingAmber() && onAmberDisconnect != null) {
      await onAmberDisconnect();
    }

    await accounts_api.logout(pubkey: pubkey);
    await storage.delete(key: _storageKey);
    await storage.delete(key: _loginMethodKey);
    state = const AsyncData(null);
    _logger.info('Logout successful');
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, String?>(AuthNotifier.new);
