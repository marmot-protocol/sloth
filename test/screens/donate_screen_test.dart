import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import '../mocks/mock_clipboard.dart';

class _MockRustLibApi implements RustLibApi {
  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async {
    return const FlutterMetadata(
      name: 'Test User',
      displayName: 'Test Display Name',
      about: 'Test bio',
      custom: {},
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _AuthenticatedAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async => 'test_pubkey';
}

void main() {
  setUpAll(() => RustLib.initMock(api: _MockRustLibApi()));
  Future<void> pumpDonateScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _AuthenticatedAuthNotifier()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, _) => Consumer(
            builder: (context, ref, _) {
              return MaterialApp.router(routerConfig: Routes.build(ref));
            },
          ),
        ),
      ),
    );

    Routes.pushToDonate(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('DonateScreen', () {
    testWidgets('tapping close icon returns to previous screen', (tester) async {
      await pumpDonateScreen(tester);
      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();

      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('shows lightning address', (tester) async {
      await pumpDonateScreen(tester);

      expect(find.text('whitenoise@npub.cash'), findsOneWidget);
    });

    testWidgets('shows bitcoin address', (tester) async {
      await pumpDonateScreen(tester);

      expect(
        find.textContaining('sp1qqvp56mxcj9pz9xudvlch5g4ah5hrc8rj6neu25p'),
        findsOneWidget,
      );
    });

    group('when copying lightning address', () {
      testWidgets('shows feedback message', (tester) async {
        await pumpDonateScreen(tester);
        await tester.tap(find.text('whitenoise@npub.cash'));
        await tester.pump();

        expect(find.text('Copied to clipboard. Thank you! 🦥'), findsOneWidget);
      });

      testWidgets('saves lightning address to clipboard', (tester) async {
        final getClipboard = mockClipboard();
        await pumpDonateScreen(tester);
        await tester.tap(find.text('whitenoise@npub.cash'));
        await tester.pump();

        expect(getClipboard(), 'whitenoise@npub.cash');
      });
    });

    group('when copying bitcoin address', () {
      testWidgets('shows feedback message', (tester) async {
        await pumpDonateScreen(tester);
        await tester.tap(
          find.textContaining('sp1qqvp56mxcj9pz9xudvlch5g4ah5hrc8rj6neu25p'),
        );
        await tester.pump();

        expect(find.text('Copied to clipboard. Thank you! 🦥'), findsOneWidget);
      });

      testWidgets('saves bitcoin address to clipboard', (tester) async {
        final getClipboard = mockClipboard();
        await pumpDonateScreen(tester);
        await tester.tap(
          find.textContaining('sp1qqvp56mxcj9pz9xudvlch5g4ah5hrc8rj6neu25p'),
        );
        await tester.pump();

        expect(
          getClipboard(),
          'sp1qqvp56mxcj9pz9xudvlch5g4ah5hrc8rj6neu25p34rc9gxhp38cwqqlmld28u57w2srgckr34dkyg3q02phu8tm05cyj483q026xedp0s5f5j40p',
        );
      });
    });
  });
}
