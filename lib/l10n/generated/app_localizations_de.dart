// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'White Noise';

  @override
  String get tagline1 => 'Dezentralisiert. Unzensierbar.';

  @override
  String get tagline2 => 'Sichere Nachrichten.';

  @override
  String get login => 'Anmelden';

  @override
  String get signUp => 'Registrieren';

  @override
  String get loginTitle => 'Anmelden';

  @override
  String get enterPrivateKey => 'Privaten Schlüssel eingeben';

  @override
  String get nsecPlaceholder => 'nsec...';

  @override
  String get setupProfile => 'Profil einrichten';

  @override
  String get chooseName => 'Namen wählen';

  @override
  String get enterYourName => 'Namen eingeben';

  @override
  String get introduceYourself => 'Stell dich vor';

  @override
  String get writeSomethingAboutYourself => 'Schreib etwas über dich';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get profileReady => 'Dein Profil ist bereit!';

  @override
  String get startConversationHint =>
      'Starte ein Gespräch, indem du Freunde hinzufügst oder dein Profil teilst.';

  @override
  String get shareYourProfile => 'Profil teilen';

  @override
  String get startChat => 'Chat starten';

  @override
  String get settings => 'Einstellungen';

  @override
  String get shareAndConnect => 'Teilen & verbinden';

  @override
  String get switchProfile => 'Profil wechseln';

  @override
  String get addNewProfile => 'Neues Profil hinzufügen';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get profileKeys => 'Profilschlüssel';

  @override
  String get networkRelays => 'Netzwerk-Relays';

  @override
  String get appSettings => 'App-Einstellungen';

  @override
  String get donateToWhiteNoise => 'An White Noise spenden';

  @override
  String get developerSettings => 'Entwicklereinstellungen';

  @override
  String get signOut => 'Abmelden';

  @override
  String get appSettingsTitle => 'App-Einstellungen';

  @override
  String get theme => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get profileKeysTitle => 'Profilschlüssel';

  @override
  String get publicKey => 'Öffentlicher Schlüssel';

  @override
  String get publicKeyCopied => 'Öffentlicher Schlüssel in Zwischenablage kopiert';

  @override
  String get publicKeyDescription =>
      'Dein öffentlicher Schlüssel (npub) kann mit anderen geteilt werden. Er wird verwendet, um dich im Netzwerk zu identifizieren.';

  @override
  String get privateKey => 'Privater Schlüssel';

  @override
  String get privateKeyCopied => 'Privater Schlüssel in Zwischenablage kopiert';

  @override
  String get privateKeyDescription =>
      'Dein privater Schlüssel (nsec) sollte geheim gehalten werden. Jeder mit Zugriff darauf kann dein Konto kontrollieren.';

  @override
  String get keepPrivateKeySecure => 'Halte deinen privaten Schlüssel sicher';

  @override
  String get privateKeyWarning =>
      'Teile deinen privaten Schlüssel nicht öffentlich und verwende ihn nur zum Anmelden bei anderen Nostr-Apps.';

  @override
  String get editProfileTitle => 'Profil bearbeiten';

  @override
  String get profileName => 'Profilname';

  @override
  String get nostrAddress => 'Nostr-Adresse';

  @override
  String get nostrAddressPlaceholder => 'beispiel@whitenoise.chat';

  @override
  String get aboutYou => 'Über dich';

  @override
  String get profileIsPublic => 'Profil ist öffentlich';

  @override
  String get profilePublicDescription =>
      'Deine Profilinformationen sind für alle im Netzwerk sichtbar.';

  @override
  String get discard => 'Verwerfen';

  @override
  String get discardChanges => 'Änderungen verwerfen';

  @override
  String get save => 'Speichern';

  @override
  String get profileUpdatedSuccessfully => 'Profil erfolgreich aktualisiert';

  @override
  String errorLoadingProfile(String error) {
    return 'Fehler beim Laden des Profils: $error';
  }

  @override
  String error(String error) {
    return 'Fehler: $error';
  }

  @override
  String get profileLoadError =>
      'Profil konnte nicht geladen werden. Bitte versuchen Sie es erneut.';

  @override
  String get profileSaveError =>
      'Profil konnte nicht gespeichert werden. Bitte versuchen Sie es erneut.';

  @override
  String get networkRelaysTitle => 'Netzwerk-Relays';

  @override
  String get myRelays => 'Meine Relays';

  @override
  String get myRelaysHelp => 'Relays, die du für alle deine Nostr-Anwendungen definiert hast.';

  @override
  String get inboxRelays => 'Posteingang-Relays';

  @override
  String get inboxRelaysHelp =>
      'Relays zum Empfangen von Einladungen und zum Starten sicherer Gespräche mit neuen Benutzern.';

  @override
  String get keyPackageRelays => 'Schlüsselpaket-Relays';

  @override
  String get keyPackageRelaysHelp =>
      'Relays, die deinen sicheren Schlüssel speichern, damit andere dich zu verschlüsselten Gesprächen einladen können.';

  @override
  String get errorLoadingRelays => 'Fehler beim Laden der Relays';

  @override
  String get noRelaysConfigured => 'Keine Relays konfiguriert';

  @override
  String get donateTitle => 'An White Noise spenden';

  @override
  String get donateDescription =>
      'Als gemeinnützige Organisation existiert White Noise ausschließlich für deine Privatsphäre und Freiheit, nicht für Profit. Deine Unterstützung hält uns unabhängig und kompromisslos.';

  @override
  String get lightningAddress => 'Lightning-Adresse';

  @override
  String get bitcoinSilentPayment => 'Bitcoin Silent Payment';

  @override
  String get copiedToClipboardThankYou => 'In Zwischenablage kopiert. Danke! 🦥';

  @override
  String get shareProfileTitle => 'Profil teilen';

  @override
  String get scanToConnect => 'Zum Verbinden scannen';

  @override
  String get signOutTitle => 'Abmelden';

  @override
  String get signOutConfirmation => 'Möchtest du dich wirklich abmelden?';

  @override
  String get signOutWarning =>
      'Wenn du dich bei White Noise abmeldest, werden deine Chats von diesem Gerät gelöscht und können auf einem anderen Gerät nicht wiederhergestellt werden.\n\nWenn du deinen privaten Schlüssel nicht gesichert hast, kannst du dieses Profil bei keinem anderen Nostr-Dienst verwenden.';

  @override
  String get backUpPrivateKey => 'Privaten Schlüssel sichern';

  @override
  String get copyPrivateKeyHint =>
      'Kopiere deinen privaten Schlüssel, um dein Konto auf einem anderen Gerät wiederherzustellen.';

  @override
  String get publicKeyCopyError =>
      'Öffentlicher Schlüssel konnte nicht kopiert werden. Bitte erneut versuchen.';

  @override
  String get noChatsYet => 'Noch keine Chats';

  @override
  String get startConversation => 'Starte ein Gespräch';

  @override
  String get noMessagesYet => 'Noch keine Nachrichten';

  @override
  String get messagePlaceholder => 'Nachricht';

  @override
  String get failedToSendMessage =>
      'Nachricht konnte nicht gesendet werden. Bitte erneut versuchen.';

  @override
  String get invitedToSecureChat => 'Du wurdest zu einem sicheren Chat eingeladen';

  @override
  String get decline => 'Ablehnen';

  @override
  String get accept => 'Annehmen';

  @override
  String failedToAcceptInvitation(String error) {
    return 'Einladung konnte nicht angenommen werden: $error';
  }

  @override
  String failedToDeclineInvitation(String error) {
    return 'Einladung konnte nicht abgelehnt werden: $error';
  }

  @override
  String get startNewChat => 'Neuen Chat starten';

  @override
  String get noResults => 'Keine Ergebnisse';

  @override
  String get noFollowsYet => 'Noch keine Follows';

  @override
  String get developerSettingsTitle => 'Entwicklereinstellungen';

  @override
  String get publishNewKeyPackage => 'Neues Schlüsselpaket veröffentlichen';

  @override
  String get refreshKeyPackages => 'Schlüsselpakete aktualisieren';

  @override
  String get deleteAllKeyPackages => 'Alle Schlüsselpakete löschen';

  @override
  String keyPackagesCount(int count) {
    return 'Schlüsselpakete ($count)';
  }

  @override
  String get noKeyPackagesFound => 'Keine Schlüsselpakete gefunden';

  @override
  String get keyPackagePublished => 'Schlüsselpaket veröffentlicht';

  @override
  String get keyPackagesRefreshed => 'Schlüsselpakete aktualisiert';

  @override
  String get keyPackagesDeleted => 'Alle Schlüsselpakete gelöscht';

  @override
  String get keyPackageDeleted => 'Schlüsselpaket gelöscht';

  @override
  String packageNumber(int number) {
    return 'Paket $number';
  }

  @override
  String get ohNo => 'Oh nein!';

  @override
  String get goBack => 'Zurück';

  @override
  String get reportError => 'Fehler melden';

  @override
  String get slothsWorking => 'Faultiere arbeiten';

  @override
  String get wipMessage =>
      'Faultiere arbeiten an dieser Funktion. Wenn du möchtest, dass die Faultiere schneller sind, spende bitte an White Noise';

  @override
  String get donate => 'Spenden';

  @override
  String get addRelay => 'Relay hinzufügen';

  @override
  String get enterRelayAddress => 'Relay-Adresse eingeben';

  @override
  String get relayAddressPlaceholder => 'wss://relay.example.com';

  @override
  String get removeRelay => 'Relay entfernen?';

  @override
  String get removeRelayConfirmation =>
      'Möchtest du dieses Relay wirklich entfernen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get remove => 'Entfernen';

  @override
  String get messageActions => 'Nachrichtenaktionen';

  @override
  String get reply => 'Antworten';

  @override
  String get delete => 'Löschen';

  @override
  String get failedToDeleteMessage =>
      'Nachricht konnte nicht gelöscht werden. Bitte erneut versuchen.';

  @override
  String get failedToSendReaction =>
      'Reaktion konnte nicht gesendet werden. Bitte erneut versuchen.';

  @override
  String get failedToRemoveReaction =>
      'Reaktion konnte nicht entfernt werden. Bitte erneut versuchen.';

  @override
  String get unknownUser => 'Unbekannter Benutzer';

  @override
  String get unknownGroup => 'Unbekannte Gruppe';

  @override
  String get hasInvitedYouToSecureChat => 'Hat dich zu einem sicheren Chat eingeladen';

  @override
  String userInvitedYouToSecureChat(String name) {
    return '$name hat dich zu einem sicheren Chat eingeladen';
  }

  @override
  String get youHaveBeenInvitedToSecureChat => 'Du wurdest zu einem sicheren Chat eingeladen';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get languageUpdateFailed =>
      'Spracheinstellung konnte nicht gespeichert werden. Bitte erneut versuchen.';

  @override
  String get timeJustNow => 'gerade eben';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Minuten',
      one: 'vor 1 Minute',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Stunden',
      one: 'vor 1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'gestern',
    );
    return '$_temp0';
  }

  @override
  String get profile => 'Profil';

  @override
  String get follow => 'Folgen';

  @override
  String get unfollow => 'Entfolgen';

  @override
  String get failedToStartChat =>
      'Chat konnte nicht gestartet werden. Bitte versuchen Sie es erneut.';

  @override
  String get userNotOnWhiteNoise => 'Dieser Benutzer ist noch nicht bei White Noise.';

  @override
  String get failedToUpdateFollow =>
      'Folgestatus konnte nicht aktualisiert werden. Bitte versuchen Sie es erneut.';

  @override
  String get imagePickerError =>
      'Bild konnte nicht ausgewählt werden. Bitte versuchen Sie es erneut.';

  @override
  String get scanNsec => 'QR-Code scannen';

  @override
  String get scanNsecHint => 'Scannen Sie den QR-Code Ihres privaten Schlüssels zum Anmelden.';

  @override
  String get cameraPermissionDenied => 'Kamerazugriff verweigert';

  @override
  String get somethingWentWrong => 'Etwas ist schiefgelaufen';

  @override
  String get scanNpub => 'QR-Code scannen';

  @override
  String get scanNpubHint => 'Scannen Sie den QR-Code eines Kontakts.';
}
