import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/is_adding_account_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  group('IsAddingAccountNotifier', () {
    test('builds with initial value of false', () {
      expect(container.read(isAddingAccountProvider), false);
    });

    test('set(true) changes state to true', () {
      container.read(isAddingAccountProvider.notifier).set(true);
      expect(container.read(isAddingAccountProvider), true);
    });

    test('set(false) changes state to false', () {
      container.read(isAddingAccountProvider.notifier).set(true);
      expect(container.read(isAddingAccountProvider), true);

      container.read(isAddingAccountProvider.notifier).set(false);
      expect(container.read(isAddingAccountProvider), false);
    });
  });
}
