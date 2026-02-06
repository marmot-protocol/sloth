import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/hooks/use_android_signer.dart';
import 'package:whitenoise/services/android_signer_service.dart';

import '../test_helpers.dart';

class MockAndroidSignerService implements AndroidSignerService {
  @override
  bool get platformIsAndroid => false;

  bool _isAvailable = false;
  String? _pubkeyToReturn;
  Exception? _errorToThrow;
  Exception? _isAvailableError;
  bool getPublicKeyCalled = false;

  void setAvailable(bool value) => _isAvailable = value;
  void setPubkeyToReturn(String value) => _pubkeyToReturn = value;
  void setErrorToThrow(Exception? value) => _errorToThrow = value;
  void setIsAvailableError(Exception? value) => _isAvailableError = value;

  @override
  Future<bool> isAvailable() async {
    if (_isAvailableError != null) throw _isAvailableError!;
    return _isAvailable;
  }

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

typedef AndroidSignerHookResult = ({
  bool isAvailable,
  bool isConnecting,
  String? error,
  Future<String> Function() connect,
  Future<void> Function() disconnect,
});

class _TestHookWidget extends HookWidget {
  const _TestHookWidget({required this.service, required this.onBuild});

  final AndroidSignerService service;
  final void Function(AndroidSignerHookResult) onBuild;

  @override
  Widget build(BuildContext context) {
    final result = useAndroidSigner(service);
    onBuild(result);
    return const SizedBox();
  }
}

void main() {
  group('useAndroidSigner', () {
    late MockAndroidSignerService mockService;

    setUp(() {
      mockService = MockAndroidSignerService();
    });

    Future<AndroidSignerHookResult Function()> mountAndroidSignerHook(
      WidgetTester tester,
    ) async {
      late AndroidSignerHookResult result;
      setUpTestView(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: _TestHookWidget(
            service: mockService,
            onBuild: (r) => result = r,
          ),
        ),
      );
      return () => result;
    }

    testWidgets('initially has isAvailable false', (tester) async {
      final getResult = await mountAndroidSignerHook(tester);
      expect(getResult().isAvailable, isFalse);
    });

    testWidgets('sets isAvailable true when signer is available', (tester) async {
      mockService.setAvailable(true);
      final getResult = await mountAndroidSignerHook(tester);
      await tester.pumpAndSettle();
      expect(getResult().isAvailable, isTrue);
    });

    testWidgets('sets isAvailable false when isAvailable throws', (tester) async {
      mockService.setIsAvailableError(Exception('Platform error'));
      final getResult = await mountAndroidSignerHook(tester);
      await tester.pumpAndSettle();
      expect(getResult().isAvailable, isFalse);
    });

    testWidgets('connect calls getPublicKey on service', (tester) async {
      mockService.setAvailable(true);
      mockService.setPubkeyToReturn(testPubkeyA);

      final getResult = await mountAndroidSignerHook(tester);
      await tester.pumpAndSettle();

      final pubkey = await getResult().connect();

      expect(mockService.getPublicKeyCalled, isTrue);
      expect(pubkey, testPubkeyA);
    });

    testWidgets('connect rethrows exception from service', (tester) async {
      mockService.setAvailable(true);
      mockService.setErrorToThrow(
        const AndroidSignerException('USER_REJECTED', 'User rejected'),
      );

      final getResult = await mountAndroidSignerHook(tester);
      await tester.pumpAndSettle();

      expect(
        () => getResult().connect(),
        throwsA(isA<AndroidSignerException>()),
      );
    });

    testWidgets('sets error when connect throws non-AndroidSignerException', (tester) async {
      mockService.setAvailable(true);
      mockService.setErrorToThrow(Exception('Generic error'));

      final getResult = await mountAndroidSignerHook(tester);
      await tester.pumpAndSettle();

      try {
        await getResult().connect();
      } catch (_) {}
      await tester.pumpAndSettle();

      expect(getResult().error, 'Unable to connect to signer. Please try again.');
    });

    testWidgets('disconnect resets error state', (tester) async {
      mockService.setAvailable(true);
      mockService.setErrorToThrow(Exception('Generic error'));

      final getResult = await mountAndroidSignerHook(tester);
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
