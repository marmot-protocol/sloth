// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'White Noise';

  @override
  String get tagline1 => 'Децентрализованный. Нецензурируемый.';

  @override
  String get tagline2 => 'Безопасный Мессенджер.';

  @override
  String get login => 'Войти';

  @override
  String get signUp => 'Регистрация';

  @override
  String get loginTitle => 'Вход в White Noise';

  @override
  String get enterPrivateKey => 'Введите ваш приватный ключ';

  @override
  String get nsecPlaceholder => 'nsec...';

  @override
  String get setupProfile => 'Настройка профиля';

  @override
  String get chooseName => 'Выберите имя';

  @override
  String get enterYourName => 'Введите ваше имя';

  @override
  String get introduceYourself => 'Расскажите о себе';

  @override
  String get writeSomethingAboutYourself => 'Напишите что-нибудь о себе';

  @override
  String get cancel => 'Отмена';

  @override
  String get profileReady => 'Ваш профиль готов!';

  @override
  String get startConversationHint =>
      'Начните разговор, добавив друзей или поделившись своим профилем.';

  @override
  String get shareYourProfile => 'Поделиться профилем';

  @override
  String get startChat => 'Начать чат';

  @override
  String get settings => 'Настройки';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get profileKeys => 'Ключи профиля';

  @override
  String get networkRelays => 'Сетевые реле';

  @override
  String get appSettings => 'Настройки приложения';

  @override
  String get donateToWhiteNoise => 'Пожертвовать White Noise';

  @override
  String get developerSettings => 'Настройки разработчика';

  @override
  String get signOut => 'Выйти';

  @override
  String get appSettingsTitle => 'Настройки Приложения';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get profileKeysTitle => 'Ключи профиля';

  @override
  String get publicKey => 'Публичный ключ';

  @override
  String get publicKeyCopied => 'Публичный ключ скопирован в буфер обмена';

  @override
  String get publicKeyDescription =>
      'Ваш публичный ключ (npub) можно делиться с другими. Он используется для вашей идентификации в сети.';

  @override
  String get privateKey => 'Приватный ключ';

  @override
  String get privateKeyCopied => 'Приватный ключ скопирован в буфер обмена';

  @override
  String get privateKeyDescription =>
      'Ваш приватный ключ (nsec) должен оставаться секретным. Любой, кто имеет к нему доступ, может контролировать ваш аккаунт.';

  @override
  String get keepPrivateKeySecure => 'Храните приватный ключ в безопасности';

  @override
  String get privateKeyWarning =>
      'Не делитесь приватным ключом публично и используйте его только для входа в другие приложения Nostr.';

  @override
  String get editProfileTitle => 'Редактировать профиль';

  @override
  String get profileName => 'Имя профиля';

  @override
  String get nostrAddress => 'Адрес Nostr';

  @override
  String get nostrAddressPlaceholder => 'example@whitenoise.chat';

  @override
  String get aboutYou => 'О вас';

  @override
  String get profileIsPublic => 'Профиль публичный';

  @override
  String get profilePublicDescription => 'Информация вашего профиля будет видна всем в сети.';

  @override
  String get discardChanges => 'Отменить изменения';

  @override
  String get save => 'Сохранить';

  @override
  String get profileUpdatedSuccessfully => 'Профиль успешно обновлён';

  @override
  String errorLoadingProfile(String error) {
    return 'Ошибка загрузки профиля: $error';
  }

  @override
  String error(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get profileLoadError => 'Не удалось загрузить профиль. Пожалуйста, попробуйте снова.';

  @override
  String get profileSaveError => 'Не удалось сохранить профиль. Пожалуйста, попробуйте снова.';

  @override
  String get networkRelaysTitle => 'Сетевые Реле';

  @override
  String get myRelays => 'Мои Реле';

  @override
  String get myRelaysHelp =>
      'Реле, которые вы определили для использования во всех ваших приложениях Nostr.';

  @override
  String get inboxRelays => 'Входящие Реле';

  @override
  String get inboxRelaysHelp =>
      'Реле для получения приглашений и начала безопасных разговоров с новыми пользователями.';

  @override
  String get keyPackageRelays => 'Реле Пакетов Ключей';

  @override
  String get keyPackageRelaysHelp =>
      'Реле, которые хранят ваш безопасный ключ, чтобы другие могли приглашать вас в зашифрованные разговоры.';

  @override
  String get errorLoadingRelays => 'Ошибка загрузки реле';

  @override
  String get noRelaysConfigured => 'Реле не настроены';

  @override
  String get donateTitle => 'Пожертвовать White Noise';

  @override
  String get donateDescription =>
      'Как некоммерческая организация, White Noise существует исключительно для вашей конфиденциальности и свободы, а не для прибыли. Ваша поддержка сохраняет нашу независимость и бескомпромиссность.';

  @override
  String get lightningAddress => 'Адрес Lightning';

  @override
  String get bitcoinSilentPayment => 'Тихий Платёж Bitcoin';

  @override
  String get copiedToClipboardThankYou => 'Скопировано в буфер обмена. Спасибо! 🦥';

  @override
  String get shareProfileTitle => 'Поделиться профилем';

  @override
  String get scanToConnect => 'Сканируйте для подключения';

  @override
  String get signOutTitle => 'Выход';

  @override
  String get signOutConfirmation => 'Вы уверены, что хотите выйти?';

  @override
  String get signOutWarning =>
      'Когда вы выходите из White Noise, ваши чаты будут удалены с этого устройства и не могут быть восстановлены на другом устройстве.\n\nЕсли вы не сделали резервную копию приватного ключа, вы не сможете использовать этот профиль в любом другом сервисе Nostr.';

  @override
  String get backUpPrivateKey => 'Сделайте резервную копию приватного ключа';

  @override
  String get copyPrivateKeyHint =>
      'Скопируйте приватный ключ для восстановления аккаунта на другом устройстве.';

  @override
  String get noChatsYet => 'Пока нет чатов';

  @override
  String get startConversation => 'Начните разговор';

  @override
  String get noMessagesYet => 'Пока нет сообщений';

  @override
  String get messagePlaceholder => 'Сообщение';

  @override
  String get failedToSendMessage => 'Не удалось отправить сообщение. Попробуйте снова.';

  @override
  String get invitedToSecureChat => 'Вы приглашены в безопасный чат';

  @override
  String get decline => 'Отклонить';

  @override
  String get accept => 'Принять';

  @override
  String failedToAcceptInvitation(String error) {
    return 'Не удалось принять приглашение: $error';
  }

  @override
  String failedToDeclineInvitation(String error) {
    return 'Не удалось отклонить приглашение: $error';
  }

  @override
  String get startNewChat => 'Новый чат';

  @override
  String get noResults => 'Нет результатов';

  @override
  String get noFollowsYet => 'Пока нет подписок';

  @override
  String get developerSettingsTitle => 'Настройки Разработчика';

  @override
  String get publishNewKeyPackage => 'Опубликовать Новый Пакет Ключей';

  @override
  String get refreshKeyPackages => 'Обновить Пакеты Ключей';

  @override
  String get deleteAllKeyPackages => 'Удалить Все Пакеты Ключей';

  @override
  String keyPackagesCount(int count) {
    return 'Пакеты Ключей ($count)';
  }

  @override
  String get noKeyPackagesFound => 'Пакеты ключей не найдены';

  @override
  String packageNumber(int number) {
    return 'Пакет $number';
  }

  @override
  String get ohNo => 'О нет!';

  @override
  String get goBack => 'Назад';

  @override
  String get reportError => 'Сообщить об ошибке';

  @override
  String get slothsWorking => 'Ленивцы работают';

  @override
  String get wipMessage =>
      'Ленивцы работают над этой функцией. Если хотите, чтобы ленивцы работали быстрее, пожертвуйте White Noise';

  @override
  String get donate => 'Пожертвовать';

  @override
  String get addRelay => 'Добавить Реле';

  @override
  String get enterRelayAddress => 'Введите адрес реле';

  @override
  String get relayAddressPlaceholder => 'wss://relay.example.com';

  @override
  String get removeRelay => 'Удалить Реле?';

  @override
  String get removeRelayConfirmation =>
      'Вы уверены, что хотите удалить это реле? Это действие нельзя отменить.';

  @override
  String get remove => 'Удалить';

  @override
  String get messageActions => 'Действия с сообщением';

  @override
  String get reply => 'Ответить';

  @override
  String get delete => 'Удалить';

  @override
  String get failedToDeleteMessage => 'Не удалось удалить сообщение. Попробуйте снова.';

  @override
  String get failedToSendReaction => 'Не удалось отправить реакцию. Попробуйте снова.';

  @override
  String get unknownUser => 'Неизвестный пользователь';

  @override
  String get unknownGroup => 'Неизвестная группа';

  @override
  String get hasInvitedYouToSecureChat => 'Пригласил вас в безопасный чат';

  @override
  String userInvitedYouToSecureChat(String name) {
    return '$name пригласил вас в безопасный чат';
  }

  @override
  String get youHaveBeenInvitedToSecureChat => 'Вы были приглашены в безопасный чат';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Системный';

  @override
  String get languageUpdateFailed => 'Не удалось сохранить языковые настройки. Попробуйте снова.';

  @override
  String get timeJustNow => 'только что';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минут назад',
      many: '$count минут назад',
      few: '$count минуты назад',
      one: '1 минуту назад',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часов назад',
      many: '$count часов назад',
      few: '$count часа назад',
      one: '1 час назад',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней назад',
      many: '$count дней назад',
      few: '$count дня назад',
      one: 'вчера',
    );
    return '$_temp0';
  }
}
