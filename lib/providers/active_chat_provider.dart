import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveChatNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String groupId) => state = groupId;

  void clear() => state = null;

  bool isActive(String groupId) => state == groupId;
}

final activeChatProvider = NotifierProvider<ActiveChatNotifier, String?>(
  ActiveChatNotifier.new,
);

class ActiveChatObserver extends NavigatorObserver {
  final ActiveChatNotifier _notifier;

  ActiveChatObserver(this._notifier);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateFromRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateFromRoute(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _updateFromRoute(newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateFromRoute(previousRoute);
  }

  static final _chatPattern = RegExp(r'^/chats/(.+)$');
  static final _invitePattern = RegExp(r'^/invites/(.+)$');

  void _updateFromRoute(Route<dynamic>? route) {
    final path = route?.settings.name;
    if (path == null) {
      _notifier.clear();
      return;
    }

    final chatMatch = _chatPattern.firstMatch(path);
    if (chatMatch != null) {
      _notifier.set(chatMatch.group(1)!);
      return;
    }

    final inviteMatch = _invitePattern.firstMatch(path);
    if (inviteMatch != null) {
      _notifier.set(inviteMatch.group(1)!);
      return;
    }

    _notifier.clear();
  }
}
