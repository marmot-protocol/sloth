import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/api/users.dart' as users_api;

class UserMetadataService {
  final String pubkey;

  const UserMetadataService(this.pubkey);

  Future<FlutterMetadata> fetch() async {
    final userMetadata = await users_api.userMetadata(
      pubkey: pubkey,
      blockingDataSync: false,
    );
    if (_isMetadataEmpty(userMetadata)) {
      return users_api.userMetadata(
        pubkey: pubkey,
        blockingDataSync: true,
      );
    }

    return userMetadata;
  }

  bool _isMetadataEmpty(FlutterMetadata userMetadata) {
    return _isFieldEmpty(userMetadata.name) &&
        _isFieldEmpty(userMetadata.displayName) &&
        _isFieldEmpty(userMetadata.picture);
  }

  bool _isFieldEmpty(String? value) {
    return value == null || value.isEmpty;
  }
}
