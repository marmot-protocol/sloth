import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/src/rust/api/media_files.dart';
import 'package:whitenoise/src/rust/frb_generated.dart';
import 'package:whitenoise/widgets/wn_media_tile.dart';
import 'package:whitenoise/widgets/wn_message_media.dart';

import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

MediaFile _mediaFile(String id) => MediaFile(
  id: id,
  mlsGroupId: testGroupId,
  accountPubkey: testPubkeyA,
  filePath: '/test/path/$id.jpg',
  originalFileHash: 'hash$id',
  encryptedFileHash: 'encrypted$id',
  mimeType: 'image/jpeg',
  mediaType: 'image',
  blossomUrl: 'https://example.com/$id',
  nostrKey: 'nostr$id',
  createdAt: DateTime(2024),
);

class _MockApi extends MockWnApi {
  Completer<MediaFile>? downloadCompleter;

  @override
  Future<MediaFile> crateApiMediaFilesDownloadChatMedia({
    required String accountPubkey,
    required String groupId,
    required String originalFileHash,
  }) async {
    if (downloadCompleter != null) return downloadCompleter!.future;
    return _mediaFile(originalFileHash.replaceFirst('hash', ''));
  }
}

final _api = _MockApi();

void main() {
  setUpAll(() => RustLib.initMock(api: _api));
  setUp(() => _api.downloadCompleter = null);

  group('WnMessageMedia', () {
    testWidgets('returns empty when mediaFiles is empty', (tester) async {
      await mountWidget(const WnMessageMedia(mediaFiles: []), tester);

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(WnMediaTile), findsNothing);
    });

    group('one attachment layout', () {
      testWidgets('renders one_layout key', (tester) async {
        await mountWidget(WnMessageMedia(mediaFiles: [_mediaFile('1')]), tester);

        expect(find.byKey(const Key('one_layout')), findsOneWidget);
        expect(find.byType(WnMediaTile), findsOneWidget);
      });

      testWidgets('uses square aspect ratio', (tester) async {
        await mountWidget(WnMessageMedia(mediaFiles: [_mediaFile('1')]), tester);

        final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio).first);
        expect(aspectRatio.aspectRatio, 1.0);
      });

      testWidgets('creates tappable tile with correct key', (tester) async {
        await mountWidget(
          WnMessageMedia(mediaFiles: [_mediaFile('1')], onMediaTap: (_) {}),
          tester,
        );

        expect(find.byKey(const Key('tappable_media_tile_0')), findsOneWidget);
      });
    });

    group('two attachments layout', () {
      testWidgets('renders two_layout key', (tester) async {
        await mountWidget(
          WnMessageMedia(mediaFiles: [_mediaFile('1'), _mediaFile('2')]),
          tester,
        );

        expect(find.byKey(const Key('two_layout')), findsOneWidget);
        expect(find.byType(WnMediaTile), findsNWidgets(2));
      });

      testWidgets('creates tappable tiles with correct keys', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: [_mediaFile('1'), _mediaFile('2')],
            onMediaTap: (_) {},
          ),
          tester,
        );

        expect(find.byKey(const Key('tappable_media_tile_0')), findsOneWidget);
        expect(find.byKey(const Key('tappable_media_tile_1')), findsOneWidget);
      });
    });

    group('three attachments layout', () {
      testWidgets('renders three_layout key', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: [_mediaFile('1'), _mediaFile('2'), _mediaFile('3')],
          ),
          tester,
        );

        expect(find.byKey(const Key('three_layout')), findsOneWidget);
        expect(find.byType(WnMediaTile), findsNWidgets(3));
      });

      testWidgets('creates tappable tiles with correct keys', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: [_mediaFile('1'), _mediaFile('2'), _mediaFile('3')],
            onMediaTap: (_) {},
          ),
          tester,
        );

        expect(find.byKey(const Key('tappable_media_tile_0')), findsOneWidget);
        expect(find.byKey(const Key('tappable_media_tile_1')), findsOneWidget);
        expect(find.byKey(const Key('tappable_media_tile_2')), findsOneWidget);
      });
    });

    group('four attachments layout', () {
      testWidgets('renders four_layout key', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: [
              _mediaFile('1'),
              _mediaFile('2'),
              _mediaFile('3'),
              _mediaFile('4'),
            ],
          ),
          tester,
        );

        expect(find.byKey(const Key('four_layout')), findsOneWidget);
        expect(find.byType(WnMediaTile), findsNWidgets(4));
      });

      testWidgets('does not show overflow indicator', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: [
              _mediaFile('1'),
              _mediaFile('2'),
              _mediaFile('3'),
              _mediaFile('4'),
            ],
          ),
          tester,
        );

        expect(find.byKey(const Key('overflow_indicator')), findsNothing);
      });

      testWidgets('creates tappable tiles with correct keys', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: [
              _mediaFile('1'),
              _mediaFile('2'),
              _mediaFile('3'),
              _mediaFile('4'),
            ],
            onMediaTap: (_) {},
          ),
          tester,
        );

        expect(find.byKey(const Key('tappable_media_tile_0')), findsOneWidget);
        expect(find.byKey(const Key('tappable_media_tile_1')), findsOneWidget);
        expect(find.byKey(const Key('tappable_media_tile_2')), findsOneWidget);
        expect(find.byKey(const Key('tappable_media_tile_3')), findsOneWidget);
      });
    });

    group('five attachments layout', () {
      testWidgets('renders five_layout key', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: [
              _mediaFile('1'),
              _mediaFile('2'),
              _mediaFile('3'),
              _mediaFile('4'),
              _mediaFile('5'),
            ],
          ),
          tester,
        );

        expect(find.byKey(const Key('five_layout')), findsOneWidget);
        expect(find.byType(WnMediaTile), findsNWidgets(5));
      });

      testWidgets('does not show overflow indicator', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: [
              _mediaFile('1'),
              _mediaFile('2'),
              _mediaFile('3'),
              _mediaFile('4'),
              _mediaFile('5'),
            ],
          ),
          tester,
        );

        expect(find.byKey(const Key('overflow_indicator')), findsNothing);
      });

      testWidgets('creates tappable tiles with correct keys', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: [
              _mediaFile('1'),
              _mediaFile('2'),
              _mediaFile('3'),
              _mediaFile('4'),
              _mediaFile('5'),
            ],
            onMediaTap: (_) {},
          ),
          tester,
        );

        for (var i = 0; i < 5; i++) {
          expect(find.byKey(Key('tappable_media_tile_$i')), findsOneWidget);
        }
      });
    });

    group('six attachments layout', () {
      testWidgets('renders six_plus_layout key', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: [
              _mediaFile('1'),
              _mediaFile('2'),
              _mediaFile('3'),
              _mediaFile('4'),
              _mediaFile('5'),
              _mediaFile('6'),
            ],
          ),
          tester,
        );

        expect(find.byKey(const Key('six_plus_layout')), findsOneWidget);
        expect(find.byType(WnMediaTile), findsNWidgets(6));
      });

      testWidgets('does not show overflow indicator for exactly 6', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: [
              _mediaFile('1'),
              _mediaFile('2'),
              _mediaFile('3'),
              _mediaFile('4'),
              _mediaFile('5'),
              _mediaFile('6'),
            ],
          ),
          tester,
        );

        expect(find.byKey(const Key('overflow_indicator')), findsNothing);
      });

      testWidgets('creates tappable tiles with correct keys', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: [
              _mediaFile('1'),
              _mediaFile('2'),
              _mediaFile('3'),
              _mediaFile('4'),
              _mediaFile('5'),
              _mediaFile('6'),
            ],
            onMediaTap: (_) {},
          ),
          tester,
        );

        for (var i = 0; i < 6; i++) {
          expect(find.byKey(Key('tappable_media_tile_$i')), findsOneWidget);
        }
      });
    });

    group('overflow (7+ attachments)', () {
      testWidgets('shows overflow indicator for 7 attachments', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: [
              _mediaFile('1'),
              _mediaFile('2'),
              _mediaFile('3'),
              _mediaFile('4'),
              _mediaFile('5'),
              _mediaFile('6'),
              _mediaFile('7'),
            ],
          ),
          tester,
        );

        expect(find.byKey(const Key('six_plus_layout')), findsOneWidget);
        expect(find.byType(WnMediaTile), findsNWidgets(6));
        expect(find.byKey(const Key('overflow_indicator')), findsOneWidget);
        expect(find.text('+1'), findsOneWidget);
      });

      testWidgets('shows correct overflow count for 8 attachments', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: [
              _mediaFile('1'),
              _mediaFile('2'),
              _mediaFile('3'),
              _mediaFile('4'),
              _mediaFile('5'),
              _mediaFile('6'),
              _mediaFile('7'),
              _mediaFile('8'),
            ],
          ),
          tester,
        );

        expect(find.text('+2'), findsOneWidget);
      });

      testWidgets('shows correct overflow count for many attachments', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: List.generate(10, (i) => _mediaFile('${i + 1}')),
          ),
          tester,
        );

        expect(find.text('+4'), findsOneWidget);
      });

      testWidgets('only shows first 6 tiles', (tester) async {
        await mountWidget(
          WnMessageMedia(
            mediaFiles: List.generate(10, (i) => _mediaFile('${i + 1}')),
            onMediaTap: (_) {},
          ),
          tester,
        );

        for (var i = 0; i < 6; i++) {
          expect(find.byKey(Key('tappable_media_tile_$i')), findsOneWidget);
        }
        expect(find.byKey(const Key('tappable_media_tile_6')), findsNothing);
      });
    });

    group('tap handling', () {
      testWidgets('calls onMediaTap with correct index when tapped', (tester) async {
        var tappedIndex = -1;

        await mountWidget(
          SizedBox(
            width: 300,
            child: WnMessageMedia(
              mediaFiles: [_mediaFile('1')],
              onMediaTap: (index) => tappedIndex = index,
            ),
          ),
          tester,
        );

        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tappable_media_tile_0')), findsOneWidget);
        await tester.tap(find.byKey(const Key('tappable_media_tile_0')));
        await tester.pumpAndSettle();
        expect(tappedIndex, 0);
      });

      testWidgets('does not crash when onMediaTap is null', (tester) async {
        await mountWidget(
          SizedBox(
            width: 300,
            child: WnMessageMedia(mediaFiles: [_mediaFile('1')]),
          ),
          tester,
        );

        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('tappable_media_tile_0')));
        // No exception = pass
      });
    });
  });
}
