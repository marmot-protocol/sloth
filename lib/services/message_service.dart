import 'package:logging/logging.dart';
import 'package:whitenoise/src/rust/api/messages.dart' as messages_api;
import 'package:whitenoise/src/rust/api/utils.dart' as utils_api;

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
      eventId: messageId,
      eventPubkey: messagePubkey,
      eventKind: messageKind,
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

  Future<void> toggleReaction({
    required messages_api.ChatMessage message,
    required String emoji,
  }) async {
    final existingReaction = message.reactions.userReactions
        .where((r) => r.user == pubkey && r.emoji == emoji)
        .firstOrNull;

    if (existingReaction != null) {
      await deleteReaction(
        reactionId: existingReaction.reactionId,
        reactionPubkey: pubkey,
      );
    } else {
      await sendReaction(
        messageId: message.id,
        messagePubkey: message.pubkey,
        messageKind: message.kind,
        emoji: emoji,
      );
    }
  }

  Future<void> deleteTextMessage({
    required String messageId,
    required String messagePubkey,
  }) async {
    await _deleteEvent(
      eventId: messageId,
      eventPubkey: messagePubkey,
      eventKind: _textMessageKind,
    );
  }

  Future<void> deleteReaction({
    required String reactionId,
    required String reactionPubkey,
  }) async {
    await _deleteEvent(
      eventId: reactionId,
      eventPubkey: reactionPubkey,
      eventKind: _reactionKind,
    );
  }

  Future<void> _deleteEvent({
    required String eventId,
    required String eventPubkey,
    required int eventKind,
  }) async {
    _logger.info('Building deletion tags for event $eventId');
    final tags = await _eventReferenceTags(
      eventId: eventId,
      eventPubkey: eventPubkey,
      eventKind: eventKind,
    );

    _logger.info('Deleting event $eventId');
    await messages_api.sendMessageToGroup(
      pubkey: pubkey,
      groupId: groupId,
      message: '',
      tags: tags,
      kind: _deletionKind,
    );
    _logger.info('Event $eventId deleted successfully');
  }

  Future<List<messages_api.Tag>> _eventReferenceTags({
    required String eventId,
    required String eventPubkey,
    required int eventKind,
  }) {
    return Future.wait([
      utils_api.tagFromVec(vec: ['e', eventId]),
      utils_api.tagFromVec(vec: ['p', eventPubkey, '']),
      utils_api.tagFromVec(vec: ['k', eventKind.toString()]),
    ]);
  }
}
