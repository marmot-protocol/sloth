import 'package:logging/logging.dart';
import 'package:whitenoise/src/rust/api/metadata.dart';
import 'package:whitenoise/src/rust/api/users.dart' as users_api;
import 'package:whitenoise/src/rust/api/users.dart' show User;

final _logger = Logger('UserService');

class UserService {
  final String pubkey;

  const UserService(this.pubkey);

  Future<FlutterMetadata> fetchMetadata() async {
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

  Future<User?> fetchUser() async {
    try {
      final user = await users_api.getUser(pubkey: pubkey, blockingDataSync: false);
      if (!_isMetadataEmpty(user.metadata)) return user;
      return await users_api.getUser(pubkey: pubkey, blockingDataSync: true);
    } catch (e) {
      _logger.warning('Failed to fetch user', e);
      return null;
    }
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
