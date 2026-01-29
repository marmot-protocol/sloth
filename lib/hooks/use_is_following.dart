import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';
import 'package:sloth/src/rust/api/accounts.dart' as accounts_api;

final _logger = Logger('useIsFollowing');

typedef IsFollowingState = ({
  bool isFollowing,
  bool isLoading,
  bool isActionLoading,
  String? error,
  void Function() clearError,
  Future<void> Function() follow,
  Future<void> Function() unfollow,
});

IsFollowingState useIsFollowing({
  required String accountPubkey,
  required String userPubkey,
}) {
  final refreshKey = useState(0);
  final isActionLoading = useState(false);
  final error = useState<String?>(null);
  final isFollowingRef = useRef<bool?>(null);

  final isFollowingFuture = useMemoized(
    () => accounts_api.isFollowingUser(
      accountPubkey: accountPubkey,
      userPubkey: userPubkey,
    ),
    [accountPubkey, userPubkey, refreshKey.value],
  );
  final isFollowingSnapshot = useFuture(isFollowingFuture);

  if (isFollowingSnapshot.hasData) {
    isFollowingRef.value = isFollowingSnapshot.data;
  }

  final hasInitialData = isFollowingRef.value != null;
  final isLoading =
      !hasInitialData && isFollowingSnapshot.connectionState == ConnectionState.waiting;

  void clearError() {
    error.value = null;
  }

  Future<void> follow() async {
    isActionLoading.value = true;
    error.value = null;
    try {
      await accounts_api.followUser(
        accountPubkey: accountPubkey,
        userToFollowPubkey: userPubkey,
      );
      refreshKey.value++;
    } catch (e) {
      _logger.severe('Failed to follow user: $e');
      error.value = 'Failed to follow user';
      rethrow;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> unfollow() async {
    isActionLoading.value = true;
    error.value = null;
    try {
      await accounts_api.unfollowUser(
        accountPubkey: accountPubkey,
        userToUnfollowPubkey: userPubkey,
      );
      refreshKey.value++;
    } catch (e) {
      _logger.severe('Failed to unfollow user: $e');
      error.value = 'Failed to unfollow user';
      rethrow;
    } finally {
      isActionLoading.value = false;
    }
  }

  return (
    isFollowing: isFollowingRef.value ?? false,
    isLoading: isLoading,
    isActionLoading: isActionLoading.value,
    error: error.value,
    clearError: clearError,
    follow: follow,
    unfollow: unfollow,
  );
}
