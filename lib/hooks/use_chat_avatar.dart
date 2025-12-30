import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';
import 'package:sloth/src/rust/api/groups.dart' as groups_api;
import 'package:sloth/src/rust/api/users.dart' as users_api;

final _logger = Logger('useChatAvatar');

class ChatAvatarData {
  final String displayName;
  final String? pictureUrl;

  const ChatAvatarData({
    required this.displayName,
    this.pictureUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatAvatarData &&
          runtimeType == other.runtimeType &&
          displayName == other.displayName &&
          pictureUrl == other.pictureUrl;

  @override
  int get hashCode => Object.hash(displayName, pictureUrl);
}

AsyncSnapshot<ChatAvatarData> useChatAvatar(String pubkey, String groupId) {
  final future = useMemoized(
    () => _fetchGroupAvatar(pubkey, groupId),
    [pubkey, groupId],
  );
  return useFuture(future);
}

Future<ChatAvatarData> _fetchGroupAvatar(String pubkey, String groupId) async {
  _logger.fine('Fetching group avatar for groupId: $groupId');

  final group = await groups_api.getGroup(
    accountPubkey: pubkey,
    groupId: groupId,
  );

  final isDm = await group.isDirectMessageType(accountPubkey: pubkey);

  if (isDm) {
    _logger.info('Fetching DM avatar data');
    return await _fetchDmAvatarData(group, pubkey);
  } else {
    _logger.info('Fetching group avatar data');
    return await _fetchGroupAvatarData(group, pubkey);
  }
}

Future<ChatAvatarData> _fetchGroupAvatarData(groups_api.Group group, String pubkey) async {
  _logger.info('Fetching group image path');
  final imagePath = await groups_api.getGroupImagePath(
    accountPubkey: pubkey,
    groupId: group.mlsGroupId,
  );
  _logger.fine('Group image path fetched');
  return ChatAvatarData(
    displayName: group.name.isEmpty ? 'Unknown group' : group.name,
    pictureUrl: imagePath,
  );
}

Future<ChatAvatarData> _fetchDmAvatarData(
  groups_api.Group group,
  String pubkey,
) async {
  final groupId = group.mlsGroupId;
  _logger.info('Fetching group members');
  final memberPubkeys = await groups_api.groupMembers(
    pubkey: pubkey,
    groupId: groupId,
  );

  final otherMemberPubkey = memberPubkeys.where((p) => p != pubkey).firstOrNull;

  if (otherMemberPubkey == null) {
    _logger.warning('No other member found in DM group');
    return const ChatAvatarData(displayName: 'Unknown User');
  }

  final metadata = await users_api.userMetadata(
    pubkey: otherMemberPubkey,
    blockingDataSync: false,
  );

  return ChatAvatarData(
    displayName: metadata.displayName ?? metadata.name ?? 'Unknown User',
    pictureUrl: metadata.picture,
  );
}
