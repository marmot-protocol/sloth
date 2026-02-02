import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/services/android_signer_service.dart';

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
}
