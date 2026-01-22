import 'package:sloth/providers/account_pubkey_provider.dart';

class MockAccountPubkeyNotifier extends AccountPubkeyNotifier {
  MockAccountPubkeyNotifier([this._pubkey = 'test_pubkey']);
  final String _pubkey;

  @override
  String build() => _pubkey;

  void update(String pubkey) {
    state = pubkey;
  }
}
