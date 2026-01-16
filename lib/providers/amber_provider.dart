import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/services/amber_signer_service.dart';

final _logger = Logger('AmberProvider');

const _amberPubkeyKey = 'amber_pubkey';
const _amberEnabledKey = 'amber_enabled';

/// Provider for the Amber signer service instance.
final amberSignerServiceProvider = Provider<AmberSignerService>(
  (_) => const AmberSignerService(),
);

/// State for Amber signer integration.
class AmberState {
  /// Whether an external signer (Amber) is available on this device.
  final bool isAvailable;

  /// Whether the user has connected via Amber (vs nsec login).
  final bool isEnabled;

  /// The public key from Amber (if connected).
  final String? pubkey;

  const AmberState({
    this.isAvailable = false,
    this.isEnabled = false,
    this.pubkey,
  });

  AmberState copyWith({
    bool? isAvailable,
    bool? isEnabled,
    String? pubkey,
  }) {
    return AmberState(
      isAvailable: isAvailable ?? this.isAvailable,
      isEnabled: isEnabled ?? this.isEnabled,
      pubkey: pubkey ?? this.pubkey,
    );
  }
}

/// Notifier for managing Amber signer state and operations.
class AmberNotifier extends AsyncNotifier<AmberState> {
  @override
  Future<AmberState> build() async {
    final service = ref.read(amberSignerServiceProvider);
    final storage = ref.read(secureStorageProvider);

    // Check if Amber is available on this device
    final isAvailable = await service.isAvailable();

    // Check if user previously connected via Amber
    final amberEnabled = await storage.read(key: _amberEnabledKey);
    final amberPubkey = await storage.read(key: _amberPubkeyKey);

    final isEnabled = amberEnabled == 'true' && amberPubkey != null;

    _logger.info('Amber state initialized: available=$isAvailable, enabled=$isEnabled');

    return AmberState(
      isAvailable: isAvailable,
      isEnabled: isEnabled,
      pubkey: amberPubkey,
    );
  }

  /// Connects to Amber and retrieves the user's public key.
  ///
  /// This initiates the NIP-55 flow, opening Amber for the user to
  /// select an account and authorize this app.
  ///
  /// Returns the public key on success.
  /// Throws [AmberSignerException] on failure.
  Future<String> connect() async {
    _logger.info('Connecting to Amber...');
    state = const AsyncLoading();

    try {
      final service = ref.read(amberSignerServiceProvider);
      final storage = ref.read(secureStorageProvider);

      // Request public key from Amber (this opens the Amber app)
      // Request all permissions Sloth needs upfront so Amber doesn't prompt repeatedly
      final pubkey = await service.getPublicKey(
        permissions: [
          // MLS event kinds (NIP-104)
          const AmberPermission(type: 'sign_event', kind: 443), // MLS Key Package
          const AmberPermission(type: 'sign_event', kind: 444), // MLS Welcome
          const AmberPermission(type: 'sign_event', kind: 445), // MLS Group Message
          // Gift wrap for MLS messages (NIP-59)
          const AmberPermission(type: 'sign_event', kind: 1059), // Gift Wrap
          // Relay lists
          const AmberPermission(type: 'sign_event', kind: 10002), // Relay List (NIP-65)
          const AmberPermission(type: 'sign_event', kind: 10050), // Inbox Relays (NIP-17)
          const AmberPermission(type: 'sign_event', kind: 10051), // MLS Key Package Relays
          // Encryption for gift wrap
          const AmberPermission(type: 'nip44_encrypt'),
          const AmberPermission(type: 'nip44_decrypt'),
        ],
      );

      // Save the Amber connection state
      await storage.write(key: _amberPubkeyKey, value: pubkey);
      await storage.write(key: _amberEnabledKey, value: 'true');

      final newState = AmberState(
        isAvailable: true,
        isEnabled: true,
        pubkey: pubkey,
      );

      state = AsyncData(newState);
      _logger.info('Connected to Amber successfully: ${pubkey.substring(0, 8)}...');

      return pubkey;
    } catch (e) {
      _logger.warning('Failed to connect to Amber: $e');
      // Restore previous state on error
      state = AsyncData(state.value ?? const AmberState());
      rethrow;
    }
  }

  /// Disconnects from Amber, clearing the saved state.
  Future<void> disconnect() async {
    _logger.info('Disconnecting from Amber...');
    final storage = ref.read(secureStorageProvider);

    await storage.delete(key: _amberPubkeyKey);
    await storage.delete(key: _amberEnabledKey);

    final currentState = state.value ?? const AmberState();
    state = AsyncData(AmberState(isAvailable: currentState.isAvailable));

    _logger.info('Disconnected from Amber');
  }

  /// Signs a Nostr event using Amber.
  ///
  /// Returns the signature (and optionally the full signed event).
  Future<AmberSignerResponse> signEvent({
    required String eventJson,
    String? id,
  }) async {
    final amberState = state.value;
    if (amberState == null || !amberState.isEnabled) {
      throw const AmberSignerException('NOT_CONNECTED', 'Not connected to Amber');
    }

    final service = ref.read(amberSignerServiceProvider);
    return service.signEvent(
      eventJson: eventJson,
      id: id,
      currentUser: amberState.pubkey,
    );
  }

  /// Encrypts text using NIP-04 via Amber.
  Future<String> nip04Encrypt({
    required String plaintext,
    required String recipientPubkey,
  }) async {
    final amberState = state.value;
    if (amberState == null || !amberState.isEnabled) {
      throw const AmberSignerException('NOT_CONNECTED', 'Not connected to Amber');
    }

    final service = ref.read(amberSignerServiceProvider);
    return service.nip04Encrypt(
      plaintext: plaintext,
      pubkey: recipientPubkey,
      currentUser: amberState.pubkey,
    );
  }

  /// Decrypts text using NIP-04 via Amber.
  Future<String> nip04Decrypt({
    required String encryptedText,
    required String senderPubkey,
  }) async {
    final amberState = state.value;
    if (amberState == null || !amberState.isEnabled) {
      throw const AmberSignerException('NOT_CONNECTED', 'Not connected to Amber');
    }

    final service = ref.read(amberSignerServiceProvider);
    return service.nip04Decrypt(
      encryptedText: encryptedText,
      pubkey: senderPubkey,
      currentUser: amberState.pubkey,
    );
  }

  /// Encrypts text using NIP-44 via Amber.
  Future<String> nip44Encrypt({
    required String plaintext,
    required String recipientPubkey,
  }) async {
    final amberState = state.value;
    if (amberState == null || !amberState.isEnabled) {
      throw const AmberSignerException('NOT_CONNECTED', 'Not connected to Amber');
    }

    final service = ref.read(amberSignerServiceProvider);
    return service.nip44Encrypt(
      plaintext: plaintext,
      pubkey: recipientPubkey,
      currentUser: amberState.pubkey,
    );
  }

  /// Decrypts text using NIP-44 via Amber.
  Future<String> nip44Decrypt({
    required String encryptedText,
    required String senderPubkey,
  }) async {
    final amberState = state.value;
    if (amberState == null || !amberState.isEnabled) {
      throw const AmberSignerException('NOT_CONNECTED', 'Not connected to Amber');
    }

    final service = ref.read(amberSignerServiceProvider);
    return service.nip44Decrypt(
      encryptedText: encryptedText,
      pubkey: senderPubkey,
      currentUser: amberState.pubkey,
    );
  }
}

/// Provider for Amber signer state and operations.
final amberProvider = AsyncNotifierProvider<AmberNotifier, AmberState>(
  AmberNotifier.new,
);
