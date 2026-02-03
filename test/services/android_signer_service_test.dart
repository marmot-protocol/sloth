import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/services/android_signer_service.dart';

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
        const service = AndroidSignerService();
        final result = await service.isAvailable();
        expect(result, isFalse);
      });
    });
  });

  group('AndroidSignerService with mocked channel', () {
    const channelName = 'com.example.sloth/android_signer';
    late List<MethodCall> log;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      log = [];
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel(channelName),
        null,
      );
    });

    void setMockHandler(Future<Object?>? Function(MethodCall call) handler) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel(channelName),
        (call) {
          log.add(call);
          return handler(call);
        },
      );
    }

    group('getPublicKey', () {
      test('returns pubkey when signer responds successfully', () async {
        setMockHandler((call) async {
          if (call.method == 'getPublicKey') {
            return {'result': testPubkeyA, 'package': 'com.amber.signer'};
          }
          return null;
        });

        final service = const TestableAndroidSignerService();
        final pubkey = await service.getPublicKey();

        expect(pubkey, testPubkeyA);
        expect(log.length, 2);
        expect(log[0].method, 'getPublicKey');
        expect(log[1].method, 'setSignerPackageName');
      });

      test('includes permissions in request when provided', () async {
        setMockHandler((call) async {
          if (call.method == 'getPublicKey') {
            return {'result': testPubkeyA};
          }
          return null;
        });

        final service = const TestableAndroidSignerService();
        await service.getPublicKey(
          permissions: [
            const SignerPermission(type: 'sign_event', kind: 443),
          ],
        );

        expect(log.first.arguments['permissions'], isNotNull);
        expect(log.first.arguments['permissions'], contains('sign_event'));
        expect(log.first.arguments['permissions'], contains('443'));
      });

      test('throws AndroidSignerException when result is null', () async {
        setMockHandler((call) async => null);

        final service = const TestableAndroidSignerService();
        expect(
          () => service.getPublicKey(),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESPONSE'),
          ),
        );
      });

      test('throws AndroidSignerException when pubkey is empty', () async {
        setMockHandler((call) async => {'result': ''});

        final service = const TestableAndroidSignerService();
        expect(
          () => service.getPublicKey(),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_PUBKEY'),
          ),
        );
      });

      test('throws AndroidSignerException on PlatformException', () async {
        setMockHandler((call) async {
          throw PlatformException(code: 'USER_REJECTED', message: 'User rejected');
        });

        final service = const TestableAndroidSignerService();
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
        setMockHandler((call) async {
          if (call.method == 'signEvent') {
            return {'result': 'sig123', 'event': '{"signed":true}'};
          }
          return null;
        });

        final service = const TestableAndroidSignerService();
        final response = await service.signEvent(eventJson: '{"test":true}');

        expect(response.result, 'sig123');
        expect(response.event, '{"signed":true}');
        expect(log.first.method, 'signEvent');
        expect(log.first.arguments['eventJson'], '{"test":true}');
      });

      test('passes currentUser and id to channel', () async {
        setMockHandler((call) async => {'result': 'sig', 'event': '{}'});

        final service = const TestableAndroidSignerService();
        await service.signEvent(
          eventJson: '{}',
          currentUser: testPubkeyA,
          id: 'req123',
        );

        expect(log.first.arguments['currentUser'], testPubkeyA);
        expect(log.first.arguments['id'], 'req123');
      });

      test('throws AndroidSignerException when result is null', () async {
        setMockHandler((call) async => null);

        final service = const TestableAndroidSignerService();
        expect(
          () => service.signEvent(eventJson: '{}'),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESPONSE'),
          ),
        );
      });

      test('throws AndroidSignerException when no signature or event', () async {
        setMockHandler((call) async => {'result': '', 'event': ''});

        final service = const TestableAndroidSignerService();
        expect(
          () => service.signEvent(eventJson: '{}'),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESULT'),
          ),
        );
      });

      test('throws AndroidSignerException on PlatformException', () async {
        setMockHandler((call) async {
          throw PlatformException(code: 'USER_REJECTED', message: 'User rejected');
        });

        final service = const TestableAndroidSignerService();
        expect(
          () => service.signEvent(eventJson: '{}'),
          throwsA(isA<AndroidSignerException>()),
        );
      });
    });

    group('nip04Encrypt', () {
      test('returns encrypted text on success', () async {
        setMockHandler((call) async => {'result': 'encrypted_text'});

        final service = const TestableAndroidSignerService();
        final result = await service.nip04Encrypt(
          plaintext: 'hello',
          pubkey: testPubkeyB,
        );

        expect(result, 'encrypted_text');
        expect(log.first.method, 'nip04Encrypt');
        expect(log.first.arguments['plaintext'], 'hello');
        expect(log.first.arguments['pubkey'], testPubkeyB);
      });

      test('throws AndroidSignerException when result is null', () async {
        setMockHandler((call) async => null);

        final service = const TestableAndroidSignerService();
        expect(
          () => service.nip04Encrypt(plaintext: 'hello', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESPONSE'),
          ),
        );
      });

      test('throws AndroidSignerException when result is empty', () async {
        setMockHandler((call) async => {'result': ''});

        final service = const TestableAndroidSignerService();
        expect(
          () => service.nip04Encrypt(plaintext: 'hello', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESULT'),
          ),
        );
      });

      test('throws AndroidSignerException on PlatformException', () async {
        setMockHandler((call) async {
          throw PlatformException(code: 'ERROR', message: 'Failed');
        });

        final service = const TestableAndroidSignerService();
        expect(
          () => service.nip04Encrypt(plaintext: 'hello', pubkey: testPubkeyB),
          throwsA(isA<AndroidSignerException>()),
        );
      });
    });

    group('nip04Decrypt', () {
      test('returns decrypted text on success', () async {
        setMockHandler((call) async => {'result': 'decrypted_text'});

        final service = const TestableAndroidSignerService();
        final result = await service.nip04Decrypt(
          encryptedText: 'encrypted',
          pubkey: testPubkeyB,
        );

        expect(result, 'decrypted_text');
        expect(log.first.method, 'nip04Decrypt');
      });

      test('throws AndroidSignerException when result is null', () async {
        setMockHandler((call) async => null);

        final service = const TestableAndroidSignerService();
        expect(
          () => service.nip04Decrypt(encryptedText: 'enc', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESPONSE'),
          ),
        );
      });

      test('throws AndroidSignerException when result is empty', () async {
        setMockHandler((call) async => {'result': ''});

        final service = const TestableAndroidSignerService();
        expect(
          () => service.nip04Decrypt(encryptedText: 'enc', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESULT'),
          ),
        );
      });

      test('throws AndroidSignerException on PlatformException', () async {
        setMockHandler((call) async {
          throw PlatformException(code: 'ERROR', message: 'Failed');
        });

        final service = const TestableAndroidSignerService();
        expect(
          () => service.nip04Decrypt(encryptedText: 'enc', pubkey: testPubkeyB),
          throwsA(isA<AndroidSignerException>()),
        );
      });
    });

    group('nip44Encrypt', () {
      test('returns encrypted text on success', () async {
        setMockHandler((call) async => {'result': 'encrypted_nip44'});

        final service = const TestableAndroidSignerService();
        final result = await service.nip44Encrypt(
          plaintext: 'hello',
          pubkey: testPubkeyB,
        );

        expect(result, 'encrypted_nip44');
        expect(log.first.method, 'nip44Encrypt');
      });

      test('throws AndroidSignerException when result is null', () async {
        setMockHandler((call) async => null);

        final service = const TestableAndroidSignerService();
        expect(
          () => service.nip44Encrypt(plaintext: 'hello', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESPONSE'),
          ),
        );
      });

      test('throws AndroidSignerException when result is empty', () async {
        setMockHandler((call) async => {'result': ''});

        final service = const TestableAndroidSignerService();
        expect(
          () => service.nip44Encrypt(plaintext: 'hello', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESULT'),
          ),
        );
      });

      test('throws AndroidSignerException on PlatformException', () async {
        setMockHandler((call) async {
          throw PlatformException(code: 'ERROR', message: 'Failed');
        });

        final service = const TestableAndroidSignerService();
        expect(
          () => service.nip44Encrypt(plaintext: 'hello', pubkey: testPubkeyB),
          throwsA(isA<AndroidSignerException>()),
        );
      });
    });

    group('nip44Decrypt', () {
      test('returns decrypted text on success', () async {
        setMockHandler((call) async => {'result': 'decrypted_nip44'});

        final service = const TestableAndroidSignerService();
        final result = await service.nip44Decrypt(
          encryptedText: 'encrypted',
          pubkey: testPubkeyB,
        );

        expect(result, 'decrypted_nip44');
        expect(log.first.method, 'nip44Decrypt');
      });

      test('throws AndroidSignerException when result is null', () async {
        setMockHandler((call) async => null);

        final service = const TestableAndroidSignerService();
        expect(
          () => service.nip44Decrypt(encryptedText: 'enc', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESPONSE'),
          ),
        );
      });

      test('throws AndroidSignerException when result is empty', () async {
        setMockHandler((call) async => {'result': ''});

        final service = const TestableAndroidSignerService();
        expect(
          () => service.nip44Decrypt(encryptedText: 'enc', pubkey: testPubkeyB),
          throwsA(
            isA<AndroidSignerException>().having((e) => e.code, 'code', 'NO_RESULT'),
          ),
        );
      });

      test('throws AndroidSignerException on PlatformException', () async {
        setMockHandler((call) async {
          throw PlatformException(code: 'ERROR', message: 'Failed');
        });

        final service = const TestableAndroidSignerService();
        expect(
          () => service.nip44Decrypt(encryptedText: 'enc', pubkey: testPubkeyB),
          throwsA(isA<AndroidSignerException>()),
        );
      });
    });

    group('getSignerPackageName', () {
      test('returns package name on success', () async {
        setMockHandler((call) async => 'com.amber.signer');

        final service = const TestableAndroidSignerService();
        final result = await service.getSignerPackageName();

        expect(result, 'com.amber.signer');
        expect(log.first.method, 'getSignerPackageName');
      });

      test('returns null on PlatformException', () async {
        setMockHandler((call) async {
          throw PlatformException(code: 'ERROR', message: 'Failed');
        });

        final service = const TestableAndroidSignerService();
        final result = await service.getSignerPackageName();

        expect(result, isNull);
      });
    });

    group('setSignerPackageName', () {
      test('calls channel with package name', () async {
        setMockHandler((call) async => null);

        final service = const TestableAndroidSignerService();
        await service.setSignerPackageName('com.amber.signer');

        expect(log.first.method, 'setSignerPackageName');
        expect(log.first.arguments['packageName'], 'com.amber.signer');
      });

      test('handles PlatformException gracefully', () async {
        setMockHandler((call) async {
          throw PlatformException(code: 'ERROR', message: 'Failed');
        });

        final service = const TestableAndroidSignerService();
        await service.setSignerPackageName('com.amber.signer');
      });
    });
  });
}

class TestableAndroidSignerService extends AndroidSignerService {
  const TestableAndroidSignerService();

  @override
  Future<bool> isAvailable() async => true;
}
