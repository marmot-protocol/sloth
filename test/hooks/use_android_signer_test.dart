import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/hooks/use_android_signer.dart';
import 'package:sloth/services/android_signer_service.dart';

import '../test_helpers.dart';

class MockAndroidSignerService implements AndroidSignerService {
  bool _isAvailable = false;
  String? _pubkeyToReturn;
  Exception? _errorToThrow;
  bool getPublicKeyCalled = false;

  void setAvailable(bool value) => _isAvailable = value;
  void setPubkeyToReturn(String value) => _pubkeyToReturn = value;
  void setErrorToThrow(Exception? value) => _errorToThrow = value;

  @override
  Future<bool> isAvailable() async => _isAvailable;

  @override
  Future<String> getPublicKey({List<SignerPermission>? permissions}) async {
    getPublicKeyCalled = true;
    if (_errorToThrow != null) throw _errorToThrow!;
    return _pubkeyToReturn ?? testPubkeyA;
  }

  @override
  Future<AndroidSignerResponse> signEvent({
    required String eventJson,
    String? id,
    String? currentUser,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String> nip04Encrypt({
    required String plaintext,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String> nip04Decrypt({
    required String encryptedText,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String> nip44Encrypt({
    required String plaintext,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String> nip44Decrypt({
    required String encryptedText,
    required String pubkey,
    String? currentUser,
    String? id,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getSignerPackageName() async => null;

  @override
  Future<void> setSignerPackageName(String packageName) async {}
}

void main() {
  group('useAndroidSigner', () {
    testWidgets('initially has isAvailable false', (tester) async {
      final mockService = MockAndroidSignerService();

      setUpTestView(tester);
      final getResult = await mountHook(
        tester,
        () => useAndroidSigner(service: mockService),
      );

      expect(getResult().isAvailable, isFalse);
    });

    testWidgets('sets isAvailable true when signer is available', (tester) async {
      final mockService = MockAndroidSignerService();
      mockService.setAvailable(true);

      setUpTestView(tester);
      final getResult = await mountHook(
        tester,
        () => useAndroidSigner(service: mockService),
      );
      await tester.pumpAndSettle();

      expect(getResult().isAvailable, isTrue);
    });

    testWidgets('connect calls getPublicKey on service', (tester) async {
      final mockService = MockAndroidSignerService();
      mockService.setAvailable(true);
      mockService.setPubkeyToReturn(testPubkeyA);

      setUpTestView(tester);
      final getResult = await mountHook(
        tester,
        () => useAndroidSigner(service: mockService),
      );
      await tester.pumpAndSettle();

      final pubkey = await getResult().connect();

      expect(mockService.getPublicKeyCalled, isTrue);
      expect(pubkey, testPubkeyA);
    });

    testWidgets('connect rethrows exception from service', (tester) async {
      final mockService = MockAndroidSignerService();
      mockService.setAvailable(true);
      mockService.setErrorToThrow(
        const AndroidSignerException('USER_REJECTED', 'User rejected'),
      );

      setUpTestView(tester);
      final getResult = await mountHook(
        tester,
        () => useAndroidSigner(service: mockService),
      );
      await tester.pumpAndSettle();

      expect(
        () => getResult().connect(),
        throwsA(isA<AndroidSignerException>()),
      );
    });

    testWidgets('sets error when connect throws non-AndroidSignerException', (tester) async {
      final mockService = MockAndroidSignerService();
      mockService.setAvailable(true);
      mockService.setErrorToThrow(Exception('Generic error'));

      setUpTestView(tester);
      final getResult = await mountHook(
        tester,
        () => useAndroidSigner(service: mockService),
      );
      await tester.pumpAndSettle();

      try {
        await getResult().connect();
      } catch (_) {}
      await tester.pumpAndSettle();

      expect(getResult().error, 'Unable to connect to signer. Please try again.');
    });

    testWidgets('disconnect resets error state', (tester) async {
      final mockService = MockAndroidSignerService();
      mockService.setAvailable(true);
      mockService.setErrorToThrow(Exception('Generic error'));

      setUpTestView(tester);
      final getResult = await mountHook(
        tester,
        () => useAndroidSigner(service: mockService),
      );
      await tester.pumpAndSettle();

      try {
        await getResult().connect();
      } catch (_) {}
      await tester.pumpAndSettle();

      expect(getResult().error, isNotNull);

      await getResult().disconnect();
      await tester.pumpAndSettle();

      expect(getResult().error, isNull);
    });
  });
}
