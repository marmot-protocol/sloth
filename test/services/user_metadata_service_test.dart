import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/services/user_metadata_service.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_wn_api.dart';

class _MockApi extends MockWnApi {
  FlutterMetadata nonBlockingResult = const FlutterMetadata(custom: {});
  FlutterMetadata blockingResult = const FlutterMetadata(
    name: 'blocking_sync_result',
    custom: {},
  );

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required String pubkey,
    required bool blockingDataSync,
  }) async {
    return blockingDataSync ? blockingResult : nonBlockingResult;
  }
}

void main() {
  late _MockApi mockApi;
  late UserMetadataService service;

  setUpAll(() {
    mockApi = _MockApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.nonBlockingResult = const FlutterMetadata(custom: {});
    mockApi.blockingResult = const FlutterMetadata(
      name: 'blocking_sync_result',
      custom: {},
    );
    service = const UserMetadataService('test_pubkey');
  });

  group('fetch', () {
    group('when metadata has name', () {
      setUp(() {
        mockApi.nonBlockingResult = const FlutterMetadata(
          name: 'Test',
          custom: {},
        );
      });

      test('returns non-blocking result', () async {
        final result = await service.fetch();

        expect(result.name, 'Test');
      });
    });

    group('when metadata has displayName', () {
      setUp(() {
        mockApi.nonBlockingResult = const FlutterMetadata(
          displayName: 'Display',
          custom: {},
        );
      });

      test('returns non-blocking result', () async {
        final result = await service.fetch();

        expect(result.displayName, 'Display');
      });
    });

    group('when metadata has picture', () {
      setUp(() {
        mockApi.nonBlockingResult = const FlutterMetadata(
          picture: 'https://example.com/pic.jpg',
          custom: {},
        );
      });

      test('returns non-blocking result', () async {
        final result = await service.fetch();

        expect(result.picture, 'https://example.com/pic.jpg');
      });
    });

    group('when metadata is empty', () {
      test('returns blocking sync result', () async {
        final result = await service.fetch();

        expect(result.name, 'blocking_sync_result');
      });
    });

    group('when metadata has empty strings for name, displayName and picture', () {
      setUp(() {
        mockApi.nonBlockingResult = const FlutterMetadata(
          name: '',
          displayName: '',
          picture: '',
          custom: {},
        );
      });

      test('returns blocking sync result', () async {
        final result = await service.fetch();

        expect(result.name, 'blocking_sync_result');
      });
    });
  });
}
