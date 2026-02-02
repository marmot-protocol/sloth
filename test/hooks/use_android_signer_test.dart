import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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

class _TestWidget extends HookWidget {
  const _TestWidget({
    required this.service,
    required this.onBuild,
  });

  final AndroidSignerService service;
  final void Function(
    bool isAvailable,
    bool isConnecting,
    String? error,
    Future<String> Function() connect,
    Future<void> Function() disconnect,
  )
  onBuild;

  @override
  Widget build(BuildContext context) {
    final result = useAndroidSigner(service: service);
    onBuild(
      result.isAvailable,
      result.isConnecting,
      result.error,
      result.connect,
      result.disconnect,
    );
    return const SizedBox();
  }
}

void main() {
  group('useAndroidSigner', () {
    testWidgets('initially has isAvailable false', (tester) async {
      final mockService = MockAndroidSignerService();
      late bool capturedIsAvailable;

      setUpTestView(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: _TestWidget(
            service: mockService,
            onBuild: (isAvailable, isConnecting, error, connect, disconnect) {
              capturedIsAvailable = isAvailable;
            },
          ),
        ),
      );

      expect(capturedIsAvailable, isFalse);
    });

    testWidgets('sets isAvailable true when signer is available', (tester) async {
      final mockService = MockAndroidSignerService();
      mockService.setAvailable(true);
      late bool capturedIsAvailable;

      setUpTestView(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: _TestWidget(
            service: mockService,
            onBuild: (isAvailable, isConnecting, error, connect, disconnect) {
              capturedIsAvailable = isAvailable;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(capturedIsAvailable, isTrue);
    });

    testWidgets('connect calls getPublicKey on service', (tester) async {
      final mockService = MockAndroidSignerService();
      mockService.setAvailable(true);
      mockService.setPubkeyToReturn(testPubkeyA);
      late Future<String> Function() capturedConnect;

      setUpTestView(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: _TestWidget(
            service: mockService,
            onBuild: (isAvailable, isConnecting, error, connect, disconnect) {
              capturedConnect = connect;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final pubkey = await capturedConnect();

      expect(mockService.getPublicKeyCalled, isTrue);
      expect(pubkey, testPubkeyA);
    });

    testWidgets('connect rethrows exception from service', (tester) async {
      final mockService = MockAndroidSignerService();
      mockService.setAvailable(true);
      mockService.setErrorToThrow(
        const AndroidSignerException('USER_REJECTED', 'User rejected'),
      );
      late Future<String> Function() capturedConnect;

      setUpTestView(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: _TestWidget(
            service: mockService,
            onBuild: (isAvailable, isConnecting, error, connect, disconnect) {
              capturedConnect = connect;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        () => capturedConnect(),
        throwsA(isA<AndroidSignerException>()),
      );
    });

    testWidgets('sets error when connect throws non-AndroidSignerException', (tester) async {
      final mockService = MockAndroidSignerService();
      mockService.setAvailable(true);
      mockService.setErrorToThrow(Exception('Generic error'));
      late Future<String> Function() capturedConnect;
      late String? capturedError;

      setUpTestView(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: _TestWidget(
            service: mockService,
            onBuild: (isAvailable, isConnecting, error, connect, disconnect) {
              capturedConnect = connect;
              capturedError = error;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      try {
        await capturedConnect();
      } catch (_) {}
      await tester.pumpAndSettle();

      expect(capturedError, 'Unable to connect to signer. Please try again.');
    });
  });
}
