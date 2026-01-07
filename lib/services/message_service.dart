import 'package:logging/logging.dart';
import 'package:sloth/src/rust/api/messages.dart' as messages_api;

final _logger = Logger('MessageService');

// NIP-C7: https://github.com/nostr-protocol/nips/blob/master/C7.md
const int _textMessageKind = 9;

class MessageService {
  final String pubkey;

  const MessageService(this.pubkey);

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
}
