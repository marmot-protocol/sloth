import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';
import 'package:sloth/services/android_signer_service.dart';

final _logger = Logger('useAndroidSigner');

/// Hook for managing Android signer (NIP-55) integration.
///
/// Provides ephemeral state for signer availability, connection status,
/// and methods to connect/disconnect from the Android signer.
///
/// [service] can be provided for testing purposes. If not provided,
/// a default [AndroidSignerService] will be created.
({
  bool isAvailable,
  bool isConnecting,
  String? error,
  Future<String> Function() connect,
  Future<void> Function() disconnect,
})
useAndroidSigner({AndroidSignerService? service}) {
  final signerService = useMemoized(() => service ?? const AndroidSignerService());

  final isAvailable = useState(false);
  final isConnecting = useState(false);
  final error = useState<String?>(null);

  // Check signer availability on mount
  useEffect(() {
    var disposed = false;

    Future<void> checkAvailability() async {
      try {
        final available = await signerService.isAvailable();
        if (!disposed) {
          isAvailable.value = available;
        }
      } catch (e, stackTrace) {
        _logger.warning('Failed to check Android signer availability', e, stackTrace);
        if (!disposed) {
          isAvailable.value = false;
        }
      }
    }

    checkAvailability();
    return () {
      disposed = true;
    };
  }, const []);

  /// Connect to the Android signer.
  ///
  /// This will open the signer app (if available) and request the user to
  /// authorize the app. It returns the public key of the selected account.
  Future<String> connect() async {
    _logger.info('Connecting to Android signer...');
    isConnecting.value = true;
    error.value = null;

    try {
      // Request public key from signer (this opens the signer app)
      // Request all permissions Sloth needs upfront so signer doesn't prompt repeatedly
      final pubkey = await signerService.getPublicKey(
        permissions: [
          // MLS event kinds (NIP-104)
          const SignerPermission(type: 'sign_event', kind: 443), // MLS Key Package
          const SignerPermission(type: 'sign_event', kind: 444), // MLS Welcome
          const SignerPermission(type: 'sign_event', kind: 445), // MLS Group Message
          // Gift wrap for MLS messages (NIP-59)
          const SignerPermission(type: 'sign_event', kind: 1059), // Gift Wrap
          // Relay lists
          const SignerPermission(type: 'sign_event', kind: 10002), // Relay List (NIP-65)
          const SignerPermission(type: 'sign_event', kind: 10050), // Inbox Relays (NIP-17)
          const SignerPermission(type: 'sign_event', kind: 10051), // MLS Key Package Relays
          // Encryption for gift wrap
          const SignerPermission(type: 'nip44_encrypt'),
          const SignerPermission(type: 'nip44_decrypt'),
        ],
      );

      _logger.info('Connected to signer successfully: ${pubkey.substring(0, 8)}...');
      return pubkey;
    } catch (e) {
      _logger.warning('Failed to connect to signer: $e');
      error.value = 'Unable to connect to signer. Please try again.';
      rethrow;
    } finally {
      isConnecting.value = false;
    }
  }

  /// Reset local ephemeral state for the Android signer.
  ///
  /// NIP-55 does not define a disconnect operation - the signer app manages its
  /// own lifecycle and permissions. This method simply resets any local error
  /// state to allow a fresh connection attempt.
  ///
  /// The [AndroidSignerService] manages the signer package name separately.
  Future<void> disconnect() async {
    _logger.info('Resetting Android signer state...');
    error.value = null;
    _logger.info('Android signer state reset');
  }

  return (
    isAvailable: isAvailable.value,
    isConnecting: isConnecting.value,
    error: error.value,
    connect: connect,
    disconnect: disconnect,
  );
}
