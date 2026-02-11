import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/hooks/use_delete_all_data.dart';
import 'package:whitenoise/src/rust/frb_generated.dart';

import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

void main() {
  late MockWnApi mockApi;

  setUpAll(() {
    mockApi = MockWnApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.reset();
  });

  group('DeleteAllDataState', () {
    test('copyWith preserves isDeleting when not provided', () {
      const state = DeleteAllDataState(isDeleting: true);
      final newState = state.copyWith(error: 'test error');
      
      expect(newState.isDeleting, true);
      expect(newState.error, 'test error');
    });

    test('copyWith preserves error when not provided and clearError is false', () {
      const state = DeleteAllDataState(error: 'existing error');
      final newState = state.copyWith(isDeleting: true);
      
      expect(newState.isDeleting, true);
      expect(newState.error, 'existing error');
    });

    test('copyWith clears error when clearError is true', () {
      const state = DeleteAllDataState(error: 'existing error', isDeleting: true);
      final newState = state.copyWith(clearError: true);
      
      expect(newState.isDeleting, true);
      expect(newState.error, null);
    });

    test('copyWith updates isDeleting when provided', () {
      const state = DeleteAllDataState();
      final newState = state.copyWith(isDeleting: true);
      
      expect(newState.isDeleting, true);
    });

    test('copyWith updates error when provided', () {
      const state = DeleteAllDataState();
      final newState = state.copyWith(error: 'new error');
      
      expect(newState.error, 'new error');
    });
  });

  group('useDeleteAllData', () {
    testWidgets('initial state is not deleting', (tester) async {
      late DeleteAllDataState state;

      await mountHook(
        tester,
        () {
          final hook = useDeleteAllData();
          state = hook.state;
          return null;
        },
      );

      expect(state.isDeleting, false);
      expect(state.error, null);
    });

    testWidgets('deleteAllData sets isDeleting to true during operation', (tester) async {
      late DeleteAllDataState initialState;
      late DeleteAllDataState duringState;
      late Future<void> Function() deleteAllData;

      mockApi.deleteAllDataDelay = const Duration(milliseconds: 100);

      await mountHook(
        tester,
        () {
          final hook = useDeleteAllData();
          initialState = hook.state;
          deleteAllData = hook.deleteAllData;
          return null;
        },
      );

      expect(initialState.isDeleting, false);

      deleteAllData();
      await tester.pump();

      await mountHook(
        tester,
        () {
          final hook = useDeleteAllData();
          duringState = hook.state;
          return null;
        },
      );

      expect(duringState.isDeleting, true);

      await tester.pumpAndSettle();
    });

    testWidgets('deleteAllData calls API successfully', (tester) async {
      late Future<void> Function() deleteAllData;

      await mountHook(
        tester,
        () {
          final hook = useDeleteAllData();
          deleteAllData = hook.deleteAllData;
          return null;
        },
      );

      await deleteAllData();
      await tester.pumpAndSettle();

      expect(mockApi.deleteAllDataCalled, true);
    });

    testWidgets('deleteAllData keeps isDeleting true after success', (tester) async {
      late DeleteAllDataState state;
      late Future<void> Function() deleteAllData;

      await mountHook(
        tester,
        () {
          final hook = useDeleteAllData();
          state = hook.state;
          deleteAllData = hook.deleteAllData;
          return null;
        },
      );

      await deleteAllData();
      await tester.pumpAndSettle();

      await mountHook(
        tester,
        () {
          final hook = useDeleteAllData();
          state = hook.state;
          return null;
        },
      );

      expect(state.isDeleting, true);
      expect(state.error, null);
    });

    testWidgets('deleteAllData sets error on failure', (tester) async {
      late DeleteAllDataState state;
      late Future<void> Function() deleteAllData;

      mockApi.deleteAllDataShouldFail = true;

      await mountHook(
        tester,
        () {
          final hook = useDeleteAllData();
          state = hook.state;
          deleteAllData = hook.deleteAllData;
          return null;
        },
      );

      await deleteAllData();
      await tester.pumpAndSettle();

      await mountHook(
        tester,
        () {
          final hook = useDeleteAllData();
          state = hook.state;
          return null;
        },
      );

      expect(state.isDeleting, false);
      expect(state.error, isNotNull);
    });

    testWidgets('deleteAllData clears previous error on new attempt', (tester) async {
      late DeleteAllDataState state;
      late Future<void> Function() deleteAllData;

      mockApi.deleteAllDataShouldFail = true;

      await mountHook(
        tester,
        () {
          final hook = useDeleteAllData();
          state = hook.state;
          deleteAllData = hook.deleteAllData;
          return null;
        },
      );

      await deleteAllData();
      await tester.pumpAndSettle();

      await mountHook(
        tester,
        () {
          final hook = useDeleteAllData();
          state = hook.state;
          return null;
        },
      );

      expect(state.error, isNotNull);

      mockApi.deleteAllDataShouldFail = false;

      await deleteAllData();
      await tester.pumpAndSettle();

      await mountHook(
        tester,
        () {
          final hook = useDeleteAllData();
          state = hook.state;
          return null;
        },
      );

      expect(state.error, null);
    });
  });
}
