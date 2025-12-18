import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_key_packages.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/src/rust/api/accounts.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';

class MockApi implements RustLibApi {
  List<FlutterEvent> keyPackages = [];
  bool shouldThrow = false;
  Completer<void>? publishCompleter;

  @override
  Future<List<FlutterEvent>> crateApiAccountsAccountKeyPackages({
    required String accountPubkey,
  }) async {
    if (shouldThrow) throw Exception('Network error');
    return keyPackages;
  }

  @override
  Future<void> crateApiAccountsPublishAccountKeyPackage({
    required String accountPubkey,
  }) async {
    if (publishCompleter != null) {
      await publishCompleter!.future;
    }
    if (shouldThrow) throw Exception('Network error');
    keyPackages.add(
      FlutterEvent(
        id: 'pkg_${keyPackages.length + 1}',
        pubkey: accountPubkey,
        createdAt: DateTime.now(),
        kind: 443,
        tags: [],
        content: '',
      ),
    );
  }

  @override
  Future<bool> crateApiAccountsDeleteAccountKeyPackage({
    required String accountPubkey,
    required String keyPackageId,
  }) async {
    if (shouldThrow) throw Exception('Network error');
    keyPackages.removeWhere((p) => p.id == keyPackageId);
    return true;
  }

  @override
  Future<BigInt> crateApiAccountsDeleteAccountKeyPackages({
    required String accountPubkey,
  }) async {
    if (shouldThrow) throw Exception('Network error');
    final count = keyPackages.length;
    keyPackages.clear();
    return BigInt.from(count);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async {
    state = const AsyncData('test_pubkey');
    return 'test_pubkey';
  }
}

late ({
  KeyPackagesState state,
  Future<void> Function() fetch,
  Future<void> Function() publish,
  Future<void> Function(String id) delete,
  Future<void> Function() deleteAll,
})
hook;

Future<void> _pump(WidgetTester tester, List overrides) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...overrides],
      child: MaterialApp(
        home: HookConsumer(
          builder: (context, ref, _) {
            hook = useKeyPackages(ref);
            return const SizedBox();
          },
        ),
      ),
    ),
  );
}

late MockApi mockApi;

void main() {
  late List overrides;

  setUpAll(() {
    mockApi = MockApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.keyPackages = [];
    mockApi.shouldThrow = false;
    mockApi.publishCompleter = null;
    overrides = [
      authProvider.overrideWith(() => _MockAuthNotifier()),
      secureStorageProvider.overrideWithValue(MockSecureStorage()),
    ];
  });

  group('fetch', () {
    testWidgets('loads packages from API', (tester) async {
      mockApi.keyPackages = [
        FlutterEvent(
          id: 'pkg1',
          pubkey: 'test',
          createdAt: DateTime.now(),
          kind: 443,
          tags: [],
          content: '',
        ),
      ];

      await _pump(tester, overrides);
      await hook.fetch();
      await tester.pump();

      expect(hook.state.packages.length, 1);
    });

    testWidgets('sets error on failure', (tester) async {
      mockApi.shouldThrow = true;

      await _pump(tester, overrides);
      await hook.fetch();
      await tester.pump();

      expect(hook.state.error, isNotNull);
    });
  });

  group('publish', () {
    testWidgets('refreshes packages after publish', (tester) async {
      await _pump(tester, overrides);
      await hook.publish();
      await tester.pump();
      expect(hook.state.isLoading, isFalse);
      expect(hook.state.packages.length, 1);
    });

    testWidgets('sets error on failure', (tester) async {
      mockApi.shouldThrow = true;

      await _pump(tester, overrides);
      await hook.publish();
      await tester.pump();

      expect(hook.state.error, isNotNull);
    });
  });

  group('delete', () {
    testWidgets('removes package and refreshes list', (tester) async {
      mockApi.keyPackages = [
        FlutterEvent(
          id: 'pkg1',
          pubkey: 'test',
          createdAt: DateTime.now(),
          kind: 443,
          tags: [],
          content: '',
        ),
      ];

      await _pump(tester, overrides);
      await hook.fetch();
      await tester.pump();

      expect(hook.state.packages.length, 1);

      await hook.delete('pkg1');
      await tester.pump();

      expect(hook.state.packages, isEmpty);
    });

    testWidgets('does not execute when isLoading is true', (tester) async {
      mockApi.keyPackages = [
        FlutterEvent(
          id: 'pkg1',
          pubkey: 'test',
          createdAt: DateTime.now(),
          kind: 443,
          tags: [],
          content: '',
        ),
      ];

      await _pump(tester, overrides);
      await hook.fetch();
      await tester.pump();
      expect(hook.state.packages.length, 1);

      final completer = Completer<void>();
      mockApi.publishCompleter = completer;
      unawaited(hook.publish());
      await tester.pump();
      expect(hook.state.isLoading, isTrue);

      await hook.delete('pkg1');
      completer.complete();
      await tester.pump();
      await hook.fetch();
      await tester.pump();

      expect(hook.state.packages.length, 2);
    });

    testWidgets('sets error on failure', (tester) async {
      mockApi.keyPackages = [
        FlutterEvent(
          id: 'pkg1',
          pubkey: 'test',
          createdAt: DateTime.now(),
          kind: 443,
          tags: [],
          content: '',
        ),
      ];

      await _pump(tester, overrides);
      await hook.fetch();
      await tester.pump();

      mockApi.shouldThrow = true;
      await hook.delete('pkg1');
      await tester.pump();

      expect(hook.state.error, isNotNull);
    });
  });

  group('copyWith', () {
    test('preserves isLoading when not provided', () {
      const state = KeyPackagesState(isLoading: true);
      final newState = state.copyWith(packages: []);

      expect(newState.isLoading, isTrue);
    });
  });

  group('deleteAll', () {
    testWidgets('clears all packages', (tester) async {
      mockApi.keyPackages = [
        FlutterEvent(
          id: 'pkg1',
          pubkey: 'test',
          createdAt: DateTime.now(),
          kind: 443,
          tags: [],
          content: '',
        ),
        FlutterEvent(
          id: 'pkg2',
          pubkey: 'test',
          createdAt: DateTime.now(),
          kind: 443,
          tags: [],
          content: '',
        ),
      ];

      await _pump(tester, overrides);
      await hook.fetch();
      await tester.pump();
      expect(hook.state.packages.length, 2);
      await hook.deleteAll();
      await tester.pump();

      expect(hook.state.packages, isEmpty);
    });

    testWidgets('sets error on failure', (tester) async {
      mockApi.shouldThrow = true;

      await _pump(tester, overrides);
      await hook.deleteAll();
      await tester.pump();

      expect(hook.state.error, isNotNull);
    });
  });
}
