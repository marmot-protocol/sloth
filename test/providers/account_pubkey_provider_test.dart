import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/providers/auth_provider.dart';

import '../test_helpers.dart';

class _MockAuthNotifier extends AuthNotifier {
  _MockAuthNotifier(this._state);
  final AsyncValue<String?> _state;

  @override
  Future<String?> build() async {
    state = _state;
    return _state.value;
  }
}

void main() {
  group('accountPubkeyProvider', () {
    group('when not authenticated', () {
      test('throws error', () {
        final container = ProviderContainer(
          overrides: [
            authProvider.overrideWith(() => _MockAuthNotifier(const AsyncData(null))),
          ],
        );
        addTearDown(container.dispose);

        expect(
          () => container.read(accountPubkeyProvider),
          throwsA(anything),
        );
      });
    });

    group('when authenticated', () {
      test('returns pubkey', () {
        final container = ProviderContainer(
          overrides: [
            authProvider.overrideWith(
              () => _MockAuthNotifier(const AsyncData(testPubkeyA)),
            ),
          ],
        );
        addTearDown(container.dispose);

        expect(container.read(accountPubkeyProvider), testPubkeyA);
      });
    });
  });
}
