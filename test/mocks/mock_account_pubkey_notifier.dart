import 'package:sloth/providers/account_pubkey_provider.dart';

class MockAccountPubkeyNotifier extends AccountPubkeyNotifier {
  MockAccountPubkeyNotifier([this._pubkey = 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4']);
  final String _pubkey;

  @override
  String build() => _pubkey;

  void update(String pubkey) {
    state = pubkey;
  }
}
