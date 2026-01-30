import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/theme/semantic_colors.dart';
import 'package:sloth/widgets/wn_avatar.dart';

import '../mocks/mock_clipboard.dart' show mockClipboard;
import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockApi extends MockWnApi {
  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async => const FlutterMetadata(
    name: 'Test User',
    displayName: 'Test Display Name',
    picture: 'https://example.com/picture.jpg',
    custom: {},
  );
}

late _MockApi _mockApi;

class _MockAuthNotifier extends AuthNotifier {
  _MockAuthNotifier([this._pubkey = testPubkeyA]);

  final String _pubkey;

  @override
  Future<String?> build() async {
    state = AsyncData(_pubkey);
    return _pubkey;
  }
}

void main() {
  setUpAll(() {
    _mockApi = _MockApi();
    RustLib.initMock(api: _mockApi);
  });

  setUp(() {
    _mockApi.reset();
  });

  Future<void> pumpShareProfileScreen(WidgetTester tester) async {
    await mountTestApp(
      tester,
      overrides: [
        authProvider.overrideWith(() => _MockAuthNotifier()),
        secureStorageProvider.overrideWithValue(MockSecureStorage()),
      ],
    );
    Routes.pushToShareProfile(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('ShareProfileScreen', () {
    testWidgets('displays Share profile title', (tester) async {
      await pumpShareProfileScreen(tester);
      expect(find.text('Share profile'), findsOneWidget);
    });

    testWidgets('displays user display name', (tester) async {
      await pumpShareProfileScreen(tester);
      expect(find.text('Test Display Name'), findsOneWidget);
    });

    testWidgets('displays Scan to connect text', (tester) async {
      await pumpShareProfileScreen(tester);
      expect(find.text('Scan to connect'), findsOneWidget);
    });

    testWidgets('displays QR code', (tester) async {
      await pumpShareProfileScreen(tester);
      await tester.pumpAndSettle();
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('tapping close icon returns to previous screen', (tester) async {
      await pumpShareProfileScreen(tester);
      await tester.tap(find.byKey(const Key('slate_close_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('tapping copy button copies npub to clipboard', (tester) async {
      final getClipboard = mockClipboard();
      await pumpShareProfileScreen(tester);
      await tester.pumpAndSettle();
      final copyButton = find.byKey(const Key('copy_button'));
      expect(copyButton, findsOneWidget);
      await tester.tap(copyButton);
      await tester.pump();
      expect(getClipboard(), startsWith('npub1'));
    });

    testWidgets('shows success message when copying public key', (tester) async {
      await pumpShareProfileScreen(tester);
      await tester.pumpAndSettle();
      final copyButton = find.byKey(const Key('copy_button'));
      await tester.tap(copyButton);
      await tester.pump();
      expect(find.text('Public key copied to clipboard'), findsOneWidget);
    });

    testWidgets('disables copy button when npub conversion fails', (tester) async {
      _mockApi.shouldFailNpubConversion = true;
      await pumpShareProfileScreen(tester);
      await tester.pumpAndSettle();

      final copyButton = find.byKey(const Key('copy_button'));
      expect(copyButton, findsOneWidget);

      final iconButton = tester.widget<IconButton>(copyButton);
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('passes color derived from pubkey to avatar', (tester) async {
      await pumpShareProfileScreen(tester);

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.color, AccentColor.violet);
    });

    testWidgets('different pubkey passes different avatar color', (tester) async {
      await mountTestApp(
        tester,
        overrides: [
          authProvider.overrideWith(() => _MockAuthNotifier(testPubkeyD)),
          secureStorageProvider.overrideWithValue(MockSecureStorage()),
        ],
      );
      Routes.pushToShareProfile(tester.element(find.byType(Scaffold)));
      await tester.pumpAndSettle();

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.color, AccentColor.cyan);
    });
  });
}
