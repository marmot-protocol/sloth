import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/widgets/wn_list_item.dart';

WnListItemController useListItemController() {
  final controller = useMemoized(() => WnListItemController(), const []);

  useEffect(() {
    return controller.dispose;
  }, [controller]);

  return controller;
}
