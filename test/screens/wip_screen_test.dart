import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/donate_screen.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockApi extends MockWnApi {
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
}

class _AuthenticatedAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async => 'test_pubkey';
}

void main() {
  setUpAll(() => RustLib.initMock(api: _MockApi()));
  Future<void> pumpWipScreen(WidgetTester tester) async {
    await mountTestApp(
      tester,
      overrides: [authProvider.overrideWith(() => _AuthenticatedAuthNotifier())],
    );

    Routes.pushToWip(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('WipScreen', () {
    testWidgets('tapping close icon returns to previous screen', (tester) async {
      await pumpWipScreen(tester);
      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('tapping Go back returns to previous screen', (tester) async {
      await pumpWipScreen(tester);
      await tester.tap(find.text('Go back'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('tapping Donate navigates to DonateScreen', (tester) async {
      await pumpWipScreen(tester);
      await tester.tap(find.text('Donate'));
      await tester.pumpAndSettle();
      expect(find.byType(DonateScreen), findsOneWidget);
    });
  });
}
