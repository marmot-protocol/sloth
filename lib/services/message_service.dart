import 'package:logging/logging.dart';
import 'package:sloth/src/rust/api/messages.dart' as messages_api;
import 'package:sloth/src/rust/api/utils.dart' as utils_api;

final _logger = Logger('MessageService');

// NIP-C7: https://github.com/nostr-protocol/nips/blob/master/C7.md
const int _textMessageKind = 9;
// NIP-09: https://github.com/nostr-protocol/nips/blob/master/09.md
const int _deletionKind = 5;
// NIP-25: https://github.com/nostr-protocol/nips/blob/master/25.md
const int _reactionKind = 7;

class MessageService {
  final String pubkey;
  final String groupId;

  const MessageService({required this.pubkey, required this.groupId});

  Future<void> sendTextMessage({
    required String groupId,
    required String content,
  }) async {
    _logger.info('Sending text message to group $groupId');
    await messages_api.sendMessageToGroup(
      pubkey: pubkey,
      groupId: groupId,
      message: content,
      kind: _textMessageKind,
    );
    _logger.info('Message sent successfully');
  }

  Future<void> sendReaction({
    required String messageId,
    required String messagePubkey,
    required int messageKind,
    required String emoji,
  }) async {
    final tags = await _eventReferenceTags(
      messageId: messageId,
      messagePubkey: messagePubkey,
      messageKind: messageKind,
    );

    _logger.info('Sending reaction to message $messageId');
    await messages_api.sendMessageToGroup(
      pubkey: pubkey,
      groupId: groupId,
      message: emoji,
      kind: _reactionKind,
      tags: tags,
    );
    _logger.info('Reaction sent successfully');
  }

  Future<void> deleteMessage({
    required String groupId,
    required String messageId,
    required String messagePubkey,
    required int messageKind,
  }) async {
    _logger.info('Building deletion tags for message $messageId');
    final tags = await _eventReferenceTags(
      messageId: messageId,
      messagePubkey: messagePubkey,
      messageKind: messageKind,
    );

    _logger.info('Deleting message $messageId');
    await messages_api.sendMessageToGroup(
      pubkey: pubkey,
      groupId: groupId,
      message: '',
      tags: tags,
      kind: _deletionKind,
    );
    _logger.info('Message $messageId deleted successfully');
  }

  Future<List<messages_api.Tag>> _eventReferenceTags({
    required String messageId,
    required String messagePubkey,
    required int messageKind,
  }) {
    return Future.wait([
      utils_api.tagFromVec(vec: ['e', messageId]),
      utils_api.tagFromVec(vec: ['p', messagePubkey, '']),
      utils_api.tagFromVec(vec: ['k', messageKind.toString()]),
    ]);
  }
}
