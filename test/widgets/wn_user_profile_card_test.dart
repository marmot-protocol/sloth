import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_copy_card.dart';
import 'package:sloth/widgets/wn_user_profile_card.dart';
import '../mocks/mock_clipboard.dart' show clearClipboardMock, mockClipboard, mockClipboardFailing;
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

final _api = MockWnApi();

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
          userPubkey: testPubkeyA,
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

    testWidgets('displays public key copy card', (tester) async {
      await pumpCard(tester);
      expect(find.byType(WnCopyCard), findsOneWidget);
    });

    testWidgets('npub is displayed formatted', (tester) async {
      await pumpCard(tester);
      final copyCard = tester.widget<WnCopyCard>(find.byType(WnCopyCard));
      expect(copyCard.textToDisplay, testNpubAFormatted);
    });

    group('copy to clipboard', () {
      tearDown(clearClipboardMock);
      testWidgets('npub can be copied', (tester) async {
        final getClipboard = mockClipboard();
        await pumpCard(tester);
        await tester.tap(find.byKey(const Key('copy_button')));
        expect(getClipboard(), testNpubA);
      });
    });

    testWidgets('invokes onPublicKeyCopied when public key is copied', (tester) async {
      mockClipboard();
      var copied = false;
      await mountWidget(
        SingleChildScrollView(
          child: WnUserProfileCard(
            userPubkey: testPubkeyA,
            onPublicKeyCopied: () => copied = true,
          ),
        ),
        tester,
      );
      await tester.tap(find.byKey(const Key('copy_button')));
      expect(copied, isTrue);
    });

    testWidgets('invokes onPublicKeyCopyError when copy fails', (tester) async {
      mockClipboardFailing();
      addTearDown(clearClipboardMock);
      var onCopyErrorCalled = false;
      await mountWidget(
        SingleChildScrollView(
          child: WnUserProfileCard(
            userPubkey: testPubkeyA,
            onPublicKeyCopyError: () => onCopyErrorCalled = true,
          ),
        ),
        tester,
      );
      await tester.tap(find.byKey(const Key('copy_button')));
      await tester.pumpAndSettle();
      expect(onCopyErrorCalled, isTrue);
    });

    testWidgets('passes color derived from pubkey to avatar', (tester) async {
      await pumpCard(tester);

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.color, AvatarColor.violet);
    });

    testWidgets('different pubkey passes different avatar color', (tester) async {
      await mountWidget(
        const SingleChildScrollView(
          child: WnUserProfileCard(
            userPubkey: testPubkeyD,
          ),
        ),
        tester,
      );

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.color, AvatarColor.cyan);
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
