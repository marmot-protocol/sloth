import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/services/message_service.dart';
import 'package:whitenoise/src/rust/api/messages.dart';
import 'package:whitenoise/src/rust/frb_generated.dart';

import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

const _testPubkey = testPubkeyA;

class _MockTag implements Tag {
  final List<String> vec;
  _MockTag(this.vec);

  @override
  void dispose() {}

  @override
  bool get isDisposed => false;
}

class _MockApi extends MockWnApi {
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
    service = const MessageService(pubkey: _testPubkey, groupId: 'group1');
  });

  group('sendTextMessage', () {
    test('sends message once', () async {
      await service.sendTextMessage(content: 'Hello');

      expect(mockApi.sentMessages.length, 1);
    });

    test('calls API with pubkey from constructor', () async {
      await service.sendTextMessage(content: 'Hello');

      expect(mockApi.sentMessages.first.pubkey, _testPubkey);
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

    test('sends message without tags when no reply params', () async {
      await service.sendTextMessage(content: 'Hello');

      expect(mockApi.sentMessages.first.tags, isNull);
    });
  });

  group('sendTextMessage (reply)', () {
    const testReplyId = 'reply_msg_id';
    const testReplyPubkey = testPubkeyB;
    const testReplyKind = 9;

    test('sends message once when reply params provided', () async {
      await service.sendTextMessage(
        content: 'Reply content',
        replyToMessageId: testReplyId,
        replyToMessagePubkey: testReplyPubkey,
        replyToMessageKind: testReplyKind,
      );

      expect(mockApi.sentMessages.length, 1);
    });

    test('calls API with content when replying', () async {
      await service.sendTextMessage(
        content: 'Reply content',
        replyToMessageId: testReplyId,
        replyToMessagePubkey: testReplyPubkey,
        replyToMessageKind: testReplyKind,
      );

      expect(mockApi.sentMessages.first.message, 'Reply content');
    });

    test('calls API with text message kind (9) when replying', () async {
      await service.sendTextMessage(
        content: 'Reply content',
        replyToMessageId: testReplyId,
        replyToMessagePubkey: testReplyPubkey,
        replyToMessageKind: testReplyKind,
      );

      expect(mockApi.sentMessages.first.kind, 9);
    });

    test('sends e tag with reply message id', () async {
      await service.sendTextMessage(
        content: 'Reply content',
        replyToMessageId: testReplyId,
        replyToMessagePubkey: testReplyPubkey,
        replyToMessageKind: testReplyKind,
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[0].vec, ['e', testReplyId]);
    });

    test('sends p tag with reply message pubkey', () async {
      await service.sendTextMessage(
        content: 'Reply content',
        replyToMessageId: testReplyId,
        replyToMessagePubkey: testReplyPubkey,
        replyToMessageKind: testReplyKind,
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[1].vec, ['p', testReplyPubkey, '']);
    });

    test('sends k tag with reply message kind', () async {
      await service.sendTextMessage(
        content: 'Reply content',
        replyToMessageId: testReplyId,
        replyToMessagePubkey: testReplyPubkey,
        replyToMessageKind: testReplyKind,
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[2].vec, ['k', testReplyKind.toString()]);
    });

    test('sends no tags when only replyToMessageId provided', () async {
      await service.sendTextMessage(
        content: 'Reply content',
        replyToMessageId: testReplyId,
      );

      expect(mockApi.sentMessages.first.tags, isNull);
    });

    test('sends no tags when only replyToMessagePubkey provided', () async {
      await service.sendTextMessage(
        content: 'Reply content',
        replyToMessagePubkey: testReplyPubkey,
      );

      expect(mockApi.sentMessages.first.tags, isNull);
    });

    test('sends no tags when only replyToMessageKind provided', () async {
      await service.sendTextMessage(
        content: 'Reply content',
        replyToMessageKind: testReplyKind,
      );

      expect(mockApi.sentMessages.first.tags, isNull);
    });
  });

  group('deleteTextMessage', () {
    test('sends deletion message once', () async {
      await service.deleteTextMessage(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
      );

      expect(mockApi.sentMessages.length, 1);
    });

    test('calls API with pubkey from constructor', () async {
      await service.deleteTextMessage(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
      );

      expect(mockApi.sentMessages.first.pubkey, _testPubkey);
    });

    test('calls API with groupId from constructor', () async {
      await service.deleteTextMessage(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
      );

      expect(mockApi.sentMessages.first.groupId, 'group1');
    });

    test('calls API with empty message', () async {
      await service.deleteTextMessage(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
      );

      expect(mockApi.sentMessages.first.message, '');
    });

    test('calls API with deletion kind (5)', () async {
      await service.deleteTextMessage(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
      );

      expect(mockApi.sentMessages.first.kind, 5);
    });

    test('sends e tag with messageId', () async {
      await service.deleteTextMessage(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[0].vec, ['e', 'msg123']);
    });

    test('sends p tag with messagePubkey', () async {
      await service.deleteTextMessage(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[1].vec, ['p', testPubkeyB, '']);
    });

    test('sends k tag with text message kind (9)', () async {
      await service.deleteTextMessage(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[2].vec, ['k', '9']);
    });
  });

  group('deleteReaction', () {
    test('sends deletion message once', () async {
      await service.deleteReaction(
        reactionId: 'reaction123',
        reactionPubkey: testPubkeyB,
      );

      expect(mockApi.sentMessages.length, 1);
    });

    test('calls API with pubkey from constructor', () async {
      await service.deleteReaction(
        reactionId: 'reaction123',
        reactionPubkey: testPubkeyB,
      );

      expect(mockApi.sentMessages.first.pubkey, _testPubkey);
    });

    test('calls API with groupId from constructor', () async {
      await service.deleteReaction(
        reactionId: 'reaction123',
        reactionPubkey: testPubkeyB,
      );

      expect(mockApi.sentMessages.first.groupId, 'group1');
    });

    test('calls API with empty message', () async {
      await service.deleteReaction(
        reactionId: 'reaction123',
        reactionPubkey: testPubkeyB,
      );

      expect(mockApi.sentMessages.first.message, '');
    });

    test('calls API with deletion kind (5)', () async {
      await service.deleteReaction(
        reactionId: 'reaction123',
        reactionPubkey: testPubkeyB,
      );

      expect(mockApi.sentMessages.first.kind, 5);
    });

    test('sends e tag with reactionId', () async {
      await service.deleteReaction(
        reactionId: 'reaction123',
        reactionPubkey: testPubkeyB,
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[0].vec, ['e', 'reaction123']);
    });

    test('sends p tag with reactionPubkey', () async {
      await service.deleteReaction(
        reactionId: 'reaction123',
        reactionPubkey: testPubkeyB,
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[1].vec, ['p', testPubkeyB, '']);
    });

    test('sends k tag with reaction kind (7)', () async {
      await service.deleteReaction(
        reactionId: 'reaction123',
        reactionPubkey: testPubkeyB,
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[2].vec, ['k', '7']);
    });
  });

  group('toggleReaction', () {
    ChatMessage createMessage({
      String id = 'msg123',
      String pubkey = testPubkeyB,
      ReactionSummary? reactions,
    }) => ChatMessage(
      id: id,
      pubkey: pubkey,
      content: 'Test message',
      createdAt: DateTime.now(),
      tags: const [],
      isReply: false,
      isDeleted: false,
      contentTokens: const [],
      reactions: reactions ?? const ReactionSummary(byEmoji: [], userReactions: []),
      mediaAttachments: const [],
      kind: 9,
    );

    test('sends reaction when user has not reacted', () async {
      final message = createMessage();

      await service.toggleReaction(message: message, emoji: '👍');

      expect(mockApi.sentMessages.length, 1);
      expect(mockApi.sentMessages.first.kind, 7);
      expect(mockApi.sentMessages.first.message, '👍');
    });

    test('deletes reaction when user has already reacted with same emoji', () async {
      final message = createMessage(
        reactions: ReactionSummary(
          byEmoji: [
            EmojiReaction(
              emoji: '👍',
              count: BigInt.one,
              users: const [_testPubkey],
            ),
          ],
          userReactions: [
            UserReaction(
              reactionId: 'reaction_to_delete',
              user: _testPubkey,
              emoji: '👍',
              createdAt: DateTime.now(),
            ),
          ],
        ),
      );

      await service.toggleReaction(message: message, emoji: '👍');

      expect(mockApi.sentMessages.length, 1);
      expect(mockApi.sentMessages.first.kind, 5);
      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[0].vec, ['e', 'reaction_to_delete']);
    });

    test('sends new reaction when user has reacted with different emoji', () async {
      final message = createMessage(
        reactions: ReactionSummary(
          byEmoji: [
            EmojiReaction(
              emoji: '👍',
              count: BigInt.one,
              users: const [_testPubkey],
            ),
          ],
          userReactions: [
            UserReaction(
              reactionId: 'existing_reaction',
              user: _testPubkey,
              emoji: '👍',
              createdAt: DateTime.now(),
            ),
          ],
        ),
      );

      await service.toggleReaction(message: message, emoji: '❤');

      expect(mockApi.sentMessages.length, 1);
      expect(mockApi.sentMessages.first.kind, 7);
      expect(mockApi.sentMessages.first.message, '❤');
    });

    test('sends reaction when other users have reacted but not current user', () async {
      final message = createMessage(
        reactions: ReactionSummary(
          byEmoji: [
            EmojiReaction(emoji: '👍', count: BigInt.one, users: const [testPubkeyC]),
          ],
          userReactions: [
            UserReaction(
              reactionId: 'other_reaction',
              user: testPubkeyC,
              emoji: '👍',
              createdAt: DateTime.now(),
            ),
          ],
        ),
      );

      await service.toggleReaction(message: message, emoji: '👍');

      expect(mockApi.sentMessages.length, 1);
      expect(mockApi.sentMessages.first.kind, 7);
      expect(mockApi.sentMessages.first.message, '👍');
    });
  });

  group('sendReaction', () {
    test('sends reaction message once', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
        messageKind: 9,
        emoji: '👍',
      );

      expect(mockApi.sentMessages.length, 1);
    });

    test('calls API with pubkey from constructor', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
        messageKind: 9,
        emoji: '👍',
      );

      expect(mockApi.sentMessages.first.pubkey, _testPubkey);
    });

    test('calls API with groupId from constructor', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
        messageKind: 9,
        emoji: '👍',
      );

      expect(mockApi.sentMessages.first.groupId, 'group1');
    });

    test('calls API with emoji as message', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
        messageKind: 9,
        emoji: '🔥',
      );

      expect(mockApi.sentMessages.first.message, '🔥');
    });

    test('calls API with reaction kind (7)', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
        messageKind: 9,
        emoji: '👍',
      );

      expect(mockApi.sentMessages.first.kind, 7);
    });

    test('sends e tag with messageId', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
        messageKind: 9,
        emoji: '👍',
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[0].vec, ['e', 'msg123']);
    });

    test('sends p tag with messagePubkey', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
        messageKind: 9,
        emoji: '👍',
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[1].vec, ['p', testPubkeyB, '']);
    });

    test('sends k tag with messageKind', () async {
      await service.sendReaction(
        messageId: 'msg123',
        messagePubkey: testPubkeyB,
        messageKind: 42,
        emoji: '👍',
      );

      final tags = mockApi.sentMessages.first.tags!.cast<_MockTag>();
      expect(tags[2].vec, ['k', '42']);
    });
  });
}
