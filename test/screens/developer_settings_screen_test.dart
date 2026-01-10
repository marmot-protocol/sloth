import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/developer_settings_screen.dart';
import 'package:sloth/src/rust/api/accounts.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockApi extends MockWnApi {
  List<FlutterEvent> keyPackages = [];
  String? deletedKeyPackageId;
  bool shouldThrowOnFetch = false;

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async => const FlutterMetadata(name: 'Test', custom: {});

  @override
  Future<List<FlutterEvent>> crateApiAccountsAccountKeyPackages({
    required String accountPubkey,
  }) async {
    if (shouldThrowOnFetch) throw Exception('Network error');
    return keyPackages;
  }

  @override
  Future<void> crateApiAccountsPublishAccountKeyPackage({
    required String accountPubkey,
  }) async {}

  @override
  Future<bool> crateApiAccountsDeleteAccountKeyPackage({
    required String accountPubkey,
    required String keyPackageId,
  }) async {
    deletedKeyPackageId = keyPackageId;
    return true;
  }

  @override
  Future<BigInt> crateApiAccountsDeleteAccountKeyPackages({
    required String accountPubkey,
  }) async => BigInt.from(keyPackages.length);
}

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async {
    state = const AsyncData('test_pubkey');
    return 'test_pubkey';
  }
}

void main() {
  late _MockApi mockApi;

  setUpAll(() {
    mockApi = _MockApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.keyPackages = [];
    mockApi.deletedKeyPackageId = null;
    mockApi.shouldThrowOnFetch = false;
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await mountTestApp(
      tester,
      overrides: [
        authProvider.overrideWith(() => _MockAuthNotifier()),
        secureStorageProvider.overrideWithValue(MockSecureStorage()),
      ],
    );
    Routes.pushToDeveloperSettings(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('DeveloperSettingsScreen', () {
    testWidgets('displays Developer Settings title', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Developer Settings'), findsOneWidget);
    });

    testWidgets('displays action buttons', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Publish New Key Package'), findsOneWidget);
      expect(find.text('Refresh Key Packages'), findsOneWidget);
      expect(find.text('Delete All Key Packages'), findsOneWidget);
    });

    testWidgets('displays key packages count', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Key Packages (0)'), findsOneWidget);
    });

    testWidgets('displays empty state when no packages', (tester) async {
      await pumpScreen(tester);
      expect(find.text('No key packages found'), findsOneWidget);
    });

    testWidgets('displays key packages when available', (tester) async {
      mockApi.keyPackages = [
        FlutterEvent(
          id: 'pkg1',
          pubkey: 'test',
          createdAt: DateTime.now(),
          kind: 443,
          tags: [],
          content: '',
        ),
      ];

      await pumpScreen(tester);
      expect(find.text('Package 1'), findsOneWidget);
    });

    testWidgets('tapping close icon returns to previous screen', (tester) async {
      await pumpScreen(tester);
      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();
      expect(find.byType(DeveloperSettingsScreen), findsNothing);
    });

    testWidgets('tapping delete icon calls delete with package id', (tester) async {
      mockApi.keyPackages = [
        FlutterEvent(
          id: 'pkg_to_delete',
          pubkey: 'test',
          createdAt: DateTime.now(),
          kind: 443,
          tags: [],
          content: '',
        ),
      ];

      await pumpScreen(tester);
      await tester.tap(find.byKey(const Key('delete_key_package_pkg_to_delete')));
      await tester.pump();
      expect(mockApi.deletedKeyPackageId, 'pkg_to_delete');
    });

    testWidgets('displays user-friendly error message on fetch failure', (tester) async {
      mockApi.shouldThrowOnFetch = true;

      await pumpScreen(tester);

      expect(find.text('Failed to fetch key packages'), findsOneWidget);
    });
  });
}
