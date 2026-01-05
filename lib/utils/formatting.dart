import 'package:logging/logging.dart';
import 'package:sloth/src/rust/api/utils.dart' as utils_api;

final _logger = Logger('formatting');

String? npubFromPubkey(String pubkey) {
  try {
    return utils_api.npubFromHexPubkey(hexPubkey: pubkey);
  } catch (e) {
    _logger.severe('Failed to convert pubkey to npub', e);
    return null;
  }
}

String formatPublicKey(String publicKey) {
  return publicKey.replaceAllMapped(
    RegExp(r'.{5}'),
    (match) => '${match.group(0)} ',
  );
}

String? formatInitials(String? displayName) {
  if (displayName == null || displayName.isEmpty) return null;
  final trimmed = displayName.trim();
  if (trimmed.isEmpty) return null;
  final words = trimmed.split(RegExp(r'\s+'));
  if (words.length >= 2) {
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
  return words[0][0].toUpperCase();
}
