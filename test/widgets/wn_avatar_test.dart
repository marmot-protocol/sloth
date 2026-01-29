import 'dart:io' show File, FileSystemException, IOOverrides;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/theme/semantic_colors.dart' show AccentColor;
import 'package:sloth/widgets/wn_avatar.dart' show WnAvatar, WnAvatarSize;
import 'package:sloth/widgets/wn_icon.dart' show WnIcon;

import '../test_helpers.dart' show mountWidget;

class _PendingImageProvider extends ImageProvider<_PendingImageProvider> {
  @override
  Future<_PendingImageProvider> obtainKey(ImageConfiguration configuration) {
    return Future.value(this);
  }

  @override
  ImageStreamCompleter loadImage(_PendingImageProvider key, ImageDecoderCallback decode) {
    return _NeverCompletingImageStreamCompleter();
  }
}

class _NeverCompletingImageStreamCompleter extends ImageStreamCompleter {}

class _FailingImageProvider extends ImageProvider<_FailingImageProvider> {
  @override
  Future<_FailingImageProvider> obtainKey(ImageConfiguration configuration) {
    return Future.value(this);
  }

  @override
  ImageStreamCompleter loadImage(_FailingImageProvider key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter(
      Future.error(Exception('Simulated image load error')),
    );
  }
}

class _SuccessImageProvider extends ImageProvider<_SuccessImageProvider> {
  @override
  Future<_SuccessImageProvider> obtainKey(ImageConfiguration configuration) {
    return Future.value(this);
  }

  @override
  ImageStreamCompleter loadImage(_SuccessImageProvider key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter(_createTestImage());
  }

  Future<ImageInfo> _createTestImage() async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder);
    final image = await recorder.endRecording().toImage(1, 1);
    return ImageInfo(image: image);
  }
}

class _SuccessThenFailImageProvider extends ImageProvider<int> {
  int _resolveCount = 0;

  @override
  Future<int> obtainKey(ImageConfiguration configuration) {
    _resolveCount++;
    return Future.value(_resolveCount);
  }

  @override
  ImageStreamCompleter loadImage(int key, ImageDecoderCallback decode) {
    if (key == 1) {
      return OneFrameImageStreamCompleter(_createTestImage());
    }
    return OneFrameImageStreamCompleter(Future.error(Exception('Error on reload')));
  }

  Future<ImageInfo> _createTestImage() async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder);
    final image = await recorder.endRecording().toImage(1, 1);
    return ImageInfo(image: image);
  }
}

class _ErrorFile extends Fake implements File {
  _ErrorFile(this.path);

  @override
  final String path;

  @override
  Never readAsBytesSync() => throw const FileSystemException('Failed to read');
}

void main() {
  group('WnAvatar', () {
    group('without pictureUrl', () {
      testWidgets('shows user icon when no displayName', (tester) async {
        await mountWidget(const WnAvatar(), tester);
        expect(find.byType(WnIcon), findsOneWidget);
        expect(find.text('A'), findsNothing);
      });

      testWidgets('shows user icon when displayName is empty', (tester) async {
        await mountWidget(const WnAvatar(displayName: ''), tester);
        expect(find.byType(WnIcon), findsOneWidget);
        expect(find.text('A'), findsNothing);
      });

      testWidgets('shows single initial for one word name', (tester) async {
        await mountWidget(const WnAvatar(displayName: 'alice'), tester);
        expect(find.text('A'), findsOneWidget);
      });

      testWidgets('shows first initial for two word name', (tester) async {
        await mountWidget(const WnAvatar(displayName: 'alice bob'), tester);
        expect(find.text('A'), findsOneWidget);
      });
    });

    group('with empty pictureUrl', () {
      testWidgets('shows user icon', (tester) async {
        await mountWidget(const WnAvatar(pictureUrl: ''), tester);
        expect(find.byType(WnIcon), findsOneWidget);
      });
    });

    group('with image', () {
      testWidgets('shows image with zero opacity while loading', (tester) async {
        await mountWidget(
          WnAvatar(imageProvider: _PendingImageProvider()),
          tester,
        );
        final animatedOpacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
        expect(animatedOpacity.opacity, 0.0);
      });

      testWidgets('shows initial while image is loading', (tester) async {
        await mountWidget(
          WnAvatar(
            imageProvider: _PendingImageProvider(),
            displayName: 'alice',
          ),
          tester,
        );
        expect(find.text('A'), findsOneWidget);
      });

      testWidgets('shows initials on error', (tester) async {
        await mountWidget(
          WnAvatar(
            imageProvider: _FailingImageProvider(),
            displayName: 'alice bob',
          ),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.text('A'), findsOneWidget);
      });

      testWidgets('shows initials on error without AnimatedOpacity', (tester) async {
        await mountWidget(
          WnAvatar(imageProvider: _FailingImageProvider()),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.byType(AnimatedOpacity), findsNothing);
      });

      testWidgets('shows image with full opacity on success', (tester) async {
        await mountWidget(
          WnAvatar(imageProvider: _SuccessImageProvider()),
          tester,
        );
        await tester.pumpAndSettle();

        final animatedOpacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
        expect(animatedOpacity.opacity, 1.0);
      });

      testWidgets('shows image on success', (tester) async {
        await mountWidget(
          WnAvatar(imageProvider: _SuccessImageProvider()),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsNWidgets(2));
      });
    });

    group('with color', () {
      testWidgets('shows initials with blue color', (tester) async {
        await mountWidget(
          const WnAvatar(
            displayName: 'alice',
            color: AccentColor.blue,
          ),
          tester,
        );

        expect(find.text('A'), findsOneWidget);
      });
    });

    group('edit button', () {
      testWidgets('does not show edit button when onEditTap is null', (tester) async {
        await mountWidget(
          const WnAvatar(displayName: 'alice', size: WnAvatarSize.large),
          tester,
        );

        expect(find.byKey(const Key('avatar_edit_button')), findsNothing);
      });

      testWidgets('shows edit button when onEditTap is provided and size is large', (tester) async {
        await mountWidget(
          WnAvatar(
            displayName: 'alice',
            size: WnAvatarSize.large,
            onEditTap: () {},
          ),
          tester,
        );

        expect(find.byKey(const Key('avatar_edit_button')), findsOneWidget);
      });

      testWidgets('does not show edit button for small size even with onEditTap', (tester) async {
        await mountWidget(
          WnAvatar(
            displayName: 'alice',
            onEditTap: () {},
          ),
          tester,
        );

        expect(find.byKey(const Key('avatar_edit_button')), findsNothing);
      });

      testWidgets('does not show edit button for medium size even with onEditTap', (tester) async {
        await mountWidget(
          WnAvatar(
            displayName: 'alice',
            size: WnAvatarSize.medium,
            onEditTap: () {},
          ),
          tester,
        );

        expect(find.byKey(const Key('avatar_edit_button')), findsNothing);
      });

      testWidgets('calls onEditTap when edit button is tapped', (tester) async {
        var tapped = false;
        await mountWidget(
          WnAvatar(
            displayName: 'alice',
            size: WnAvatarSize.large,
            onEditTap: () => tapped = true,
          ),
          tester,
        );

        await tester.tap(find.byKey(const Key('avatar_edit_button')));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('shows edit button with image', (tester) async {
        await mountWidget(
          WnAvatar(
            imageProvider: _SuccessImageProvider(),
            size: WnAvatarSize.large,
            onEditTap: () {},
          ),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('avatar_edit_button')), findsOneWidget);
        expect(find.byType(Image), findsNWidgets(2));
      });

      testWidgets('shows edit button with color', (tester) async {
        await mountWidget(
          WnAvatar(
            displayName: 'alice',
            color: AccentColor.rose,
            size: WnAvatarSize.large,
            onEditTap: () {},
          ),
          tester,
        );

        expect(find.byKey(const Key('avatar_edit_button')), findsOneWidget);
        expect(find.text('A'), findsOneWidget);
      });
    });

    group('local file path', () {
      testWidgets('shows initials when local file fails to load', (tester) async {
        await IOOverrides.runZoned(
          () async {
            await mountWidget(
              const WnAvatar(
                pictureUrl: '/fake/path/image.jpg',
                displayName: 'John Doe',
              ),
              tester,
            );
            await tester.pumpAndSettle();

            expect(find.text('J'), findsOneWidget);
          },
          createFile: (path) => _ErrorFile(path),
        );
      });

      testWidgets('shows user icon when local file fails and no displayName', (tester) async {
        await IOOverrides.runZoned(
          () async {
            await mountWidget(
              const WnAvatar(pictureUrl: '/fake/path/image.jpg'),
              tester,
            );
            await tester.pumpAndSettle();

            expect(find.byType(WnIcon), findsOneWidget);
            expect(find.text('A'), findsNothing);
          },
          createFile: (path) => _ErrorFile(path),
        );
      });

      testWidgets('shows initials when network image fails to load', (tester) async {
        await mountWidget(
          WnAvatar(
            imageProvider: _FailingImageProvider(),
            displayName: 'John Doe',
          ),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.text('J'), findsOneWidget);
      });
    });

    group('with valid URL pictureUrl', () {
      testWidgets('renders Image widget for http URLs', (tester) async {
        await mountWidget(
          const WnAvatar(
            pictureUrl: 'http://example.com/image.jpg',
            displayName: 'Test',
          ),
          tester,
        );
        await tester.pump();

        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('renders Image widget for https URLs', (tester) async {
        await mountWidget(
          const WnAvatar(
            pictureUrl: 'https://example.com/image.jpg',
            displayName: 'Test',
          ),
          tester,
        );
        await tester.pump();

        expect(find.byType(Image), findsOneWidget);
      });
    });

    group('image transitions', () {
      testWidgets('shows initials when first image is loading', (tester) async {
        await mountWidget(
          WnAvatar(
            imageProvider: _PendingImageProvider(),
            displayName: 'alice',
          ),
          tester,
        );

        expect(find.text('A'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('shows previous image while new image loads', (tester) async {
        final firstProvider = _SuccessImageProvider();
        final secondProvider = _PendingImageProvider();
        final key = UniqueKey();

        await mountWidget(
          WnAvatar(
            key: key,
            imageProvider: firstProvider,
            displayName: 'alice',
          ),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsNWidgets(2));

        await mountWidget(
          WnAvatar(
            key: key,
            imageProvider: secondProvider,
            displayName: 'alice',
          ),
          tester,
        );
        await tester.pump();

        expect(find.byType(Image), findsNWidgets(2));
      });

      testWidgets('resets loading state when image changes', (tester) async {
        final firstProvider = _SuccessImageProvider();
        final secondProvider = _PendingImageProvider();
        final key = UniqueKey();

        await mountWidget(
          WnAvatar(
            key: key,
            imageProvider: firstProvider,
            displayName: 'alice',
          ),
          tester,
        );
        await tester.pumpAndSettle();

        var animatedOpacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
        expect(animatedOpacity.opacity, 1.0);

        await mountWidget(
          WnAvatar(
            key: key,
            imageProvider: secondProvider,
            displayName: 'alice',
          ),
          tester,
        );
        await tester.pump();

        animatedOpacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
        expect(animatedOpacity.opacity, 0.0);
      });

      testWidgets('shows previous image on error instead of initials', (tester) async {
        final firstProvider = _SuccessImageProvider();
        final failingProvider = _FailingImageProvider();
        final key = UniqueKey();

        await mountWidget(
          WnAvatar(
            key: key,
            imageProvider: firstProvider,
            displayName: 'alice',
          ),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsNWidgets(2));

        await mountWidget(
          WnAvatar(
            key: key,
            imageProvider: failingProvider,
            displayName: 'alice',
          ),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsNWidgets(2));
      });
    });

    group('when previous image fails to load', () {
      testWidgets('does not crash and shows initials', (tester) async {
        final firstProvider = _SuccessThenFailImageProvider();
        final pendingProvider = _PendingImageProvider();
        final key = UniqueKey();

        await mountWidget(
          WnAvatar(
            key: key,
            imageProvider: firstProvider,
            displayName: 'alice',
          ),
          tester,
        );
        await tester.pumpAndSettle();

        imageCache.clear();

        await mountWidget(
          WnAvatar(
            key: key,
            imageProvider: pendingProvider,
            displayName: 'alice',
          ),
          tester,
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('A'), findsOneWidget);
      });
    });
  });
}
