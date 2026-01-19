import 'dart:async' show Completer;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/hooks/use_route_refresh.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

const _emptyMetadata = FlutterMetadata(custom: {});

const _slothMetadata = FlutterMetadata(
  name: 'Sloth',
  displayName: 'sloth',
  about: 'I live in costa rica',
  picture: 'https://example.com/sloth.jpg',
  banner: 'https://example.com/sloth-banner.jpg',
  website: 'https://sloth.com',
  nip05: 'sloth@example.com',
  custom: {},
);

late AsyncSnapshot<FlutterMetadata> Function() getResult;

Future<void> _mountHookWithNullablePubkey(WidgetTester tester, String? pubkey) async {
  await tester.pumpWidget(
    MaterialApp(
      home: HookBuilder(
        builder: (context) {
          final result = useUserMetadata(context, pubkey);
          getResult = () => result;
          return const SizedBox();
        },
      ),
    ),
  );
}

Future<void> _mountHook(WidgetTester tester, String pubkey) async {
  await tester.pumpWidget(
    MaterialApp(
      home: HookBuilder(
        builder: (context) {
          final result = useUserMetadata(context, pubkey);
          getResult = () => result;
          return const SizedBox();
        },
      ),
    ),
  );
}

Future<void> _mountHookWithNavigation(WidgetTester tester, String pubkey) async {
  await tester.pumpWidget(
    MaterialApp(
      navigatorObservers: [routeObserver],
      home: HookBuilder(
        builder: (context) {
          final result = useUserMetadata(context, pubkey);
          getResult = () => result;
          return ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const _SecondPage()),
            ),
            child: const Text('push'),
          );
        },
      ),
    ),
  );
}

class _SecondPage extends StatelessWidget {
  const _SecondPage();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('pop'),
    );
  }
}

enum _MockMode { loading, success, error, emptyThenSuccess }

class _MockApi implements RustLibApi {
  _MockMode mode = _MockMode.success;
  final calls = <({String pubkey, bool blocking})>[];

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) {
    calls.add((pubkey: pubkey, blocking: blockingDataSync));
    switch (mode) {
      case _MockMode.loading:
        return Completer<FlutterMetadata>().future;
      case _MockMode.success:
        return Future.value(_slothMetadata);
      case _MockMode.error:
        return Future.error(Exception('fail'));
      case _MockMode.emptyThenSuccess:
        return blockingDataSync ? Future.value(_slothMetadata) : Future.value(_emptyMetadata);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final _api = _MockApi();

void main() {
  setUpAll(() => RustLib.initMock(api: _api));

  setUp(() => _api.calls.clear());

  group('useUserMetadata', () {
    group('loading', () {
      setUp(() => _api.mode = _MockMode.loading);

      testWidgets('is loading while waiting', (tester) async {
        await _mountHook(tester, 'pk1');

        expect(getResult().connectionState, equals(ConnectionState.waiting));
      });
    });

    group('success', () {
      group('when db has data', () {
        setUp(() => _api.mode = _MockMode.success);

        testWidgets('returns expected metadata', (tester) async {
          await _mountHook(tester, 'pk1');
          await tester.pump();

          expect(getResult().data, equals(_slothMetadata));
        });

        testWidgets('does not refetch when rebuilt with same pubkey', (tester) async {
          await _mountHook(tester, 'pk1');
          await _mountHook(tester, 'pk1');

          expect(_api.calls.length, 1);
        });

        testWidgets('calls with blockingDataSync false', (tester) async {
          await _mountHook(tester, 'pk1');
          await tester.pump();

          expect(_api.calls.single.blocking, isFalse);
        });

        testWidgets('refetches when pubkey changes', (tester) async {
          await _mountHook(tester, 'pk1');
          await _mountHook(tester, 'pk2');

          expect(_api.calls.length, 2);
        });
      });

      group('when db metadata has no name, displayName, or picture', () {
        setUp(() => _api.mode = _MockMode.emptyThenSuccess);

        testWidgets('calls again with blockingDataSync true', (tester) async {
          await _mountHook(tester, 'pk1');
          await tester.pump();

          expect(_api.calls.last.blocking, isTrue);
        });

        testWidgets('returns blocking result', (tester) async {
          await _mountHook(tester, 'pk1');
          await tester.pump();

          expect(getResult().data, equals(_slothMetadata));
        });
      });
    });

    group('error', () {
      setUp(() => _api.mode = _MockMode.error);

      testWidgets('returns error on failure', (tester) async {
        await _mountHook(tester, 'pk1');
        await tester.pump();

        expect(getResult().hasError, isTrue);
      });
    });

    group('refresh on route change', () {
      setUp(() => _api.mode = _MockMode.success);

      testWidgets('refetches when route changes', (tester) async {
        await _mountHookWithNavigation(tester, 'pk1');
        await tester.pumpAndSettle();
        await tester.tap(find.text('push'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('pop'));
        await tester.pumpAndSettle();

        expect(_api.calls.length, 2);
      });
    });

    group('nullable pubkey', () {
      testWidgets('returns none connection state when pubkey is null', (tester) async {
        await _mountHookWithNullablePubkey(tester, null);
        await tester.pump();

        expect(getResult().connectionState, equals(ConnectionState.none));
        expect(getResult().data, isNull);
      });

      testWidgets('does not make API call when pubkey is null', (tester) async {
        _api.calls.clear();
        await _mountHookWithNullablePubkey(tester, null);
        await tester.pump();

        expect(_api.calls, isEmpty);
      });
    });
  });
}
