import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/services/message_service.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/src/rust/frb_generated.dart';

class _MockApi implements RustLibApi {
  final List<({String pubkey, String groupId, String message, int kind})> sentMessages = [];

  @override
  Future<MessageWithTokens> crateApiMessagesSendMessageToGroup({
    required String pubkey,
    required String groupId,
    required String message,
    required int kind,
    List<Tag>? tags,
  }) async {
    sentMessages.add((pubkey: pubkey, groupId: groupId, message: message, kind: kind));
    return MessageWithTokens(
      id: 'sent_${sentMessages.length}',
      pubkey: pubkey,
      kind: kind,
      createdAt: DateTime.now(),
      content: message,
      tokens: const [],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _MockApi mockApi;
  late MessageService service;

  setUpAll(() {
    mockApi = _MockApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.sentMessages.clear();
    service = const MessageService('test_pubkey');
  });

  group('sendTextMessage', () {
    test('sends message once', () async {
      await service.sendTextMessage(groupId: 'group1', content: 'Hello');

      expect(mockApi.sentMessages.length, 1);
    });

    test('calls API with pubkey', () async {
      await service.sendTextMessage(groupId: 'group1', content: 'Hello');

      expect(mockApi.sentMessages.first.pubkey, 'test_pubkey');
    });

    test('calls API with groupId', () async {
      await service.sendTextMessage(groupId: 'group1', content: 'Hello');

      expect(mockApi.sentMessages.first.groupId, 'group1');
    });

    test('calls API with message content', () async {
      await service.sendTextMessage(groupId: 'group1', content: 'Hello World');

      expect(mockApi.sentMessages.first.message, 'Hello World');
    });

    test('calls API with text message kind (9)', () async {
      await service.sendTextMessage(groupId: 'group1', content: 'Hello');

      expect(mockApi.sentMessages.first.kind, 9);
    });
  });
}
