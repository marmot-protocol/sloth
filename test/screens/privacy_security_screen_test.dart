import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/delete_all_data_confirmation_screen.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async {
    state = const AsyncData('test_pubkey');
    return 'test_pubkey';
  }
}

void main() {
  late MockWnApi mockApi;
  late MockSecureStorage mockStorage;

  setUpAll(() {
    mockApi = MockWnApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.reset();
    mockStorage = MockSecureStorage();
  });

  Future<void> pumpPrivacySecurityScreen(WidgetTester tester) async {
    await mountTestApp(
      tester,
      overrides: [
        authProvider.overrideWith(() => _MockAuthNotifier()),
        secureStorageProvider.overrideWithValue(mockStorage),
      ],
    );
    Routes.pushToPrivacySecurity(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('PrivacySecurityScreen', () {
    testWidgets('displays Privacy & Security title', (tester) async {
      await pumpPrivacySecurityScreen(tester);
      expect(find.text('Privacy & Security'), findsOneWidget);
    });

    testWidgets('displays Delete all app data section', (tester) async {
      await pumpPrivacySecurityScreen(tester);
      expect(find.text('Delete all app data'), findsOneWidget);
      expect(find.text('Delete app data'), findsOneWidget);
      expect(
        find.text('Erase every profile, key, chat, and local file from this device.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping close icon returns to previous screen', (tester) async {
      await pumpPrivacySecurityScreen(tester);
      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('tapping delete button navigates to confirmation screen', (tester) async {
      await pumpPrivacySecurityScreen(tester);

      await tester.tap(find.byKey(const Key('delete_app_data_button')));
      await tester.pumpAndSettle();

      expect(find.byType(DeleteAllDataConfirmationScreen), findsOneWidget);
    });
  });

  group('DeleteAllDataConfirmationScreen', () {
    Future<void> pumpConfirmationScreen(WidgetTester tester) async {
      await mountTestApp(
        tester,
        overrides: [
          authProvider.overrideWith(() => _MockAuthNotifier()),
          secureStorageProvider.overrideWithValue(mockStorage),
        ],
      );
      Routes.pushToDeleteAllDataConfirmation(tester.element(find.byType(Scaffold)));
      await tester.pumpAndSettle();
    }

    testWidgets('displays confirmation title', (tester) async {
      await pumpConfirmationScreen(tester);
      expect(find.text('Delete all app data?'), findsOneWidget);
    });

    testWidgets('displays warning message', (tester) async {
      await pumpConfirmationScreen(tester);
      expect(
        find.text(
          'This will erase every profile, key, chat, and local file from this device. This cannot be undone.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays Cancel and Delete app data buttons', (tester) async {
      await pumpConfirmationScreen(tester);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete app data'), findsOneWidget);
    });

    testWidgets('tapping Cancel returns to previous screen', (tester) async {
      await pumpPrivacySecurityScreen(tester);
      await tester.tap(find.byKey(const Key('delete_app_data_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cancel_button')));
      await tester.pumpAndSettle();

      expect(find.text('Privacy & Security'), findsOneWidget);
    });

    testWidgets('confirming delete calls rust API and clears storage', (tester) async {
      await pumpConfirmationScreen(tester);

      await tester.tap(find.byKey(const Key('confirm_delete_button')));
      await tester.pumpAndSettle();

      expect(mockStorage.deleteAllCalled, isTrue);
    });

    testWidgets('shows error snackbar when delete fails', (tester) async {
      mockApi.shouldFailDeleteAllData = true;
      await pumpConfirmationScreen(tester);

      await tester.tap(find.byKey(const Key('confirm_delete_button')));
      await tester.pumpAndSettle();

      expect(find.text('Failed to delete app data. Please try again.'), findsOneWidget);
    });
  });
}
