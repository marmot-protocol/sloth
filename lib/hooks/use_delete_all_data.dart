import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';
import 'package:whitenoise/src/rust/api.dart' as api;

final _logger = Logger('useDeleteAllData');

class DeleteAllDataState {
  final bool isDeleting;
  final bool hasError;

  const DeleteAllDataState({
    this.isDeleting = false,
    this.hasError = false,
  });

  DeleteAllDataState copyWith({
    bool? isDeleting,
    bool? hasError,
  }) {
    return DeleteAllDataState(
      isDeleting: isDeleting ?? this.isDeleting,
      hasError: hasError ?? this.hasError,
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
    state.value = state.value.copyWith(isDeleting: true, hasError: false);
    try {
      _logger.info('Deleting all application data');
      await api.deleteAllData();
      _logger.info('All data deleted successfully');
      state.value = state.value.copyWith(isDeleting: false);
    } catch (e, stackTrace) {
      _logger.severe('Failed to delete all data', e, stackTrace);
      state.value = state.value.copyWith(
        isDeleting: false,
        hasError: true,
      );
      rethrow;
    }
  }

  return (
    state: state.value,
    deleteAllData: deleteAllData,
  );
}
