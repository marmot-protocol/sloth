import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/services/message_service.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/src/rust/frb_generated.dart';

class _MockTag implements Tag {
  final List<String> vec;
  _MockTag(this.vec);

  @override
  void dispose() {}

  @override
  bool get isDisposed => false;
}

class _MockApi implements RustLibApi {
  final List<({String pubkey, String groupId, String message, int kind, List<Tag>? tags})>
  sentMessages = [];

  @override
  Future<Tag> crateApiUtilsTagFromVec({required List<String> vec}) async {
    return _MockTag(vec);
  }

  @override
  Future<MessageWithTokens> crateApiMessagesSendMessageToGroup({
    required String pubkey,
    required String groupId,
    required String message,
    required int kind,
    List<Tag>? tags,
  }) async {
    sentMessages.add((pubkey: pubkey, groupId: groupId, message: message, kind: kind, tags: tags));
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
    service = const MessageService(pubkey: 'test_pubkey', groupId: 'group1');
  });

  group('sendTextMessage', () {
    test('sends message once', () async {
      await service.sendTextMessage(content: 'Hello');

      expect(mockApi.sentMessages.length, 1);
    });

    test('calls API with pubkey from constructor', () async {
      await service.sendTextMessage(content: 'Hello');

      expect(mockApi.sentMessages.first.pubkey, 'test_pubkey');
    });

    test('calls API with groupId from constructor', () async {
      await service.sendTextMessage(content: 'Hello');

      expect(mockApi.sentMessages.first.groupId, 'group1');
    });

    test('calls API with message content', () async {
      await service.sendTextMessage(content: 'Hello World');

      expect(mockApi.sentMessages.first.message, 'Hello World');
    });

    test('calls API with text message kind (9)', () async {
      await service.sendTextMessage(content: 'Hello');

      expect(mockApi.sentMessages.first.kind, 9);
    });
  });

  group('deleteMessage', () {
    test('sends deletion message once', () async {
      await service.deleteMessage(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
      );

      expect(mockApi.sentMessages.length, 1);
    });

    test('calls API with pubkey from constructor', () async {
      await service.deleteMessage(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
      );

      expect(mockApi.sentMessages.first.pubkey, 'test_pubkey');
    });

    test('calls API with groupId from constructor', () async {
      await service.deleteMessage(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
      );

      expect(mockApi.sentMessages.first.groupId, 'group1');
    });

    test('calls API with empty message', () async {
      await service.deleteMessage(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
      );

      expect(mockApi.sentMessages.first.message, '');
    });

    test('calls API with deletion kind (5)', () async {
      await service.deleteMessage(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
      );

      expect(mockApi.sentMessages.first.kind, 5);
    });

    test('sends e tag with messageId', () async {
      await service.deleteMessage(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[0].vec, ['e', 'msg123']);
    });

    test('sends p tag with messagePubkey', () async {
      await service.deleteMessage(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[1].vec, ['p', 'author_pubkey', '']);
    });

    test('sends k tag with messageKind', () async {
      await service.deleteMessage(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[2].vec, ['k', '9']);
    });
  });

  group('sendReaction', () {
    test('sends reaction message once', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
        emoji: '👍',
      );

      expect(mockApi.sentMessages.length, 1);
    });

    test('calls API with pubkey from constructor', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
        emoji: '👍',
      );

      expect(mockApi.sentMessages.first.pubkey, 'test_pubkey');
    });

    test('calls API with groupId from constructor', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
        emoji: '👍',
      );

      expect(mockApi.sentMessages.first.groupId, 'group1');
    });

    test('calls API with emoji as message', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
        emoji: '🔥',
      );

      expect(mockApi.sentMessages.first.message, '🔥');
    });

    test('calls API with reaction kind (7)', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
        emoji: '👍',
      );

      expect(mockApi.sentMessages.first.kind, 7);
    });

    test('sends e tag with messageId', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
        emoji: '👍',
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[0].vec, ['e', 'msg123']);
    });

    test('sends p tag with messagePubkey', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 9,
        emoji: '👍',
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[1].vec, ['p', 'author_pubkey', '']);
    });

    test('sends k tag with messageKind', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: 'author_pubkey',
        messageKind: 42,
        emoji: '👍',
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[2].vec, ['k', '42']);
    });
  });
}
