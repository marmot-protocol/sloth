import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/src/rust/api/accounts.dart';
import 'package:sloth/src/rust/api/error.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';

class _MockRustLibApi implements RustLibApi {
  var metadataCompleter = Completer<FlutterMetadata>();
  String? metadataCalledWithPubkey;
  String? logoutCalledWithPubkey;
  final Set<String> existingAccounts = {};
  Object? getAccountError;

  @override
  Future<Account> crateApiAccountsGetAccount({required String pubkey}) async {
    if (getAccountError != null) {
      throw getAccountError!;
    }
    if (!existingAccounts.contains(pubkey)) {
      throw const ApiError.whitenoise(message: 'Account not found');
    }
    return Account(
      pubkey: pubkey,
      accountType: AccountType.local,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<Account> crateApiAccountsCreateIdentity() async {
    existingAccounts.add('created_pubkey');
    return Account(
      pubkey: 'created_pubkey',
      accountType: AccountType.local,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<Account> crateApiAccountsLogin({required String nsecOrHexPrivkey}) async {
    existingAccounts.add('logged_in_pubkey');
    return Account(
      pubkey: 'logged_in_pubkey',
      accountType: AccountType.local,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> crateApiAccountsLogout({required String pubkey}) async {
    logoutCalledWithPubkey = pubkey;
  }

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) {
    metadataCalledWithPubkey = pubkey;
    return metadataCompleter.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late ProviderContainer container;
  late _MockRustLibApi mockApi;
  late MockSecureStorage mockStorage;

  setUpAll(() {
    mockApi = _MockRustLibApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.metadataCompleter = Completer<FlutterMetadata>();
    mockApi.metadataCalledWithPubkey = null;
    mockApi.logoutCalledWithPubkey = null;
    mockApi.existingAccounts.clear();
    mockApi.getAccountError = null;
    mockStorage = MockSecureStorage();
    container = ProviderContainer(
      overrides: [secureStorageProvider.overrideWithValue(mockStorage)],
    );
  });

  tearDown(() => container.dispose());

  group('AuthNotifier', () {
    group('build', () {
      group('when secure storage has no pubkey', () {
        test('returns null', () async {
          await container.read(authProvider.future);
          expect(container.read(authProvider).value, isNull);
        });
      });

      group('when pubkey is only in secure storage', () {
        setUp(() async {
          mockApi.existingAccounts.clear();
          await mockStorage.write(key: 'active_account_pubkey', value: 'stale_pubkey');
        });
        test('returns null', () async {
          final pubkey = await container.read(authProvider.future);
          expect(pubkey, isNull);
          expect(await mockStorage.read(key: 'active_account_pubkey'), isNull);
        });

        test('clears secure storage', () async {
          await container.read(authProvider.future);
          expect(await mockStorage.read(key: 'active_account_pubkey'), isNull);
        });
      });

      group('when getAccount fails with unexpected error', () {
        setUp(() async {
          mockApi.getAccountError = const ApiError.whitenoise(message: 'Network error');
          await mockStorage.write(key: 'active_account_pubkey', value: 'stored_pubkey');
        });

        test('returns stored pubkey', () async {
          final pubkey = await container.read(authProvider.future);
          expect(pubkey, 'stored_pubkey');
        });

        test('does not clear secure storage', () async {
          await container.read(authProvider.future);
          expect(await mockStorage.read(key: 'active_account_pubkey'), 'stored_pubkey');
        });
      });

      group('when pubkey is in secure storage and rust crate db', () {
        setUp(() async {
          mockApi.existingAccounts.add('stored_pubkey');
          await mockStorage.write(key: 'active_account_pubkey', value: 'stored_pubkey');
        });
        test('returns expected pubkey', () async {
          final pubkey = await container.read(authProvider.future);
          expect(pubkey, 'stored_pubkey');
        });

        test('does not clear secure storage', () async {
          await container.read(authProvider.future);
          expect(await mockStorage.read(key: 'active_account_pubkey'), 'stored_pubkey');
        });
      });
    });

    group('login', () {
      test('sets state to pubkey', () async {
        await container.read(authProvider.notifier).login('nsec123');
        expect(container.read(authProvider).value, 'logged_in_pubkey');
      });

      test('fetches account metadata without awaiting', () async {
        await container.read(authProvider.notifier).login('nsec123');
        expect(mockApi.metadataCalledWithPubkey, 'logged_in_pubkey');
        expect(mockApi.metadataCompleter.isCompleted, isFalse);
      });
    });

    group('signup', () {
      test('returns created pubkey', () async {
        final pubkey = await container.read(authProvider.notifier).signup();
        expect(pubkey, 'created_pubkey');
      });
    });

    group('logout', () {
      test('clears state', () async {
        await container.read(authProvider.notifier).login('nsec123');
        await container.read(authProvider.notifier).logout();
        expect(container.read(authProvider).value, isNull);
      });

      test('clears storage', () async {
        await container.read(authProvider.notifier).login('nsec123');
        await container.read(authProvider.notifier).logout();
        expect(await mockStorage.read(key: 'active_account_pubkey'), isNull);
      });

      test('calls Rust API logout', () async {
        await container.read(authProvider.notifier).login('nsec123');
        await container.read(authProvider.notifier).logout();
        expect(mockApi.logoutCalledWithPubkey, 'logged_in_pubkey');
      });

      test('does nothing when not authenticated', () async {
        await container.read(authProvider.future);
        await container.read(authProvider.notifier).logout();
        expect(mockApi.logoutCalledWithPubkey, isNull);
        expect(container.read(authProvider).value, isNull);
      });
    });
  });
}
