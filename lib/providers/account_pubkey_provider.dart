import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whitenoise/providers/auth_provider.dart';

class AccountPubkeyNotifier extends Notifier<String> {
  @override
  String build() {
    ref.listen(authProvider, (_, next) {
      final pubkey = next.value;
      if (pubkey != null && pubkey != state) {
        state = pubkey;
      } else if (pubkey == null && next.hasValue) {
        ref.invalidateSelf();
      }
    });

    final pubkey = ref.read(authProvider).value;
    if (pubkey == null) {
      throw StateError('accountPubkeyProvider accessed without authentication');
    }
    return pubkey;
  }
}

final accountPubkeyProvider = NotifierProvider<AccountPubkeyNotifier, String>(
  AccountPubkeyNotifier.new,
);
