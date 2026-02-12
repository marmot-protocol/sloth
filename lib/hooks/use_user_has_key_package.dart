import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:whitenoise/src/rust/api/users.dart' as users_api;

AsyncSnapshot<bool> useUserHasKeyPackage(String pubkey) {
  final future = useMemoized(
    () async {
      final hasKeyPackage = await users_api.userHasKeyPackage(
        pubkey: pubkey,
        blockingDataSync: false,
      );
      if (hasKeyPackage) return true;
      return users_api.userHasKeyPackage(pubkey: pubkey, blockingDataSync: true);
    },
    [pubkey],
  );
  return useFuture(future);
}
