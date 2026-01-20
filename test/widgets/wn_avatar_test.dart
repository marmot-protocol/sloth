import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_animated_pixel_overlay.dart' show WnAnimatedPixelOverlay;
import 'package:sloth/widgets/wn_avatar.dart' show WnAvatar;
import 'package:sloth/widgets/wn_initials_avatar.dart' show WnInitialsAvatar;

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

void main() {
  group('WnAvatar', () {
    group('without pictureUrl', () {
      testWidgets('shows WnInitialsAvatar', (tester) async {
        await mountWidget(const WnAvatar(animated: true), tester);
        expect(find.byType(WnInitialsAvatar), findsOneWidget);
      });

      testWidgets('shows fallback icon when no displayName', (tester) async {
        await mountWidget(const WnAvatar(animated: true), tester);
        expect(find.byKey(const Key('avatar_fallback_icon')), findsOneWidget);
      });
    });

    group('with empty pictureUrl', () {
      testWidgets('shows WnInitialsAvatar', (tester) async {
        await mountWidget(const WnAvatar(pictureUrl: '', animated: true), tester);
        expect(find.byType(WnInitialsAvatar), findsOneWidget);
      });
    });

    group('animated', () {
      testWidgets('shows loading animation while loading', (tester) async {
        await mountWidget(
          WnAvatar(imageProvider: _PendingImageProvider(), animated: true),
          tester,
        );
        expect(find.byType(WnAnimatedPixelOverlay), findsOneWidget);
      });

      testWidgets('shows initials on error', (tester) async {
        await mountWidget(
          WnAvatar(
            imageProvider: _FailingImageProvider(),
            displayName: 'alice bob',
            animated: true,
          ),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.text('AB'), findsOneWidget);
      });

      testWidgets('hides loading animation on error', (tester) async {
        await mountWidget(
          WnAvatar(imageProvider: _FailingImageProvider(), animated: true),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.byType(WnAnimatedPixelOverlay), findsNothing);
      });

      testWidgets('hides loading animation on success', (tester) async {
        await mountWidget(
          WnAvatar(imageProvider: _SuccessImageProvider(), animated: true),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.byType(WnAnimatedPixelOverlay), findsNothing);
      });

      testWidgets('shows image on success', (tester) async {
        await mountWidget(
          WnAvatar(imageProvider: _SuccessImageProvider(), animated: true),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsOneWidget);
      });
    });

    group('static', () {
      testWidgets('shows image', (tester) async {
        await mountWidget(
          WnAvatar(imageProvider: _SuccessImageProvider()),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsOneWidget);
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

        expect(find.text('AB'), findsOneWidget);
      });
    });
  });
}
