import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';
import 'package:whitenoise/src/rust/api.dart' as api;

final _logger = Logger('useDeleteAllData');

class DeleteAllDataState {
  final bool isDeleting;
  final String? error;

  const DeleteAllDataState({
    this.isDeleting = false,
    this.error,
  });

  DeleteAllDataState copyWith({
    bool? isDeleting,
    String? error,
    bool clearError = false,
  }) {
    return DeleteAllDataState(
      isDeleting: isDeleting ?? this.isDeleting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

({
  DeleteAllDataState state,
  Future<void> Function() deleteAllData,
})
useDeleteAllData() {
  final state = useState(const DeleteAllDataState());

  Future<void> deleteAllData() async {
    state.value = state.value.copyWith(isDeleting: true, clearError: true);
    try {
      _logger.info('Deleting all application data');
      await api.deleteAllData();
      _logger.info('All data deleted successfully');
      state.value = state.value.copyWith(isDeleting: false);
    } catch (e, stackTrace) {
      _logger.severe('Failed to delete all data', e, stackTrace);
      state.value = state.value.copyWith(
        isDeleting: false,
        error: 'Failed to delete all data. Please try again.',
      );
      rethrow;
    }
  }

  return (
    state: state.value,
    deleteAllData: deleteAllData,
  );
}
