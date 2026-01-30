import 'package:logging/logging.dart';
import 'package:sloth/theme/semantic_colors.dart';

final _logger = Logger('AvatarColor');

AccentColor avatarColorFromPubkey(String pubkey) {
  if (pubkey.isEmpty) {
    _logger.severe('avatarColorFromPubkey called with empty string');
    return AccentColor.rose;
  }

  final firstChar = pubkey[0].toLowerCase();
  final hexValue = int.tryParse(firstChar, radix: 16);

  if (hexValue == null) {
    _logger.severe('avatarColorFromPubkey called with invalid hex: $firstChar');
    return AccentColor.rose;
  }

  return AccentColor.values[hexValue % AccentColor.values.length];
}
