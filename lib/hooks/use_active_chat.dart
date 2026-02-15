import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void useActiveChat({
  required String groupId,
  required void Function(String) setActiveChat,
  required VoidCallback clearActiveChat,
  required void Function(String) cancelGroupNotifications,
}) {
  useEffect(() {
    setActiveChat(groupId);
    cancelGroupNotifications(groupId);
    return clearActiveChat;
  }, [groupId]);

  useOnAppLifecycleStateChange((previous, current) {
    switch (current) {
      case AppLifecycleState.resumed:
        setActiveChat(groupId);
        cancelGroupNotifications(groupId);
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        clearActiveChat();
    }
  });
}
