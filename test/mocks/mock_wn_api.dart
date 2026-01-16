import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/src/rust/api/chat_list.dart';
import 'package:sloth/src/rust/api/groups.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

class MockWnApi implements RustLibApi {
  @override
  Future<List<ChatMessage>> crateApiMessagesFetchAggregatedMessagesForGroup({
    required String pubkey,
    required String groupId,
  }) async {
    return [];
  }

  @override
  Future<bool> crateApiGroupsGroupIsDirectMessageType({
    required Group that,
    required String accountPubkey,
  }) async {
    return false;
  }

  @override
  Future<String?> crateApiGroupsGetGroupImagePath({
    required String accountPubkey,
    required String groupId,
  }) async {
    return null;
  }

  @override
  Stream<MessageStreamItem> crateApiMessagesSubscribeToGroupMessages({
    required String groupId,
  }) {
    return Stream.value(const MessageStreamItem.initialSnapshot(messages: []));
  }

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async {
    return const FlutterMetadata(custom: {});
  }

  @override
  Stream<ChatListStreamItem> crateApiChatListSubscribeToChatList({
    required String accountPubkey,
  }) {
    return Stream.value(const ChatListStreamItem.initialSnapshot(items: []));
  }

  @override
  Future<List<String>> crateApiGroupsGroupMembers({
    required String pubkey,
    required String groupId,
  }) async => [];

  @override
  Future<void> crateApiAccountsLogout({required String pubkey}) async {}

  @override
  Future<String> crateApiUtilsGetDefaultBlossomServerUrl() async => 'https://blossom.example.com';

  @override
  Future<void> crateApiAccountsUpdateAccountMetadata({
    required String pubkey,
    required FlutterMetadata metadata,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
