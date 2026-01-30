import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_text_form_field.dart';

import '../mocks/mock_clipboard.dart' show mockClipboard;
import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockApi extends MockWnApi {
  @override
  Future<String> crateApiAccountsExportAccountNsec({required String pubkey}) async {
    return 'nsec1test${pubkey.substring(0, 10)}';
  }
}

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async {
    state = const AsyncData('test_pubkey');
    return 'test_pubkey';
  }
}

void main() {
  setUpAll(() => RustLib.initMock(api: _MockApi()));

  Future<void> pumpProfileKeysScreen(WidgetTester tester) async {
    await mountTestApp(
      tester,
      overrides: [
        authProvider.overrideWith(() => _MockAuthNotifier()),
        secureStorageProvider.overrideWithValue(MockSecureStorage()),
      ],
    );
    Routes.pushToProfileKeys(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('ProfileKeysScreen', () {
    testWidgets('displays Profile keys title', (tester) async {
      await pumpProfileKeysScreen(tester);
      expect(find.text('Profile keys'), findsOneWidget);
    });

    testWidgets('displays public key label', (tester) async {
      await pumpProfileKeysScreen(tester);
      expect(find.text('Public key'), findsOneWidget);
    });

    testWidgets('displays private key label', (tester) async {
      await pumpProfileKeysScreen(tester);
      expect(find.text('Private key'), findsOneWidget);
    });

    testWidgets('displays public key description', (tester) async {
      await pumpProfileKeysScreen(tester);
      expect(
        find.text(
          'Your public key (npub) can be shared with others. It\'s used to identify you on the network.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays private key description', (tester) async {
      await pumpProfileKeysScreen(tester);
      expect(
        find.text(
          'Your private key (nsec) should be kept secret. Anyone with access to it can control your account.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays warning box', (tester) async {
      await pumpProfileKeysScreen(tester);
      expect(find.text('Keep your private key secure'), findsOneWidget);
    });

    testWidgets('tapping close icon returns to previous screen', (tester) async {
      await pumpProfileKeysScreen(tester);
      await tester.tap(find.byKey(const Key('slate_close_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('loads and displays npub in public key field', (tester) async {
      await pumpProfileKeysScreen(tester);
      await tester.pumpAndSettle();
      final publicKeyFields = find.byType(WnTextFormField);
      expect(publicKeyFields, findsNWidgets(2));
      final publicKeyField = publicKeyFields.first;
      final textField = find.descendant(
        of: publicKeyField,
        matching: find.byType(TextFormField),
      );
      expect(textField, findsOneWidget);
      final fieldText = tester.widget<TextFormField>(textField).controller?.text ?? '';
      expect(fieldText, startsWith('npub1'));
    });

    testWidgets('loads and displays nsec in private key field', (tester) async {
      await pumpProfileKeysScreen(tester);
      await tester.pumpAndSettle();
      final privateKeyFields = find.byType(WnTextFormField);
      expect(privateKeyFields, findsNWidgets(2));
      final privateKeyField = privateKeyFields.last;
      final textField = find.descendant(
        of: privateKeyField,
        matching: find.byType(TextFormField),
      );
      expect(textField, findsOneWidget);
      final fieldText = tester.widget<TextFormField>(textField).controller?.text ?? '';
      expect(fieldText, startsWith('nsec1'));
    });

    testWidgets('tapping copy button on public key copies to clipboard', (tester) async {
      final getClipboard = mockClipboard();
      await pumpProfileKeysScreen(tester);
      await tester.pumpAndSettle();
      final copyButtons = find.byKey(const Key('copy_button'));
      expect(copyButtons, findsNWidgets(2));
      await tester.tap(copyButtons.first);
      await tester.pump();
      expect(getClipboard(), startsWith('npub1'));
    });

    testWidgets('tapping copy button on private key copies to clipboard', (tester) async {
      final getClipboard = mockClipboard();
      await pumpProfileKeysScreen(tester);
      await tester.pumpAndSettle();
      final copyButtons = find.byKey(const Key('copy_button'));
      expect(copyButtons, findsNWidgets(2));
      await tester.tap(copyButtons.last);
      await tester.pump();
      expect(getClipboard(), startsWith('nsec1'));
    });

    testWidgets('shows success message when copying public key', (tester) async {
      await pumpProfileKeysScreen(tester);
      await tester.pumpAndSettle();
      final copyButtons = find.byKey(const Key('copy_button'));
      await tester.tap(copyButtons.first);
      await tester.pump();
      expect(find.text('Public key copied to clipboard'), findsOneWidget);
    });

    testWidgets('shows success message when copying private key', (tester) async {
      await pumpProfileKeysScreen(tester);
      await tester.pumpAndSettle();
      final copyButtons = find.byKey(const Key('copy_button'));
      await tester.tap(copyButtons.last);
      await tester.pump();
      expect(find.text('Private key copied to clipboard'), findsOneWidget);
    });

    testWidgets('private key remains in field after copying', (tester) async {
      await pumpProfileKeysScreen(tester);
      await tester.pumpAndSettle();
      final privateKeyFields = find.byType(WnTextFormField);
      final privateKeyField = privateKeyFields.last;
      final textField = find.descendant(
        of: privateKeyField,
        matching: find.byType(TextFormField),
      );
      final controllerBefore = tester.widget<TextFormField>(textField).controller;
      expect(controllerBefore?.text, startsWith('nsec1'));

      final copyButtons = find.byKey(const Key('copy_button'));
      await tester.tap(copyButtons.last);
      await tester.pump();

      final controllerAfter = tester.widget<TextFormField>(textField).controller;
      expect(controllerAfter?.text, startsWith('nsec1'));
    });

    testWidgets('tapping visibility toggle shows/hides private key', (tester) async {
      await pumpProfileKeysScreen(tester);
      await tester.pumpAndSettle();
      final visibilityToggle = find.byKey(const Key('visibility_toggle'));
      expect(visibilityToggle, findsOneWidget);

      final visibilityIcon = find.descendant(
        of: visibilityToggle,
        matching: find.byType(WnIcon),
      );
      expect(tester.widget<WnIcon>(visibilityIcon).icon, WnIcons.view);

      await tester.tap(visibilityToggle);
      await tester.pump();

      expect(tester.widget<WnIcon>(visibilityIcon).icon, WnIcons.viewOff);

      await tester.tap(visibilityToggle);
      await tester.pump();

      expect(tester.widget<WnIcon>(visibilityIcon).icon, WnIcons.view);
    });
  });
}
