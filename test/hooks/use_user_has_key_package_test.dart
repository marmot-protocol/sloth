import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/hooks/use_user_has_key_package.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import '../mocks/mock_wn_api.dart';

class _MockApi extends MockWnApi {
  Completer<bool>? userHasKeyPackageCompleter;
  final userHasKeyPackageCalls = <({String pubkey, bool blocking})>[];

  @override
  Future<bool> crateApiUsersUserHasKeyPackage({
    required String pubkey,
    required bool blockingDataSync,
  }) {
    userHasKeyPackageCalls.add((pubkey: pubkey, blocking: blockingDataSync));
    if (userHasKeyPackageCompleter != null) {
      return userHasKeyPackageCompleter!.future;
    }
    return Future.value(userHasKeyPackage);
  }

  @override
  void reset() {
    super.reset();
    userHasKeyPackageCompleter = null;
    userHasKeyPackageCalls.clear();
  }
}

late AsyncSnapshot<bool> Function() getSnapshot;

Future<void> _mountHook(WidgetTester tester, String pubkey) async {
  await tester.pumpWidget(
    MaterialApp(
      home: HookBuilder(
        builder: (context) {
          final snapshot = useUserHasKeyPackage(pubkey);
          getSnapshot = () => snapshot;
          return const SizedBox();
        },
      ),
    ),
  );
}

final _api = _MockApi();

void main() {
  setUpAll(() => RustLib.initMock(api: _api));
  setUp(() => _api.reset());

  group('useUserHasKeyPackage', () {
    testWidgets('is loading while waiting', (tester) async {
      _api.userHasKeyPackageCompleter = Completer();
      await _mountHook(tester, 'pk1');

      expect(getSnapshot().connectionState, equals(ConnectionState.waiting));
    });

    testWidgets('returns true when user has key package', (tester) async {
      _api.userHasKeyPackage = true;
      await _mountHook(tester, 'pk1');
      await tester.pump();

      expect(getSnapshot().data, isTrue);
    });

    testWidgets('returns false when user has no key package', (tester) async {
      _api.userHasKeyPackage = false;
      await _mountHook(tester, 'pk1');
      await tester.pump();

      expect(getSnapshot().data, isFalse);
    });

    testWidgets('calls with blockingDataSync false', (tester) async {
      await _mountHook(tester, 'pk1');
      await tester.pump();

      expect(_api.userHasKeyPackageCalls.single.blocking, isFalse);
    });

    testWidgets('does not refetch when rebuilt with same pubkey', (tester) async {
      await _mountHook(tester, 'pk1');
      await _mountHook(tester, 'pk1');

      expect(_api.userHasKeyPackageCalls.length, 1);
    });

    testWidgets('refetches when pubkey changes', (tester) async {
      await _mountHook(tester, 'pk1');
      await _mountHook(tester, 'pk2');

      expect(_api.userHasKeyPackageCalls.length, 2);
    });
  });
}
