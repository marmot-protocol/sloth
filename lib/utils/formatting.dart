export 'package:sloth/utils/encoding.dart' show npubFromHex;

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
  return trimmed[0].toUpperCase();
}
