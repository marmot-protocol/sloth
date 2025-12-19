import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_animated_avatar.dart' show WnAnimatedAvatar;
import 'package:sloth/widgets/wn_animated_pixel_overlay.dart' show WnAnimatedPixelOverlay;
import 'package:sloth/widgets/wn_initials_avatar.dart' show WnInitialsAvatar;
import '../test_helpers.dart' show mountWidget;

class _MockFailingHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    throw const SocketException('Simulated network error');
  }
}

void main() {
  group('WnAnimatedAvatar', () {
    group('without pictureUrl', () {
      testWidgets('shows WnInitialsAvatar', (tester) async {
        await mountWidget(const WnAnimatedAvatar(), tester);
        expect(find.byType(WnInitialsAvatar), findsOneWidget);
      });
    });

    group('with empty pictureUrl', () {
      testWidgets('shows WnInitialsAvatar', (tester) async {
        await mountWidget(const WnAnimatedAvatar(pictureUrl: ''), tester);
        expect(find.byType(WnInitialsAvatar), findsOneWidget);
      });
    });

    group('with pictureUrl', () {
      testWidgets('shows loading animation', (tester) async {
        await mountWidget(
          const WnAnimatedAvatar(pictureUrl: 'https://example.com/image.jpg'),
          tester,
        );
        expect(find.byType(WnAnimatedPixelOverlay), findsOneWidget);
      });

      testWidgets('shows initials on error', (tester) async {
        await HttpOverrides.runZoned(
          () async {
            await mountWidget(
              const WnAnimatedAvatar(
                pictureUrl: 'https://example.com/image.jpg',
                displayName: 'alice bob',
              ),
              tester,
            );
            await tester.pumpAndSettle();

            expect(find.text('AB'), findsOneWidget);
          },
          createHttpClient: (_) => _MockFailingHttpClient(),
        );
      });

      testWidgets('hides loading animation on error', (tester) async {
        await HttpOverrides.runZoned(
          () async {
            await mountWidget(
              const WnAnimatedAvatar(
                pictureUrl: 'https://example.com/image.jpg',
              ),
              tester,
            );
            await tester.pumpAndSettle();

            expect(find.byType(WnAnimatedPixelOverlay), findsNothing);
          },
          createHttpClient: (_) => _MockFailingHttpClient(),
        );
      });
    });
  });
}
