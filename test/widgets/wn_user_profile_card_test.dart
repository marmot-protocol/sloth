import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/theme/semantic_colors.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_copyable_field.dart';
import 'package:sloth/widgets/wn_user_profile_card.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

const _userPubkey = 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4';

class _MockApi extends MockWnApi {
  @override
  String crateApiUtilsNpubFromHexPubkey({required String hexPubkey}) {
    return 'npub1$hexPubkey';
  }
}

final _api = _MockApi();

void main() {
  setUpAll(() => RustLib.initMock(api: _api));
  setUp(() => _api.reset());

  Future<void> pumpCard(
    WidgetTester tester, {
    FlutterMetadata? metadata,
  }) async {
    await mountWidget(
      SingleChildScrollView(
        child: WnUserProfileCard(
          userPubkey: _userPubkey,
          metadata: metadata,
        ),
      ),
      tester,
    );
  }

  group('WnUserProfileCard', () {
    testWidgets('displays avatar', (tester) async {
      await pumpCard(tester);
      expect(find.byType(WnAvatar), findsOneWidget);
    });

    testWidgets('displays public key field', (tester) async {
      await pumpCard(tester);
      expect(find.byType(WnCopyableField), findsOneWidget);
      expect(find.text('Public key'), findsOneWidget);
    });

    testWidgets('passes color derived from pubkey to avatar', (tester) async {
      await pumpCard(tester);

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.color, AccentColor.violet);
    });

    testWidgets('different pubkey passes different avatar color', (tester) async {
      await mountWidget(
        const SingleChildScrollView(
          child: WnUserProfileCard(
            userPubkey: '0123456789abcdef0123456789abcdef',
          ),
        ),
        tester,
      );

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.color, AccentColor.blue);
    });

    group('with metadata', () {
      const metadata = FlutterMetadata(
        displayName: 'Alice',
        nip05: 'alice@example.com',
        about: 'I love Nostr!',
        custom: {},
      );

      testWidgets('displays user name', (tester) async {
        await pumpCard(tester, metadata: metadata);
        expect(find.text('Alice'), findsOneWidget);
      });

      testWidgets('displays nip05', (tester) async {
        await pumpCard(tester, metadata: metadata);
        expect(find.text('alice@example.com'), findsOneWidget);
      });

      testWidgets('displays about', (tester) async {
        await pumpCard(tester, metadata: metadata);
        expect(find.text('I love Nostr!'), findsOneWidget);
      });
    });

    group('with minimal metadata', () {
      testWidgets('does not display name when null', (tester) async {
        await pumpCard(tester, metadata: const FlutterMetadata(custom: {}));
        expect(find.text('Alice'), findsNothing);
      });

      testWidgets('does not display nip05 when null', (tester) async {
        await pumpCard(tester, metadata: const FlutterMetadata(custom: {}));
        expect(find.text('alice@example.com'), findsNothing);
      });

      testWidgets('does not display about when null', (tester) async {
        await pumpCard(tester, metadata: const FlutterMetadata(custom: {}));
        expect(find.text('I love Nostr!'), findsNothing);
      });
    });
  });
}
