import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_nsec.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/src/rust/frb_generated.dart';

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

class _PubkeyNotifier extends Notifier<String> {
  @override
  String build() => 'test_pubkey';

  void update(String pubkey) {
    state = pubkey;
  }
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
      accountPubkeyProvider.overrideWith((ref) => 'test_pubkey'),
    ];
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
      final pubkeyNotifierProvider = NotifierProvider<_PubkeyNotifier, String>(_PubkeyNotifier.new);
      final testOverrides = [
        accountPubkeyProvider.overrideWith((ref) => ref.watch(pubkeyNotifierProvider)),
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
      container.read(pubkeyNotifierProvider.notifier).update('new_pubkey');
      await tester.pumpAndSettle();

      expect(result.state.nsec, isNull);
      expect(result.state.isLoading, isFalse);
      expect(result.state.error, isNull);
    });
  });
}
