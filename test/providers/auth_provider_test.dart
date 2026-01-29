import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/providers/is_adding_account_provider.dart';
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
  Object? getAccountsError;
  List<Account> allAccounts = [];

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
  Future<List<Account>> crateApiAccountsGetAccounts() async {
    if (getAccountsError != null) {
      throw getAccountsError!;
    }
    return allAccounts;
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
    mockApi.getAccountsError = null;
    mockApi.allAccounts = [];
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

      test('resets isAddingAccountProvider to false', () async {
        container.read(isAddingAccountProvider.notifier).set(true);
        expect(container.read(isAddingAccountProvider), true);
        await container.read(authProvider.notifier).login('nsec123');
        expect(container.read(isAddingAccountProvider), false);
      });
    });

    group('signup', () {
      test('returns created pubkey', () async {
        final pubkey = await container.read(authProvider.notifier).signup();
        expect(pubkey, 'created_pubkey');
      });

      test('resets isAddingAccountProvider to false', () async {
        container.read(isAddingAccountProvider.notifier).set(true);
        expect(container.read(isAddingAccountProvider), true);
        await container.read(authProvider.notifier).signup();
        expect(container.read(isAddingAccountProvider), false);
      });
    });

    group('logout', () {
      test('clears state when no other accounts', () async {
        await container.read(authProvider.notifier).login('nsec123');
        await container.read(authProvider.notifier).logout();
        expect(container.read(authProvider).value, isNull);
      });

      test('clears storage when no other accounts', () async {
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

      test('switches to another account when available', () async {
        await container.read(authProvider.notifier).login('nsec123');
        mockApi.existingAccounts.add('other_pubkey');
        mockApi.allAccounts = [
          Account(
            accountType: AccountType.local,
            pubkey: 'other_pubkey',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final nextPubkey = await container.read(authProvider.notifier).logout();
        expect(nextPubkey, 'other_pubkey');
        expect(container.read(authProvider).value, 'other_pubkey');
        expect(await mockStorage.read(key: 'active_account_pubkey'), 'other_pubkey');
      });

      test('filters out logged-out account when switching', () async {
        await container.read(authProvider.notifier).login('nsec123');
        mockApi.existingAccounts.add('other_pubkey');
        mockApi.allAccounts = [
          Account(
            accountType: AccountType.local,
            pubkey: 'logged_in_pubkey',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Account(
            accountType: AccountType.local,
            pubkey: 'other_pubkey',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final nextPubkey = await container.read(authProvider.notifier).logout();
        expect(nextPubkey, 'other_pubkey');
        expect(container.read(authProvider).value, 'other_pubkey');
      });

      test('returns null when no other accounts', () async {
        await container.read(authProvider.notifier).login('nsec123');
        final nextPubkey = await container.read(authProvider.notifier).logout();
        expect(nextPubkey, isNull);
      });

      test('returns null when getAccounts fails', () async {
        await container.read(authProvider.notifier).login('nsec123');
        mockApi.getAccountsError = Exception('Network error');
        final nextPubkey = await container.read(authProvider.notifier).logout();
        expect(nextPubkey, isNull);
        expect(container.read(authProvider).value, isNull);
      });
    });

    group('switchProfile', () {
      test('updates state to new pubkey', () async {
        await container.read(authProvider.notifier).login('nsec123');
        mockApi.existingAccounts.add('new_pubkey');
        await container.read(authProvider.notifier).switchProfile('new_pubkey');
        expect(container.read(authProvider).value, 'new_pubkey');
      });

      test('updates storage with new pubkey', () async {
        await container.read(authProvider.notifier).login('nsec123');
        mockApi.existingAccounts.add('new_pubkey');
        await container.read(authProvider.notifier).switchProfile('new_pubkey');
        expect(await mockStorage.read(key: 'active_account_pubkey'), 'new_pubkey');
      });

      test('clears state when account not found', () async {
        await container.read(authProvider.notifier).login('nsec123');
        await container.read(authProvider.notifier).switchProfile('nonexistent');
        expect(container.read(authProvider).value, isNull);
        expect(await mockStorage.read(key: 'active_account_pubkey'), isNull);
      });
    });
  });
}
