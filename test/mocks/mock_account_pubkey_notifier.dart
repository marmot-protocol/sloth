import 'package:sloth/providers/account_pubkey_provider.dart';

import '../test_helpers.dart';

class MockAccountPubkeyNotifier extends AccountPubkeyNotifier {
  MockAccountPubkeyNotifier([this._pubkey = testPubkeyA]);
  final String _pubkey;

  @override
  String build() => _pubkey;

  void update(String pubkey) {
    state = pubkey;
  }
}
