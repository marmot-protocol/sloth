import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/android_signer_service_provider.dart';
import 'package:sloth/services/android_signer_service.dart';

import '../test_helpers.dart';

void main() {
  group('androidSignerServiceProvider', () {
    test('returns AndroidSignerService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(androidSignerServiceProvider);

      expect(service, isA<AndroidSignerService>());
    });

    test('can be overridden', () {
      final mockService = _MockAndroidSignerService();
      final container = ProviderContainer(
        overrides: [
          androidSignerServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final service = container.read(androidSignerServiceProvider);

      expect(service, same(mockService));
    });
  });
}

class _MockAndroidSignerService implements AndroidSignerService {
  @override
  bool get platformIsAndroid => false;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<String> getPublicKey({List<SignerPermission>? permissions}) async => testPubkeyA;

  @override
  Future<AndroidSignerResponse> signEvent({
    required String eventJson,
    String? id,
    String? currentUser,
  }) async => throw UnimplementedError();

  @override
  Future<String> nip04Encrypt({
    required String plaintext,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async => throw UnimplementedError();

  @override
  Future<String> nip04Decrypt({
    required String encryptedText,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async => throw UnimplementedError();

  @override
  Future<String> nip44Encrypt({
    required String plaintext,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async => throw UnimplementedError();

  @override
  Future<String> nip44Decrypt({
    required String encryptedText,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async => throw UnimplementedError();

  @override
  Future<String?> getSignerPackageName() async => null;

  @override
  Future<void> setSignerPackageName(String packageName) async {}
}
