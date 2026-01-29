import 'package:sloth/theme/semantic_colors.dart';

AccentColor avatarColorFromPubkey(String pubkey) {
  final firstChar = pubkey[0].toLowerCase();
  final hexValue = int.parse(firstChar, radix: 16);
  return AccentColor.values[hexValue % AccentColor.values.length];
}
