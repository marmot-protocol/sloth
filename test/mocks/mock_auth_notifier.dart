import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:whitenoise/providers/auth_provider.dart';

import '../test_helpers.dart';

class MockAuthNotifier extends AuthNotifier {
  final String _overridePubkey = testPubkeyA;

  @override
  Future<String?> build() async {
    final storage = ref.read(secureStorageProvider);
    final storedPubkey = await storage.read(key: 'active_account_pubkey');

    if (storedPubkey == null) {
      await storage.write(key: 'active_account_pubkey', value: _overridePubkey);
    }

    final pubkey = storedPubkey ?? _overridePubkey;
    state = AsyncData(pubkey);
    return pubkey;
  }

  @override
  Future<void> resetAuth() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: 'active_account_pubkey');
    state = const AsyncData(null);
  }
}
