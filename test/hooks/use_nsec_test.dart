import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:whitenoise/hooks/use_nsec.dart';
import 'package:whitenoise/providers/account_pubkey_provider.dart';
import 'package:whitenoise/src/rust/frb_generated.dart';

import '../mocks/mock_account_pubkey_notifier.dart';

class _MockApi implements RustLibApi {
  bool shouldThrow = false;

  @override
  Future<String> crateApiAccountsExportAccountNsec({required String pubkey}) async {
    if (shouldThrow) {
      throw Exception('Export error');
    }
    return 'nsec1test${pubkey.substring(0, 10)}';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

late ({
  NsecState state,
  Future<void> Function() loadNsec,
})
result;

Future<void> _pump(WidgetTester tester, List overrides) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...overrides],
      child: MaterialApp(
        home: HookConsumer(
          builder: (context, ref, _) {
            final pubkey = ref.read(accountPubkeyProvider);
            result = useNsec(pubkey);
            return const SizedBox();
          },
        ),
      ),
    ),
  );
}

Future<void> _pumpWithNullablePubkey(WidgetTester tester, String? pubkey) async {
  await tester.pumpWidget(
    MaterialApp(
      home: HookBuilder(
        builder: (context) {
          result = useNsec(pubkey);
          return const SizedBox();
        },
      ),
    ),
  );
}

void main() {
  late _MockApi mockApi;
  late List overrides;

  setUpAll(() {
    mockApi = _MockApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.shouldThrow = false;
    overrides = [
      accountPubkeyProvider.overrideWith(MockAccountPubkeyNotifier.new),
    ];
  });

  group('NsecState', () {
    test('copyWith preserves isLoading when not explicitly set', () {
      const state = NsecState(isLoading: true);
      final copied = state.copyWith(nsec: 'test_nsec');
      expect(copied.isLoading, isTrue);
      expect(copied.nsec, 'test_nsec');
    });

    test('copyWith can override isLoading', () {
      const state = NsecState(isLoading: true);
      final copied = state.copyWith(isLoading: false);
      expect(copied.isLoading, isFalse);
    });
  });

  group('useNsec', () {
    testWidgets('initial state has no nsec', (tester) async {
      await _pump(tester, overrides);
      await tester.pump();

      expect(result.state.nsec, isNull);
      expect(result.state.isLoading, isFalse);
      expect(result.state.error, isNull);
    });

    testWidgets('loadNsec loads nsec successfully', (tester) async {
      await _pump(tester, overrides);
      await tester.pump();

      await result.loadNsec();
      await tester.pumpAndSettle();

      expect(result.state.nsec, startsWith('nsec1'));
      expect(result.state.isLoading, isFalse);
      expect(result.state.error, isNull);
    });

    testWidgets('loadNsec handles errors', (tester) async {
      mockApi.shouldThrow = true;
      await _pump(tester, overrides);
      await tester.pump();

      await result.loadNsec();
      await tester.pumpAndSettle();

      expect(result.state.nsec, isNull);
      expect(result.state.isLoading, isFalse);
      expect(result.state.error, isNotNull);
    });

    testWidgets('state is cleared when pubkey changes', (tester) async {
      final testOverrides = [
        accountPubkeyProvider.overrideWith(MockAccountPubkeyNotifier.new),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [...testOverrides],
          child: MaterialApp(
            home: HookConsumer(
              builder: (context, ref, _) {
                final pubkey = ref.watch(accountPubkeyProvider);
                result = useNsec(pubkey);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      await result.loadNsec();
      await tester.pumpAndSettle();

      expect(result.state.nsec, isNotNull);
      expect(result.state.nsec, startsWith('nsec1'));

      final element = tester.element(find.byType(HookConsumer));
      final container = ProviderScope.containerOf(element);
      final notifier = container.read(accountPubkeyProvider.notifier) as MockAccountPubkeyNotifier;
      notifier.update('new_pubkey');
      await tester.pumpAndSettle();

      expect(result.state.nsec, isNull);
      expect(result.state.isLoading, isFalse);
      expect(result.state.error, isNull);
    });

    testWidgets('handles null pubkey gracefully', (tester) async {
      await _pumpWithNullablePubkey(tester, null);
      await tester.pump();

      expect(result.state.nsec, isNull);
      expect(result.state.isLoading, isFalse);
      expect(result.state.error, isNull);
    });

    testWidgets('loadNsec is no-op when pubkey is null', (tester) async {
      await _pumpWithNullablePubkey(tester, null);
      await tester.pump();

      await result.loadNsec();
      await tester.pumpAndSettle();

      expect(result.state.nsec, isNull);
      expect(result.state.isLoading, isFalse);
      expect(result.state.error, isNull);
    });

    testWidgets('nsec remains null when error occurs on fresh state', (tester) async {
      mockApi.shouldThrow = true;
      await _pump(tester, overrides);
      await tester.pump();

      expect(result.state.nsec, isNull);

      await result.loadNsec();
      await tester.pumpAndSettle();

      expect(result.state.nsec, isNull);
      expect(result.state.error, isNotNull);
    });
  });
}
