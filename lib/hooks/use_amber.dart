import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:sloth/services/amber_signer_service.dart';

final _logger = Logger('useAmber');

const _amberPubkeyKey = 'amber_pubkey';
const _amberEnabledKey = 'amber_enabled';

/// Hook for managing Amber signer integration.
///
/// Provides ephemeral state for Amber availability, connection status,
/// and methods to connect/disconnect from the Amber signer.
({
  bool isAvailable,
  bool isConnecting,
  String? error,
  Future<String> Function() connect,
  Future<void> Function() disconnect,
})
useAmber() {
  final amberService = useMemoized(() => const AmberSignerService());
  final storage = useMemoized(() => const FlutterSecureStorage());

  final isAvailable = useState(false);
  final isConnecting = useState(false);
  final error = useState<String?>(null);

  // Check Amber availability on mount
  useEffect(() {
    void checkAvailability() async {
      final available = await amberService.isAvailable();
      isAvailable.value = available;
    }

    checkAvailability();
    return null;
  }, const []);

  Future<String> connect() async {
    _logger.info('Connecting to Amber...');
    isConnecting.value = true;
    error.value = null;

    try {
      // Request public key from Amber (this opens the Amber app)
      // Request all permissions Sloth needs upfront so Amber doesn't prompt repeatedly
      final pubkey = await amberService.getPublicKey(
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

      _logger.info('Connected to Amber successfully: ${pubkey.substring(0, 8)}...');
      return pubkey;
    } catch (e) {
      _logger.warning('Failed to connect to Amber: $e');
      error.value = e.toString();
      rethrow;
    } finally {
      isConnecting.value = false;
    }
  }

  Future<void> disconnect() async {
    _logger.info('Disconnecting from Amber...');
    await storage.delete(key: _amberPubkeyKey);
    await storage.delete(key: _amberEnabledKey);
    _logger.info('Disconnected from Amber');
  }

  return (
    isAvailable: isAvailable.value,
    isConnecting: isConnecting.value,
    error: error.value,
    connect: connect,
    disconnect: disconnect,
  );
}
