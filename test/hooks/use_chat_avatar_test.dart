import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/hooks/use_chat_avatar.dart';
import 'package:whitenoise/src/rust/api/groups.dart';
import 'package:whitenoise/src/rust/api/metadata.dart';
import 'package:whitenoise/src/rust/frb_generated.dart';
import '../test_helpers.dart';

const _pubkey = 'my_pubkey';
const _groupId = 'group_123';
const _otherPubkey = 'other_pubkey';

Group _group({required String name}) => Group(
  mlsGroupId: _groupId,
  nostrGroupId: 'nostr_$_groupId',
  name: name,
  description: '',
  adminPubkeys: const [],
  epoch: BigInt.zero,
  state: GroupState.active,
);

const _metadata = FlutterMetadata(
  displayName: 'Alice',
  name: 'alice',
  picture: 'https://example.com/alice.jpg',
  custom: {},
);

class _MockApi implements RustLibApi {
  bool isDm = false;
  String groupName = 'Test Group';
  List<String> members = [_pubkey, _otherPubkey];
  FlutterMetadata metadata = _metadata;
  bool shouldError = false;

  @override
  Future<Group> crateApiGroupsGetGroup({
    required String accountPubkey,
    required String groupId,
  }) {
    if (shouldError) return Future.error(Exception('fail'));
    return Future.value(_group(name: groupName));
  }

  @override
  Future<bool> crateApiGroupsGroupIsDirectMessageType({
    required Group that,
    required String accountPubkey,
  }) => Future.value(isDm);

  @override
  Future<List<String>> crateApiGroupsGroupMembers({
    required String pubkey,
    required String groupId,
  }) => Future.value(members);

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required String pubkey,
    required bool blockingDataSync,
  }) => Future.value(metadata);

  @override
  Future<String?> crateApiGroupsGetGroupImagePath({
    required String accountPubkey,
    required String groupId,
  }) => Future.value('https://example.com/group.jpg');

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final _api = _MockApi();

late AsyncSnapshot<ChatAvatarData> Function() getResult;

Future<void> _mountHook(WidgetTester tester) async {
  getResult = await mountHook(tester, () => useChatAvatar(_pubkey, _groupId));
  await tester.pump();
}

void main() {
  setUpAll(() => RustLib.initMock(api: _api));

  setUp(() {
    _api.isDm = false;
    _api.groupName = 'Test Group';
    _api.members = [_pubkey, _otherPubkey];
    _api.metadata = _metadata;
    _api.shouldError = false;
  });

  group('useChatAvatar', () {
    group('when is DM', () {
      setUp(() => _api.isDm = true);

      group('when other member has metadata', () {
        testWidgets('returns other member avatar data', (tester) async {
          await _mountHook(tester);

          expect(
            getResult().data,
            const ChatAvatarData(
              displayName: 'Alice',
              pictureUrl: 'https://example.com/alice.jpg',
              otherMemberPubkey: _otherPubkey,
            ),
          );
        });

        testWidgets('falls back to name when displayName is null', (tester) async {
          _api.metadata = const FlutterMetadata(name: 'bob', custom: {});
          await _mountHook(tester);

          expect(
            getResult().data,
            const ChatAvatarData(displayName: 'bob', otherMemberPubkey: _otherPubkey),
          );
        });
      });

      group('when other member has no metadata', () {
        testWidgets('returns Unknown User avatar data', (tester) async {
          _api.metadata = const FlutterMetadata(custom: {});
          await _mountHook(tester);

          expect(
            getResult().data,
            const ChatAvatarData(
              displayName: 'Unknown User',
              otherMemberPubkey: _otherPubkey,
            ),
          );
        });
      });

      group('when there is no other member', () {
        setUp(() => _api.members = [_pubkey]);

        testWidgets('returns Unknown User avatar data', (tester) async {
          await _mountHook(tester);

          expect(
            getResult().data,
            const ChatAvatarData(displayName: 'Unknown User'),
          );
        });
      });
    });

    group('when is not DM', () {
      setUp(() => _api.isDm = false);

      testWidgets('returns group avatar data', (tester) async {
        _api.groupName = 'Cool Group';
        await _mountHook(tester);

        expect(
          getResult().data,
          const ChatAvatarData(
            displayName: 'Cool Group',
            pictureUrl: 'https://example.com/group.jpg',
          ),
        );
      });

      testWidgets('returns Unknown group when group name is empty', (tester) async {
        _api.groupName = '';
        await _mountHook(tester);

        expect(
          getResult().data,
          const ChatAvatarData(
            displayName: 'Unknown group',
            pictureUrl: 'https://example.com/group.jpg',
          ),
        );
      });

      group('on error', () {
        setUp(() {
          _api.shouldError = true;
        });

        testWidgets('returns error on failure', (tester) async {
          await _mountHook(tester);

          expect(getResult().hasError, isTrue);
        });
      });
    });
  });

  group('ChatAvatarData equality and hashCode', () {
    test('equal objects have equal hash codes', () {
      const avatar1 = ChatAvatarData(
        displayName: 'Alice',
        pictureUrl: 'https://example.com/alice.jpg',
        otherMemberPubkey: 'pubkey1',
      );
      const avatar2 = ChatAvatarData(
        displayName: 'Alice',
        pictureUrl: 'https://example.com/alice.jpg',
        otherMemberPubkey: 'pubkey1',
      );

      expect(avatar1, avatar2);
      expect(avatar1.hashCode, avatar2.hashCode);
    });

    test('equal objects with null pictureUrl have equal hash codes', () {
      const avatar1 = ChatAvatarData(displayName: 'Bob');
      const avatar2 = ChatAvatarData(displayName: 'Bob');

      expect(avatar1, avatar2);
      expect(avatar1.hashCode, avatar2.hashCode);
    });

    test('different displayNames produce different hash codes', () {
      const avatar1 = ChatAvatarData(displayName: 'Alice');
      const avatar2 = ChatAvatarData(displayName: 'Bob');

      expect(avatar1, isNot(avatar2));
      expect(avatar1.hashCode, isNot(avatar2.hashCode));
    });

    test('different pictureUrls produce different hash codes', () {
      const avatar1 = ChatAvatarData(
        displayName: 'Alice',
        pictureUrl: 'https://example.com/pic1.jpg',
      );
      const avatar2 = ChatAvatarData(
        displayName: 'Alice',
        pictureUrl: 'https://example.com/pic2.jpg',
      );

      expect(avatar1, isNot(avatar2));
      expect(avatar1.hashCode, isNot(avatar2.hashCode));
    });

    test('different otherMemberPubkeys produce different hash codes', () {
      const avatar1 = ChatAvatarData(
        displayName: 'Alice',
        otherMemberPubkey: 'pubkey1',
      );
      const avatar2 = ChatAvatarData(
        displayName: 'Alice',
        otherMemberPubkey: 'pubkey2',
      );

      expect(avatar1, isNot(avatar2));
      expect(avatar1.hashCode, isNot(avatar2.hashCode));
    });
  });
}
