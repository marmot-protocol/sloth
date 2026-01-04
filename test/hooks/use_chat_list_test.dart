import 'dart:async' show Completer;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/hooks/use_chat_list.dart';
import 'package:sloth/src/rust/api/chat_list.dart';
import 'package:sloth/src/rust/api/groups.dart' show GroupType;
import 'package:sloth/src/rust/frb_generated.dart';
import '../test_helpers.dart';

ChatSummary _chatSummaryFactory(String id, DateTime createdAt) => ChatSummary(
  mlsGroupId: 'mls_$id',
  name: 'Chat $id',
  groupType: GroupType.group,
  createdAt: createdAt,
  pendingConfirmation: false,
);

class _MockApi implements RustLibApi {
  final Map<String, List<ChatSummary>> chatListByPubkey = {};
  Completer<List<ChatSummary>>? completer;
  final calls = <String>[];

  @override
  Future<List<ChatSummary>> crateApiChatListGetChatList({
    required String accountPubkey,
  }) {
    calls.add(accountPubkey);
    if (completer != null) return completer!.future;
    return Future.value(chatListByPubkey[accountPubkey] ?? []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final _api = _MockApi();

late ChatListResult Function() getResult;

Future<void> _pump(WidgetTester tester, String pubkey) async {
  getResult = await mountHook(tester, () => useChatList(pubkey));
}

void main() {
  setUpAll(() => RustLib.initMock(api: _api));

  setUp(() {
    _api.chatListByPubkey.clear();
    _api.completer = null;
    _api.calls.clear();
  });

  group('useChatList', () {
    group('when loading', () {
      setUp(() => _api.completer = Completer());

      testWidgets('is waiting', (tester) async {
        await _pump(tester, 'pk1');

        expect(getResult().snapshot.connectionState, ConnectionState.waiting);
      });
    });

    group('without chats', () {
      testWidgets('returns empty list', (tester) async {
        await _pump(tester, 'pk1');
        await tester.pump();

        expect(getResult().snapshot.data, isEmpty);
      });
    });

    group('with single chat', () {
      setUp(() => _api.chatListByPubkey['pk1'] = [_chatSummaryFactory('c1', DateTime(2024))]);
      testWidgets('returns expected chat', (tester) async {
        await _pump(tester, 'pk1');
        await tester.pump();

        expect(getResult().snapshot.data?.length, 1);
      });
    });

    group('with multiple chats', () {
      setUp(
        () => _api.chatListByPubkey['pk1'] = [
          _chatSummaryFactory('c1', DateTime(2024)),
          _chatSummaryFactory('c2', DateTime(2024, 1, 2)),
          _chatSummaryFactory('c3', DateTime(2024, 1, 3)),
        ],
      );

      testWidgets('returns multiple chat summaries', (tester) async {
        await _pump(tester, 'pk1');
        await tester.pump();

        expect(getResult().snapshot.data?.length, 3);
      });
    });

    group('refresh', () {
      testWidgets('triggers refetch', (tester) async {
        await _pump(tester, 'pk1');
        await tester.pump();
        getResult().refresh();
        await tester.pump();

        expect(_api.calls.length, 2);
      });
    });

    group('pubkey change', () {
      testWidgets('returns data for last pubkey', (tester) async {
        _api.chatListByPubkey['pk1'] = [_chatSummaryFactory('c1', DateTime(2024))];
        _api.chatListByPubkey['pk2'] = [_chatSummaryFactory('c2', DateTime(2024, 1, 2))];
        await _pump(tester, 'pk1');
        await tester.pump();
        await _pump(tester, 'pk2');
        await tester.pump();

        expect(_api.calls, ['pk1', 'pk2']);
        expect(getResult().snapshot.data?.first.mlsGroupId, 'mls_c2');
      });
    });
  });
}
