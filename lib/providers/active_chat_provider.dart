import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveChatNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String groupId) => state = groupId;

  void clear() => state = null;
}

final activeChatProvider = NotifierProvider<ActiveChatNotifier, String?>(
  ActiveChatNotifier.new,
);
