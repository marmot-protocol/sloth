import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/services/android_signer_service.dart';

import '../mocks/mock_android_signer_channel.dart';
import '../test_helpers.dart';

void main() {
  group('AndroidSignerException', () {
    test('toString returns formatted string', () {
      const exception = AndroidSignerException('TEST_CODE', 'Test message');
      expect(exception.toString(), 'AndroidSignerException(TEST_CODE): Test message');
    });

    group('userFriendlyMessage', () {
      test('returns correct message for USER_REJECTED', () {
        const exception = AndroidSignerException('USER_REJECTED', 'User rejected');
        expect(exception.userFriendlyMessage, 'Login cancelled');
      });

      test('returns correct message for NOT_CONNECTED', () {
        const exception = AndroidSignerException('NOT_CONNECTED', 'Not connected');
        expect(exception.userFriendlyMessage, 'Not connected to signer. Please try again.');
      });

      test('returns correct message for NO_SIGNER', () {
        const exception = AndroidSignerException('NO_SIGNER', 'No signer');
        expect(
          exception.userFriendlyMessage,
          'No signer app found. Please install a NIP-55 compatible signer.',
        );
      });

      test('returns correct message for NO_RESPONSE', () {
        const exception = AndroidSignerException('NO_RESPONSE', 'No response');
        expect(exception.userFriendlyMessage, 'No response from signer. Please try again.');
      });

      test('returns correct message for NO_PUBKEY', () {
        const exception = AndroidSignerException('NO_PUBKEY', 'No pubkey');
        expect(exception.userFriendlyMessage, 'Unable to get public key from signer.');
      });

      test('returns correct message for NO_RESULT', () {
        const exception = AndroidSignerException('NO_RESULT', 'No result');
        expect(exception.userFriendlyMessage, 'Signer did not return a result.');
      });

      test('returns correct message for NO_EVENT', () {
        const exception = AndroidSignerException('NO_EVENT', 'No event');
        expect(exception.userFriendlyMessage, 'Signer did not return a signed event.');
      });

      test('returns correct message for REQUEST_IN_PROGRESS', () {
        const exception = AndroidSignerException('REQUEST_IN_PROGRESS', 'In progress');
        expect(exception.userFriendlyMessage, 'Another request is in progress. Please wait.');
      });

      test('returns correct message for NO_ACTIVITY', () {
        const exception = AndroidSignerException('NO_ACTIVITY', 'No activity');
        expect(exception.userFriendlyMessage, 'Unable to launch signer. Please try again.');
      });

      test('returns correct message for LAUNCH_ERROR', () {
        const exception = AndroidSignerException('LAUNCH_ERROR', 'Launch error');
        expect(exception.userFriendlyMessage, 'Failed to launch signer app.');
      });

      test('returns generic message for unknown error code', () {
        const exception = AndroidSignerException('UNKNOWN_CODE', 'Unknown error');
        expect(
          exception.userFriendlyMessage,
          'An error occurred with the signer. Please try again.',
        );
      });
    });
  });

  group('AndroidSignerResponse', () {
    test('fromMap creates response with all fields', () {
      final response = AndroidSignerResponse.fromMap({
        'result': 'test_result',
        'package': 'com.example.signer',
        'event': '{"id":"abc"}',
        'id': 'request_id',
      });

      expect(response.result, 'test_result');
      expect(response.packageName, 'com.example.signer');
      expect(response.event, '{"id":"abc"}');
      expect(response.id, 'request_id');
    });

    test('fromMap handles null fields', () {
      final response = AndroidSignerResponse.fromMap({});

      expect(response.result, isNull);
      expect(response.packageName, isNull);
      expect(response.event, isNull);
      expect(response.id, isNull);
    });

    test('toString returns formatted string', () {
      const response = AndroidSignerResponse(
        result: 'test_result',
        packageName: 'com.example.signer',
        id: 'req_id',
      );

      expect(
        response.toString(),
        'AndroidSignerResponse(result: test_result, package: com.example.signer, id: req_id)',
      );
    });
  });

  group('SignerPermission', () {
    test('toJson includes type', () {
      const permission = SignerPermission(type: 'sign_event');
      expect(permission.toJson(), {'type': 'sign_event'});
    });

    test('toJson includes kind when provided', () {
      const permission = SignerPermission(type: 'sign_event', kind: 443);
      expect(permission.toJson(), {'type': 'sign_event', 'kind': 443});
    });
  });

  group('AndroidSignerService', () {
    group('isAvailable', () {
      test('returns false on non-Android platform', () async {
        const service = AndroidSignerService(platformIsAndroid: false);
        final result = await service.isAvailable();
        expect(result, isFalse);
      });
    });
  });

  group('AndroidSignerService with mocked channel', () {
    late dynamic mockAndroidSigner;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      mockAndroidSigner = mockAndroidSignerChannel();
    });

    tearDown(() {
      mockAndroidSigner.reset();
    });

    group('isAvailable', () {
      test('returns true when channel returns true', () async {
        mockAndroidSigner.setResult('isExternalSignerInstalled', true);

        const service = AndroidSignerService(platformIsAndroid: true);
        final result = await service.isAvailable();

        expect(result, isTrue);
        expect(mockAndroidSigner.log.single.method, 'isExternalSignerInstalled');
      });

      test('returns false when channel returns null', () async {
        const service = AndroidSignerService(platformIsAndroid: true);
        final result = await service.isAvailable();

        expect(result, isFalse);
      });

      test('returns false on PlatformException', () async {
        mockAndroidSigner.setException(
          'isExternalSignerInstalled',
          PlatformException(code: 'ERROR', message: 'Signer check failed'),
        );

        const service = AndroidSignerService(platformIsAndroid: true);
        final result = await service.isAvailable();

        expect(result, isFalse);
      });
    });

    group('getPublicKey', () {
      test('returns pubkey when signer responds successfully', () async {
        mockAndroidSigner.setResult('getPublicKey', {
          'result': testPubkeyA,
          'package': 'com.amber.signer',
        });

        const service = AndroidSignerService(platformIsAndroid: true);
        final pubkey = await service.getPublicKey();

        expect(pubkey, testPubkeyA);
        expect(mockAndroidSigner.log.length, 2);
        expect(mockAndroidSigner.log[0].method, 'getPublicKey');
        expect(mockAndroidSigner.log[1].method, 'setSignerPackageName');
      });

      test('includes permissions in request when provided', () async {
        mockAndroidSigner.setResult('getPublicKey', {'result': testPubkeyA});

        const service = AndroidSignerService(platformIsAndroid: true);
        await service.getPublicKey(
          permissions: [
            const SignerPermission(type: 'sign_event', kind: 443),
          ],
        );

        expect(mockAndroidSigner.log.first.arguments['permissions'], isNotNull);
        expect(mockAndroidSigner.log.first.arguments['permissions'], contains('sign_event'));
        expect(mockAndroidSigner.log.first.arguments['permissions'], contains('443'));
      });

      test('throws AndroidSignerException when result is null', () async {
        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.getPublicKey(),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESPONSE'),
          ),
        );
      });

      test('throws AndroidSignerException when pubkey is empty', () async {
        mockAndroidSigner.setResult('getPublicKey', {'result': ''});

        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.getPublicKey(),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_PUBKEY'),
          ),
        );
      });

      test('throws AndroidSignerException on PlatformException', () async {
        mockAndroidSigner.setException(
          'getPublicKey',
          PlatformException(code: 'USER_REJECTED', message: 'User rejected'),
        );

        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.getPublicKey(),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'USER_REJECTED'),
          ),
        );
      });
    });

    group('signEvent', () {
      test('returns response when signer responds with event', () async {
        mockAndroidSigner.setResult('signEvent', {'result': 'sig123', 'event': '{"signed":true}'});

        const service = AndroidSignerService(platformIsAndroid: true);
        final response = await service.signEvent(eventJson: '{"test":true}');

        expect(response.result, 'sig123');
        expect(response.event, '{"signed":true}');
        expect(mockAndroidSigner.log.first.method, 'signEvent');
        expect(mockAndroidSigner.log.first.arguments['eventJson'], '{"test":true}');
      });

      test('passes currentUser and id to channel', () async {
        mockAndroidSigner.setResult('signEvent', {'result': 'sig', 'event': '{}'});

        const service = AndroidSignerService(platformIsAndroid: true);
        await service.signEvent(
          eventJson: '{}',
          currentUser: testPubkeyA,
          id: 'req123',
        );

        expect(mockAndroidSigner.log.first.arguments['currentUser'], testPubkeyA);
        expect(mockAndroidSigner.log.first.arguments['id'], 'req123');
      });

      test('throws AndroidSignerException when result is null', () async {
        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.signEvent(eventJson: '{}'),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESPONSE'),
          ),
        );
      });

      test('throws AndroidSignerException when no signature or event', () async {
        mockAndroidSigner.setResult('signEvent', {'result': '', 'event': ''});

        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.signEvent(eventJson: '{}'),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESULT'),
          ),
        );
      });

      test('throws AndroidSignerException on PlatformException', () async {
        mockAndroidSigner.setException(
          'signEvent',
          PlatformException(code: 'USER_REJECTED', message: 'User rejected'),
        );

        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.signEvent(eventJson: '{}'),
          throwsA(isA<AndroidSignerException>()),
        );
      });
    });

    group('nip04Encrypt', () {
      test('returns encrypted text on success', () async {
        mockAndroidSigner.setResult('nip04Encrypt', {'result': 'encrypted_text'});

        const service = AndroidSignerService(platformIsAndroid: true);
        final result = await service.nip04Encrypt(
          plaintext: 'hello',
          pubkey: testPubkeyB,
        );

        expect(result, 'encrypted_text');
        expect(mockAndroidSigner.log.first.method, 'nip04Encrypt');
        expect(mockAndroidSigner.log.first.arguments['plaintext'], 'hello');
        expect(mockAndroidSigner.log.first.arguments['pubkey'], testPubkeyB);
      });

      test('throws AndroidSignerException when result is null', () async {
        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.nip04Encrypt(plaintext: 'hello', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESPONSE'),
          ),
        );
      });

      test('throws AndroidSignerException when result is empty', () async {
        mockAndroidSigner.setResult('nip04Encrypt', {'result': ''});

        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.nip04Encrypt(plaintext: 'hello', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESULT'),
          ),
        );
      });

      test('throws AndroidSignerException on PlatformException', () async {
        mockAndroidSigner.setException(
          'nip04Encrypt',
          PlatformException(code: 'ERROR', message: 'Failed'),
        );

        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.nip04Encrypt(plaintext: 'hello', pubkey: testPubkeyB),
          throwsA(isA<AndroidSignerException>()),
        );
      });
    });

    group('nip04Decrypt', () {
      test('returns decrypted text on success', () async {
        mockAndroidSigner.setResult('nip04Decrypt', {'result': 'decrypted_text'});

        const service = AndroidSignerService(platformIsAndroid: true);
        final result = await service.nip04Decrypt(
          encryptedText: 'encrypted',
          pubkey: testPubkeyB,
        );

        expect(result, 'decrypted_text');
        expect(mockAndroidSigner.log.first.method, 'nip04Decrypt');
      });

      test('throws AndroidSignerException when result is null', () async {
        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.nip04Decrypt(encryptedText: 'enc', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESPONSE'),
          ),
        );
      });

      test('throws AndroidSignerException when result is empty', () async {
        mockAndroidSigner.setResult('nip04Decrypt', {'result': ''});

        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.nip04Decrypt(encryptedText: 'enc', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESULT'),
          ),
        );
      });

      test('throws AndroidSignerException on PlatformException', () async {
        mockAndroidSigner.setException(
          'nip04Decrypt',
          PlatformException(code: 'ERROR', message: 'Failed'),
        );

        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.nip04Decrypt(encryptedText: 'enc', pubkey: testPubkeyB),
          throwsA(isA<AndroidSignerException>()),
        );
      });
    });

    group('nip44Encrypt', () {
      test('returns encrypted text on success', () async {
        mockAndroidSigner.setResult('nip44Encrypt', {'result': 'encrypted_nip44'});

        const service = AndroidSignerService(platformIsAndroid: true);
        final result = await service.nip44Encrypt(
          plaintext: 'hello',
          pubkey: testPubkeyB,
        );

        expect(result, 'encrypted_nip44');
        expect(mockAndroidSigner.log.first.method, 'nip44Encrypt');
      });

      test('throws AndroidSignerException when result is null', () async {
        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.nip44Encrypt(plaintext: 'hello', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESPONSE'),
          ),
        );
      });

      test('throws AndroidSignerException when result is empty', () async {
        mockAndroidSigner.setResult('nip44Encrypt', {'result': ''});

        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.nip44Encrypt(plaintext: 'hello', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESULT'),
          ),
        );
      });

      test('throws AndroidSignerException on PlatformException', () async {
        mockAndroidSigner.setException(
          'nip44Encrypt',
          PlatformException(code: 'ERROR', message: 'Failed'),
        );

        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.nip44Encrypt(plaintext: 'hello', pubkey: testPubkeyB),
          throwsA(isA<AndroidSignerException>()),
        );
      });
    });

    group('nip44Decrypt', () {
      test('returns decrypted text on success', () async {
        mockAndroidSigner.setResult('nip44Decrypt', {'result': 'decrypted_nip44'});

        const service = AndroidSignerService(platformIsAndroid: true);
        final result = await service.nip44Decrypt(
          encryptedText: 'encrypted',
          pubkey: testPubkeyB,
        );

        expect(result, 'decrypted_nip44');
        expect(mockAndroidSigner.log.first.method, 'nip44Decrypt');
      });

      test('throws AndroidSignerException when result is null', () async {
        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.nip44Decrypt(encryptedText: 'enc', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESPONSE'),
          ),
        );
      });

      test('throws AndroidSignerException when result is empty', () async {
        mockAndroidSigner.setResult('nip44Decrypt', {'result': ''});

        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.nip44Decrypt(encryptedText: 'enc', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESULT'),
          ),
        );
      });

      test('throws AndroidSignerException on PlatformException', () async {
        mockAndroidSigner.setException(
          'nip44Decrypt',
          PlatformException(code: 'ERROR', message: 'Failed'),
        );

        const service = AndroidSignerService(platformIsAndroid: true);
        expect(
          () => service.nip44Decrypt(encryptedText: 'enc', pubkey: testPubkeyB),
          throwsA(isA<AndroidSignerException>()),
        );
      });
    });

    group('getSignerPackageName', () {
      test('returns package name on success', () async {
        mockAndroidSigner.setResult('getSignerPackageName', 'com.amber.signer');

        const service = AndroidSignerService(platformIsAndroid: true);
        final result = await service.getSignerPackageName();

        expect(result, 'com.amber.signer');
        expect(mockAndroidSigner.log.first.method, 'getSignerPackageName');
      });

      test('returns null on PlatformException', () async {
        mockAndroidSigner.setException(
          'getSignerPackageName',
          PlatformException(code: 'ERROR', message: 'Failed'),
        );

        const service = AndroidSignerService(platformIsAndroid: true);
        final result = await service.getSignerPackageName();

        expect(result, isNull);
      });
    });

    group('setSignerPackageName', () {
      test('calls channel with package name', () async {
        const service = AndroidSignerService(platformIsAndroid: true);
        await service.setSignerPackageName('com.amber.signer');

        expect(mockAndroidSigner.log.first.method, 'setSignerPackageName');
        expect(mockAndroidSigner.log.first.arguments['packageName'], 'com.amber.signer');
      });

      test('handles PlatformException gracefully', () async {
        mockAndroidSigner.setException(
          'setSignerPackageName',
          PlatformException(code: 'ERROR', message: 'Failed'),
        );

        const service = AndroidSignerService(platformIsAndroid: true);
        await service.setSignerPackageName('com.amber.signer');
      });
    });
  });
}
