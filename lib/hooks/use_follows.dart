import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';
import 'package:sloth/src/rust/api/accounts.dart' as accounts_api;
import 'package:sloth/src/rust/api/users.dart' show User;

final _logger = Logger('useFollows');

typedef FollowsState = ({
  List<User> follows,
  bool isLoading,
  bool isActionLoading,
  String? error,
  void Function() refresh,
  void Function() clearError,
  Future<void> Function(String userPubkey) follow,
  Future<void> Function(String userPubkey) unfollow,
  bool Function(String userPubkey) isFollowing,
});

FollowsState useFollows(String accountPubkey) {
  final refreshKey = useState(0);
  final isActionLoading = useState(false);
  final error = useState<String?>(null);
  final followsRef = useRef(<User>[]);

  final followsFuture = useMemoized(
    () => accounts_api.accountFollows(pubkey: accountPubkey),
    [accountPubkey, refreshKey.value],
  );
  final followsSnapshot = useFuture(followsFuture);
  final isLoading = followsSnapshot.connectionState == ConnectionState.waiting;

  if (followsSnapshot.hasData) {
    followsRef.value = followsSnapshot.data!;
  }

  void refresh() {
    refreshKey.value++;
  }

  void clearError() {
    error.value = null;
  }

  Future<void> follow(String userPubkey) async {
    isActionLoading.value = true;
    error.value = null;
    try {
      await accounts_api.followUser(
        accountPubkey: accountPubkey,
        userToFollowPubkey: userPubkey,
      );
      refresh();
    } catch (e) {
      _logger.severe('Failed to follow user: $e');
      error.value = 'Failed to follow user';
      rethrow;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> unfollow(String userPubkey) async {
    isActionLoading.value = true;
    error.value = null;
    try {
      await accounts_api.unfollowUser(
        accountPubkey: accountPubkey,
        userToUnfollowPubkey: userPubkey,
      );
      refresh();
    } catch (e) {
      _logger.severe('Failed to unfollow user: $e');
      error.value = 'Failed to unfollow user';
      rethrow;
    } finally {
      isActionLoading.value = false;
    }
  }

  bool isFollowing(String userPubkey) {
    return followsRef.value.any((user) => user.pubkey == userPubkey);
  }

  return (
    follows: followsRef.value,
    isLoading: isLoading,
    isActionLoading: isActionLoading.value,
    error: error.value,
    refresh: refresh,
    clearError: clearError,
    follow: follow,
    unfollow: unfollow,
    isFollowing: isFollowing,
  );
}
