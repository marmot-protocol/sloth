import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/src/rust/api/users.dart' as users_api;

AsyncSnapshot<bool> useUserHasKeyPackage(String pubkey) {
  final future = useMemoized(
    () => users_api.userHasKeyPackage(pubkey: pubkey, blockingDataSync: false),
    [pubkey],
  );
  return useFuture(future);
}
