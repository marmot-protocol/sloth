import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/hooks/use_route_refresh.dart';
import 'package:sloth/services/user_service.dart';
import 'package:sloth/src/rust/api/metadata.dart';

AsyncSnapshot<FlutterMetadata> useUserMetadata(
  BuildContext context,
  String? pubkey,
) {
  final refreshKey = useState(0);

  useRouteRefresh(context, () => refreshKey.value++);

  final future = useMemoized(
    () => pubkey != null ? UserService(pubkey).fetchMetadata() : null,
    [pubkey, refreshKey.value],
  );
  return useFuture(future);
}
