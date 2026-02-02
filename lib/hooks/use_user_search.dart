import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/services/user_service.dart';
import 'package:sloth/src/rust/api/accounts.dart' as accounts_api;
import 'package:sloth/src/rust/api/users.dart' show User;
import 'package:sloth/utils/encoding.dart';

bool _isPartialNpubQuery(String searchQuery, String? hexPubkeyFromQuery) {
  final trimmedSearchQuery = searchQuery.trim().toLowerCase();
  if (trimmedSearchQuery.isEmpty) return false;
  return 'npub1'.startsWith(trimmedSearchQuery) ||
      (trimmedSearchQuery.startsWith('npub1') && hexPubkeyFromQuery == null);
}

typedef UserSearchState = ({
  List<User> users,
  bool isLoading,
  bool hasSearchQuery,
});

UserSearchState useUserSearch({
  required String accountPubkey,
  required String searchQuery,
}) {
  final followsRef = useRef(<User>[]);
  final trimmedSearchQuery = searchQuery.trim().toLowerCase();
  final hexPubkeyFromQuery = hexFromNpub(trimmedSearchQuery);

  final followsFuture = useMemoized(
    () => accounts_api.accountFollows(pubkey: accountPubkey),
    [accountPubkey],
  );
  final followsSnapshot = useFuture(followsFuture);
  final isLoadingFollows = followsSnapshot.connectionState == ConnectionState.waiting;

  if (followsSnapshot.hasData) {
    followsRef.value = followsSnapshot.data!;
  }

  final follows = followsRef.value;

  final followNpubs = useMemoized(() {
    final Map<String, String?> npubMap = {};
    for (final user in follows) {
      npubMap[user.pubkey] = npubFromHex(user.pubkey);
    }
    return npubMap;
  }, [follows]);

  final searchFuture = useMemoized(
    () => hexPubkeyFromQuery != null ? UserService(hexPubkeyFromQuery).fetchUser() : null,
    [hexPubkeyFromQuery],
  );
  final searchSnapshot = useFuture(searchFuture);
  final isLoadingSearch = searchSnapshot.connectionState == ConnectionState.waiting;

  final hasSearchQuery = trimmedSearchQuery.isNotEmpty;
  final isPartialNpubSearch = _isPartialNpubQuery(searchQuery, hexPubkeyFromQuery);

  final matchingFollows = useMemoized(() {
    if (!isPartialNpubSearch || follows.isEmpty) return follows;
    return follows.where((user) {
      final npub = followNpubs[user.pubkey];
      return npub != null && npub.startsWith(trimmedSearchQuery);
    }).toList();
  }, [trimmedSearchQuery, followNpubs, isPartialNpubSearch]);

  final List<User> users;
  final bool isLoading;

  if (!hasSearchQuery) {
    users = follows;
    isLoading = isLoadingFollows;
  } else if (hexPubkeyFromQuery != null) {
    isLoading = isLoadingSearch;
    final user = searchSnapshot.data;
    users = user != null ? [user] : [];
  } else if (isPartialNpubSearch) {
    users = matchingFollows;
    isLoading = isLoadingFollows;
  } else {
    users = [];
    isLoading = false;
  }

  return (users: users, isLoading: isLoading, hasSearchQuery: hasSearchQuery);
}
