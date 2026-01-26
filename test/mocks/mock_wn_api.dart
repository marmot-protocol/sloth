import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/src/rust/api.dart' as rust_api;
import 'package:sloth/src/rust/api/chat_list.dart';
import 'package:sloth/src/rust/api/groups.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/api/users.dart';
import 'package:sloth/src/rust/frb_generated.dart';

class MockThemeMode implements rust_api.ThemeMode {
  final String mode;
  const MockThemeMode(this.mode);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class MockLanguage implements rust_api.Language {
  final String code;
  const MockLanguage(this.code);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class MockAppSettings implements rust_api.AppSettings {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class MockWnApi implements RustLibApi {
  String currentThemeMode = 'system';
  String currentLanguage = 'en';
  bool shouldFailUpdateLanguage = false;
  bool shouldFailNpubConversion = false;

  @override
  Future<List<User>> crateApiAccountsAccountFollows({required String pubkey}) async {
    return [];
  }

  @override
  String crateApiUtilsNpubFromHexPubkey({required String hexPubkey}) {
    if (shouldFailNpubConversion) {
      throw Exception('Invalid hex pubkey');
    }
    return 'npub1test${hexPubkey.substring(0, 10)}';
  }

  @override
  Future<List<ChatMessage>> crateApiMessagesFetchAggregatedMessagesForGroup({
    required String pubkey,
    required String groupId,
  }) async {
    return [];
  }

  @override
  Future<bool> crateApiGroupsGroupIsDirectMessageType({
    required Group that,
    required String accountPubkey,
  }) async {
    return false;
  }

  @override
  Future<String?> crateApiGroupsGetGroupImagePath({
    required String accountPubkey,
    required String groupId,
  }) async {
    return null;
  }

  @override
  Stream<MessageStreamItem> crateApiMessagesSubscribeToGroupMessages({
    required String groupId,
  }) {
    return Stream.value(const MessageStreamItem.initialSnapshot(messages: []));
  }

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async {
    return const FlutterMetadata(custom: {});
  }

  @override
  Stream<ChatListStreamItem> crateApiChatListSubscribeToChatList({
    required String accountPubkey,
  }) {
    return Stream.value(const ChatListStreamItem.initialSnapshot(items: []));
  }

  @override
  Future<List<String>> crateApiGroupsGroupMembers({
    required String pubkey,
    required String groupId,
  }) async => [];

  @override
  Future<void> crateApiAccountsLogout({required String pubkey}) async {}

  @override
  Future<String> crateApiUtilsGetDefaultBlossomServerUrl() async => 'https://blossom.example.com';

  @override
  Future<void> crateApiAccountsUpdateAccountMetadata({
    required String pubkey,
    required FlutterMetadata metadata,
  }) async {}

  @override
  rust_api.ThemeMode crateApiUtilsThemeModeLight() => const MockThemeMode('light');

  @override
  rust_api.ThemeMode crateApiUtilsThemeModeDark() => const MockThemeMode('dark');

  @override
  rust_api.ThemeMode crateApiUtilsThemeModeSystem() => const MockThemeMode('system');

  @override
  String crateApiUtilsThemeModeToString({required rust_api.ThemeMode themeMode}) {
    if (themeMode is MockThemeMode) {
      return themeMode.mode;
    }
    return 'system';
  }

  @override
  Future<rust_api.AppSettings> crateApiGetAppSettings() async {
    return MockAppSettings();
  }

  @override
  Future<rust_api.ThemeMode> crateApiAppSettingsThemeMode({
    required rust_api.AppSettings appSettings,
  }) async {
    return MockThemeMode(currentThemeMode);
  }

  @override
  Future<void> crateApiUpdateThemeMode({
    required rust_api.ThemeMode themeMode,
  }) async {
    if (themeMode is MockThemeMode) {
      currentThemeMode = themeMode.mode;
    }
  }

  @override
  rust_api.Language crateApiUtilsLanguageEnglish() => const MockLanguage('en');

  @override
  rust_api.Language crateApiUtilsLanguageSpanish() => const MockLanguage('es');

  @override
  rust_api.Language crateApiUtilsLanguageFrench() => const MockLanguage('fr');

  @override
  rust_api.Language crateApiUtilsLanguageGerman() => const MockLanguage('de');

  @override
  rust_api.Language crateApiUtilsLanguageItalian() => const MockLanguage('it');

  @override
  rust_api.Language crateApiUtilsLanguagePortuguese() => const MockLanguage('pt');

  @override
  rust_api.Language crateApiUtilsLanguageRussian() => const MockLanguage('ru');

  @override
  rust_api.Language crateApiUtilsLanguageTurkish() => const MockLanguage('tr');

  @override
  String crateApiUtilsLanguageToString({required rust_api.Language language}) {
    if (language is MockLanguage) {
      return language.code;
    }
    return 'en';
  }

  @override
  Future<rust_api.Language> crateApiAppSettingsLanguage({
    required rust_api.AppSettings appSettings,
  }) async {
    return MockLanguage(currentLanguage);
  }

  @override
  Future<void> crateApiUpdateLanguage({
    required rust_api.Language language,
  }) async {
    if (shouldFailUpdateLanguage) {
      throw Exception('Failed to update language');
    }
    if (language is MockLanguage) {
      currentLanguage = language.code;
    }
  }

  void reset() {
    currentThemeMode = 'system';
    currentLanguage = 'en';
    shouldFailUpdateLanguage = false;
    shouldFailNpubConversion = false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
