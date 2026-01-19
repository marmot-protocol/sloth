import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';
import 'package:sloth/src/rust/api/accounts.dart' as accounts_api;
import 'package:sloth/src/rust/api/relays.dart' as relays_api;

final _logger = Logger('useNetworkRelays');

enum RelayCategory { normal, inbox, keyPackage }

class RelayListState {
  final bool isLoading;
  final List<relays_api.Relay> relays;
  final String? error;

  const RelayListState({
    this.isLoading = false,
    this.relays = const [],
    this.error,
  });

  RelayListState copyWith({
    bool? isLoading,
    List<relays_api.Relay>? relays,
    String? error,
    bool clearError = false,
  }) {
    return RelayListState(
      isLoading: isLoading ?? this.isLoading,
      relays: relays ?? this.relays,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class NetworkRelaysState {
  final Map<RelayCategory, RelayListState> categoryStates;
  final Map<String, String> relayStatuses;
  final bool isAddingRelay;
  final bool isRemovingRelay;

  const NetworkRelaysState({
    this.categoryStates = const {},
    this.relayStatuses = const {},
    this.isAddingRelay = false,
    this.isRemovingRelay = false,
  });

  RelayListState get normalRelays => categoryStates[RelayCategory.normal] ?? const RelayListState();
  RelayListState get inboxRelays => categoryStates[RelayCategory.inbox] ?? const RelayListState();
  RelayListState get keyPackageRelays =>
      categoryStates[RelayCategory.keyPackage] ?? const RelayListState();

  NetworkRelaysState copyWith({
    Map<RelayCategory, RelayListState>? categoryStates,
    Map<String, String>? relayStatuses,
    bool? isAddingRelay,
    bool? isRemovingRelay,
  }) {
    return NetworkRelaysState(
      categoryStates: categoryStates ?? this.categoryStates,
      relayStatuses: relayStatuses ?? this.relayStatuses,
      isAddingRelay: isAddingRelay ?? this.isAddingRelay,
      isRemovingRelay: isRemovingRelay ?? this.isRemovingRelay,
    );
  }

  NetworkRelaysState updateCategory(RelayCategory category, RelayListState newState) {
    return copyWith(
      categoryStates: Map.from(categoryStates)..[category] = newState,
    );
  }

  RelayListState getCategory(RelayCategory category) {
    return categoryStates[category] ?? const RelayListState();
  }
}

({
  NetworkRelaysState state,
  Future<void> Function() fetchAll,
  Future<void> Function(String url, RelayCategory category) addRelay,
  Future<void> Function(String url, RelayCategory category) removeRelay,
})
useNetworkRelays(String pubkey) {
  final state = useState(const NetworkRelaysState());
  final isMountedRef = useRef(true);

  useEffect(() {
    isMountedRef.value = true;
    return () {
      isMountedRef.value = false;
    };
  }, const []);

  Future<accounts_api.RelayType> getRelayType(RelayCategory category) async {
    return switch (category) {
      RelayCategory.normal => await relays_api.relayTypeNip65(),
      RelayCategory.inbox => await relays_api.relayTypeInbox(),
      RelayCategory.keyPackage => await relays_api.relayTypeKeyPackage(),
    };
  }

  void updateCategoryState(
    RelayCategory category,
    RelayListState Function(RelayListState) updater,
  ) {
    final currentState = state.value.getCategory(category);
    state.value = state.value.updateCategory(category, updater(currentState));
  }

  Future<void> fetchRelayStatuses() async {
    try {
      final statuses = await relays_api.getAccountRelayStatuses(pubkey: pubkey);
      final statusMap = <String, String>{};
      for (final (url, status) in statuses) {
        statusMap[url] = status;
      }
      state.value = state.value.copyWith(relayStatuses: statusMap);
    } catch (e) {
      _logger.severe('Failed to fetch relay statuses', e);
    }
  }

  Future<void> fetchRelaysForCategory(RelayCategory category) async {
    updateCategoryState(
      category,
      (s) => s.copyWith(isLoading: true, clearError: true),
    );

    try {
      final relayType = await getRelayType(category);
      final relays = await accounts_api.accountRelays(pubkey: pubkey, relayType: relayType);
      updateCategoryState(
        category,
        (s) => s.copyWith(isLoading: false, relays: relays),
      );
    } catch (e) {
      _logger.severe('Failed to fetch relays for $category', e);
      updateCategoryState(
        category,
        (s) => s.copyWith(isLoading: false, error: 'Failed to fetch relays'),
      );
    }
  }

  Future<void> fetchAll() async {
    await Future.wait([
      fetchRelaysForCategory(RelayCategory.normal),
      fetchRelaysForCategory(RelayCategory.inbox),
      fetchRelaysForCategory(RelayCategory.keyPackage),
      fetchRelayStatuses(),
    ]);
  }

  void awaitRelayConnection(String url) async {
    const maxAttempts = 10;
    const retryInterval = Duration(milliseconds: 500);

    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(retryInterval);

      if (!isMountedRef.value) return;

      try {
        final statuses = await relays_api.getAccountRelayStatuses(pubkey: pubkey);
        final statusMap = <String, String>{};
        for (final (relayUrl, status) in statuses) {
          statusMap[relayUrl] = status;
        }

        if (!isMountedRef.value) return;

        state.value = state.value.copyWith(relayStatuses: statusMap);

        final currentStatus = statusMap[url];
        if (currentStatus != null && currentStatus.toLowerCase() != 'connecting') {
          break;
        }
      } catch (e) {
        _logger.warning('Failed to poll relay status', e);
        break;
      }
    }
  }

  Future<void> addRelay(String url, RelayCategory category) async {
    if (state.value.isAddingRelay) return;

    state.value = state.value.copyWith(isAddingRelay: true);

    try {
      final relayType = await getRelayType(category);
      await accounts_api.addAccountRelay(pubkey: pubkey, url: url, relayType: relayType);
      await fetchRelaysForCategory(category);
      await fetchRelayStatuses();

      awaitRelayConnection(url);
    } catch (e) {
      _logger.severe('Failed to add relay', e);
      updateCategoryState(
        category,
        (s) => s.copyWith(isLoading: false, error: 'Failed to add relay'),
      );
    } finally {
      state.value = state.value.copyWith(isAddingRelay: false);
    }
  }

  Future<void> removeRelay(String url, RelayCategory category) async {
    if (state.value.isRemovingRelay) return;

    state.value = state.value.copyWith(isRemovingRelay: true);

    try {
      final relayType = await getRelayType(category);
      await accounts_api.removeAccountRelay(pubkey: pubkey, url: url, relayType: relayType);
      await fetchRelaysForCategory(category);
      await fetchRelayStatuses();
    } catch (e) {
      _logger.severe('Failed to remove relay', e);
      updateCategoryState(
        category,
        (s) => s.copyWith(isLoading: false, error: 'Failed to remove relay'),
      );
    } finally {
      state.value = state.value.copyWith(isRemovingRelay: false);
    }
  }

  return (
    state: state.value,
    fetchAll: fetchAll,
    addRelay: addRelay,
    removeRelay: removeRelay,
  );
}
