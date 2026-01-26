import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsAddingAccountNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final isAddingAccountProvider = NotifierProvider<IsAddingAccountNotifier, bool>(
  IsAddingAccountNotifier.new,
);
