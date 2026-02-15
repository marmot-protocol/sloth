import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/providers/active_chat_provider.dart';

void main() {
  group('ActiveChatNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(activeChatProvider), isNull);
    });

    test('set updates active chat', () {
      container.read(activeChatProvider.notifier).set('group123');
      expect(container.read(activeChatProvider), 'group123');
    });

    test('clear removes active chat', () {
      container.read(activeChatProvider.notifier).set('group123');
      container.read(activeChatProvider.notifier).clear();
      expect(container.read(activeChatProvider), isNull);
    });

    test('set replaces previous active chat', () {
      container.read(activeChatProvider.notifier).set('group1');
      container.read(activeChatProvider.notifier).set('group2');
      expect(container.read(activeChatProvider), 'group2');
    });
  });
}
