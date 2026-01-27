// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'White Noise';

  @override
  String get tagline1 => 'Décentralisé. Incensurable.';

  @override
  String get tagline2 => 'Messagerie Sécurisée.';

  @override
  String get login => 'Connexion';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get loginTitle => 'Connexion à White Noise';

  @override
  String get enterPrivateKey => 'Entrez votre clé privée';

  @override
  String get nsecPlaceholder => 'nsec...';

  @override
  String get setupProfile => 'Configurer le profil';

  @override
  String get chooseName => 'Choisissez un nom';

  @override
  String get enterYourName => 'Entrez votre nom';

  @override
  String get introduceYourself => 'Présentez-vous';

  @override
  String get writeSomethingAboutYourself => 'Écrivez quelque chose sur vous';

  @override
  String get cancel => 'Annuler';

  @override
  String get profileReady => 'Votre profil est prêt !';

  @override
  String get startConversationHint =>
      'Démarrez une conversation en ajoutant des amis ou en partageant votre profil.';

  @override
  String get shareYourProfile => 'Partager votre profil';

  @override
  String get startChat => 'Démarrer une discussion';

  @override
  String get settings => 'Paramètres';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get profileKeys => 'Clés du profil';

  @override
  String get networkRelays => 'Relais réseau';

  @override
  String get appSettings => 'Paramètres de l\'app';

  @override
  String get privacyAndSecurity => 'Confidentialité et sécurité';

  @override
  String get dataUsage => 'Utilisation des données';

  @override
  String get appearance => 'Apparence';

  @override
  String get donateToWhiteNoise => 'Faire un don à White Noise';

  @override
  String get developerSettings => 'Paramètres développeur';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get appSettingsTitle => 'Paramètres de l\'App';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get profileKeysTitle => 'Clés du profil';

  @override
  String get publicKey => 'Clé publique';

  @override
  String get publicKeyCopied => 'Clé publique copiée dans le presse-papiers';

  @override
  String get publicKeyDescription =>
      'Votre clé publique (npub) peut être partagée avec d\'autres. Elle est utilisée pour vous identifier sur le réseau.';

  @override
  String get privateKey => 'Clé privée';

  @override
  String get privateKeyCopied => 'Clé privée copiée dans le presse-papiers';

  @override
  String get privateKeyDescription =>
      'Votre clé privée (nsec) doit rester secrète. Toute personne y ayant accès peut contrôler votre compte.';

  @override
  String get keepPrivateKeySecure => 'Gardez votre clé privée en sécurité';

  @override
  String get privateKeyWarning =>
      'Ne partagez pas votre clé privée publiquement et utilisez-la uniquement pour vous connecter à d\'autres apps Nostr.';

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get profileName => 'Nom du profil';

  @override
  String get nostrAddress => 'Adresse Nostr';

  @override
  String get nostrAddressPlaceholder => 'exemple@whitenoise.chat';

  @override
  String get aboutYou => 'À propos de vous';

  @override
  String get profileIsPublic => 'Le profil est public';

  @override
  String get profilePublicDescription =>
      'Les informations de votre profil seront visibles par tous sur le réseau.';

  @override
  String get discardChanges => 'Annuler les modifications';

  @override
  String get save => 'Enregistrer';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès';

  @override
  String errorLoadingProfile(String error) {
    return 'Erreur lors du chargement du profil : $error';
  }

  @override
  String error(String error) {
    return 'Erreur : $error';
  }

  @override
  String get profileLoadError => 'Impossible de charger le profil. Veuillez réessayer.';

  @override
  String get profileSaveError => 'Impossible d\'enregistrer le profil. Veuillez réessayer.';

  @override
  String get networkRelaysTitle => 'Relais Réseau';

  @override
  String get myRelays => 'Mes Relais';

  @override
  String get myRelaysHelp =>
      'Relais que vous avez définis pour une utilisation dans toutes vos applications Nostr.';

  @override
  String get inboxRelays => 'Relais de Boîte de Réception';

  @override
  String get inboxRelaysHelp =>
      'Relais utilisés pour recevoir des invitations et démarrer des conversations sécurisées avec de nouveaux utilisateurs.';

  @override
  String get keyPackageRelays => 'Relais de Paquet de Clés';

  @override
  String get keyPackageRelaysHelp =>
      'Relais qui stockent votre clé sécurisée pour que d\'autres puissent vous inviter à des conversations chiffrées.';

  @override
  String get errorLoadingRelays => 'Erreur lors du chargement des relais';

  @override
  String get noRelaysConfigured => 'Aucun relais configuré';

  @override
  String get donateTitle => 'Faire un don à White Noise';

  @override
  String get donateDescription =>
      'En tant qu\'organisation à but non lucratif, White Noise existe uniquement pour votre vie privée et votre liberté, pas pour le profit. Votre soutien nous maintient indépendants et sans compromis.';

  @override
  String get lightningAddress => 'Adresse Lightning';

  @override
  String get bitcoinSilentPayment => 'Paiement Silencieux Bitcoin';

  @override
  String get copiedToClipboardThankYou => 'Copié dans le presse-papiers. Merci ! 🦥';

  @override
  String get shareProfileTitle => 'Partager le profil';

  @override
  String get scanToConnect => 'Scanner pour se connecter';

  @override
  String get signOutTitle => 'Déconnexion';

  @override
  String get signOutConfirmation => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get signOutWarning =>
      'Lorsque vous vous déconnectez de White Noise, vos discussions seront supprimées de cet appareil et ne pourront pas être restaurées sur un autre appareil.\n\nSi vous n\'avez pas sauvegardé votre clé privée, vous ne pourrez pas utiliser ce profil sur un autre service Nostr.';

  @override
  String get backUpPrivateKey => 'Sauvegardez votre clé privée';

  @override
  String get copyPrivateKeyHint =>
      'Copiez votre clé privée pour restaurer votre compte sur un autre appareil.';

  @override
  String get noChatsYet => 'Pas encore de discussions';

  @override
  String get startConversation => 'Démarrer une conversation';

  @override
  String get noMessagesYet => 'Pas encore de messages';

  @override
  String get messagePlaceholder => 'Message';

  @override
  String get failedToSendMessage => 'Échec de l\'envoi du message. Veuillez réessayer.';

  @override
  String get invitedToSecureChat => 'Vous êtes invité à une discussion sécurisée';

  @override
  String get decline => 'Refuser';

  @override
  String get accept => 'Accepter';

  @override
  String failedToAcceptInvitation(String error) {
    return 'Échec de l\'acceptation de l\'invitation : $error';
  }

  @override
  String failedToDeclineInvitation(String error) {
    return 'Échec du refus de l\'invitation : $error';
  }

  @override
  String get startNewChat => 'Nouvelle discussion';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get noFollowsYet => 'Pas encore d\'abonnements';

  @override
  String get developerSettingsTitle => 'Paramètres Développeur';

  @override
  String get publishNewKeyPackage => 'Publier un Nouveau Paquet de Clés';

  @override
  String get refreshKeyPackages => 'Actualiser les Paquets de Clés';

  @override
  String get deleteAllKeyPackages => 'Supprimer Tous les Paquets de Clés';

  @override
  String keyPackagesCount(int count) {
    return 'Paquets de Clés ($count)';
  }

  @override
  String get noKeyPackagesFound => 'Aucun paquet de clés trouvé';

  @override
  String packageNumber(int number) {
    return 'Paquet $number';
  }

  @override
  String get ohNo => 'Oh non !';

  @override
  String get goBack => 'Retour';

  @override
  String get reportError => 'Signaler une erreur';

  @override
  String get slothsWorking => 'Paresseux au travail';

  @override
  String get wipMessage =>
      'Les paresseux travaillent sur cette fonctionnalité. Si vous voulez que les paresseux aillent plus vite, faites un don à White Noise';

  @override
  String get donate => 'Faire un don';

  @override
  String get addRelay => 'Ajouter un Relais';

  @override
  String get enterRelayAddress => 'Entrez l\'adresse du relais';

  @override
  String get relayAddressPlaceholder => 'wss://relay.example.com';

  @override
  String get removeRelay => 'Supprimer le Relais ?';

  @override
  String get removeRelayConfirmation =>
      'Êtes-vous sûr de vouloir supprimer ce relais ? Cette action ne peut pas être annulée.';

  @override
  String get remove => 'Supprimer';

  @override
  String get messageActions => 'Actions du message';

  @override
  String get reply => 'Répondre';

  @override
  String get delete => 'Supprimer';

  @override
  String get failedToDeleteMessage => 'Échec de la suppression du message. Veuillez réessayer.';

  @override
  String get failedToSendReaction => 'Échec de l\'envoi de la réaction. Veuillez réessayer.';

  @override
  String get unknownUser => 'Utilisateur inconnu';

  @override
  String get unknownGroup => 'Groupe inconnu';

  @override
  String get hasInvitedYouToSecureChat => 'Vous a invité à une discussion sécurisée';

  @override
  String userInvitedYouToSecureChat(String name) {
    return '$name vous a invité à une discussion sécurisée';
  }

  @override
  String get youHaveBeenInvitedToSecureChat => 'Vous avez été invité à une discussion sécurisée';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get languageUpdateFailed =>
      'Échec de l\'enregistrement de la préférence linguistique. Veuillez réessayer.';

  @override
  String get timeJustNow => 'à l\'instant';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count minutes',
      one: 'il y a 1 minute',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count heures',
      one: 'il y a 1 heure',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count jours',
      one: 'hier',
    );
    return '$_temp0';
  }

  @override
  String get deleteAllAppData => 'Supprimer toutes les données de l\'app';

  @override
  String get deleteAppData => 'Supprimer les données de l\'app';

  @override
  String get deleteAllAppDataDescription =>
      'Efface tous les profils, clés, conversations et fichiers locaux de cet appareil.';

  @override
  String get deleteAllAppDataConfirmation => 'Supprimer toutes les données de l\'app ?';

  @override
  String get deleteAllAppDataWarning =>
      'Cela effacera tous les profils, clés, conversations et fichiers locaux de cet appareil. Cette action est irréversible.';

  @override
  String get deleteAllAppDataFailed =>
      'Échec de la suppression des données de l\'app. Veuillez réessayer.';
}
