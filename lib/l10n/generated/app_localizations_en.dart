// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'White Noise';

  @override
  String get tagline1 => 'Decentralized. Uncensorable.';

  @override
  String get tagline2 => 'Secure Messaging.';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get loginTitle => 'Login to White Noise';

  @override
  String get enterPrivateKey => 'Enter your private key';

  @override
  String get nsecPlaceholder => 'nsec...';

  @override
  String get setupProfile => 'Setup profile';

  @override
  String get chooseName => 'Choose a name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get introduceYourself => 'Introduce yourself';

  @override
  String get writeSomethingAboutYourself => 'Write something about yourself';

  @override
  String get cancel => 'Cancel';

  @override
  String get profileReady => 'Your profile is ready!';

  @override
  String get startConversationHint =>
      'Start a conversation by adding friends or sharing your profile.';

  @override
  String get shareYourProfile => 'Share your profile';

  @override
  String get startChat => 'Start a chat';

  @override
  String get settings => 'Settings';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get profileKeys => 'Profile keys';

  @override
  String get networkRelays => 'Network relays';

  @override
  String get appSettings => 'App settings';

  @override
  String get donateToWhiteNoise => 'Donate to White Noise';

  @override
  String get developerSettings => 'Developer settings';

  @override
  String get signOut => 'Sign out';

  @override
  String get appSettingsTitle => 'App Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get profileKeysTitle => 'Profile keys';

  @override
  String get publicKey => 'Public key';

  @override
  String get publicKeyCopied => 'Public key copied to clipboard';

  @override
  String get publicKeyDescription =>
      'Your public key (npub) can be shared with others. It\'s used to identify you on the network.';

  @override
  String get privateKey => 'Private key';

  @override
  String get privateKeyCopied => 'Private key copied to clipboard';

  @override
  String get privateKeyDescription =>
      'Your private key (nsec) should be kept secret. Anyone with access to it can control your account.';

  @override
  String get keepPrivateKeySecure => 'Keep your private key secure';

  @override
  String get privateKeyWarning =>
      'Don\'t share your private key publicly, and use it only to log in to other Nostr apps.';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get profileName => 'Profile name';

  @override
  String get nostrAddress => 'Nostr address';

  @override
  String get nostrAddressPlaceholder => 'example@whitenoise.chat';

  @override
  String get aboutYou => 'About you';

  @override
  String get profileIsPublic => 'Profile is public';

  @override
  String get profilePublicDescription =>
      'Your profile information will be visible to everyone on the network.';

  @override
  String get discardChanges => 'Discard changes';

  @override
  String get save => 'Save';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String errorLoadingProfile(String error) {
    return 'Error loading profile: $error';
  }

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get profileLoadError => 'Unable to load profile. Please try again.';

  @override
  String get profileSaveError => 'Unable to save profile. Please try again.';

  @override
  String get networkRelaysTitle => 'Network Relays';

  @override
  String get myRelays => 'My Relays';

  @override
  String get myRelaysHelp => 'Relays you have defined for use across all your Nostr applications.';

  @override
  String get inboxRelays => 'Inbox Relays';

  @override
  String get inboxRelaysHelp =>
      'Relays used to receive invitations and start secure conversations with new users.';

  @override
  String get keyPackageRelays => 'Key Package Relays';

  @override
  String get keyPackageRelaysHelp =>
      'Relays that store your secure key so others can invite you to encrypted conversations.';

  @override
  String get errorLoadingRelays => 'Error loading relays';

  @override
  String get noRelaysConfigured => 'No relays configured';

  @override
  String get donateTitle => 'Donate to White Noise';

  @override
  String get donateDescription =>
      'As a not-for-profit, White Noise exists solely for your privacy and freedom, not for profit. Your support keeps us independent and uncompromised.';

  @override
  String get lightningAddress => 'Lightning Address';

  @override
  String get bitcoinSilentPayment => 'Bitcoin Silent Payment';

  @override
  String get copiedToClipboardThankYou => 'Copied to clipboard. Thank you! 🦥';

  @override
  String get shareProfileTitle => 'Share profile';

  @override
  String get scanToConnect => 'Scan to connect';

  @override
  String get signOutTitle => 'Sign out';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get signOutWarning =>
      'When you sign out of White Noise, your chats will be deleted from this device and cannot be restored on another device.\n\nIf you haven\'t backed up your private key, you won\'t be able to use this profile on any other Nostr service.';

  @override
  String get backUpPrivateKey => 'Back up your private key';

  @override
  String get copyPrivateKeyHint =>
      'Copy your private key to restore your account on another device.';

  @override
  String get noChatsYet => 'No chats yet';

  @override
  String get startConversation => 'Start a conversation';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get messagePlaceholder => 'Message';

  @override
  String get failedToSendMessage => 'Failed to send message. Please try again.';

  @override
  String get invitedToSecureChat => 'You are invited to a secure chat';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String failedToAcceptInvitation(String error) {
    return 'Failed to accept invitation: $error';
  }

  @override
  String failedToDeclineInvitation(String error) {
    return 'Failed to decline invitation: $error';
  }

  @override
  String get startNewChat => 'Start new chat';

  @override
  String get noResults => 'No results';

  @override
  String get noFollowsYet => 'No follows yet';

  @override
  String get developerSettingsTitle => 'Developer Settings';

  @override
  String get publishNewKeyPackage => 'Publish New Key Package';

  @override
  String get refreshKeyPackages => 'Refresh Key Packages';

  @override
  String get deleteAllKeyPackages => 'Delete All Key Packages';

  @override
  String keyPackagesCount(int count) {
    return 'Key Packages ($count)';
  }

  @override
  String get noKeyPackagesFound => 'No key packages found';

  @override
  String packageNumber(int number) {
    return 'Package $number';
  }

  @override
  String get ohNo => 'Oh no!';

  @override
  String get goBack => 'Go back';

  @override
  String get reportError => 'Report error';

  @override
  String get slothsWorking => 'Sloths working';

  @override
  String get wipMessage =>
      'Sloths are working on this feature. If you want sloths to go faster, please donate to White Noise';

  @override
  String get donate => 'Donate';

  @override
  String get addRelay => 'Add Relay';

  @override
  String get enterRelayAddress => 'Enter relay address';

  @override
  String get relayAddressPlaceholder => 'wss://relay.example.com';

  @override
  String get removeRelay => 'Remove Relay?';

  @override
  String get removeRelayConfirmation =>
      'Are you sure you want to remove this relay? This action cannot be undone.';

  @override
  String get remove => 'Remove';

  @override
  String get messageActions => 'Message actions';

  @override
  String get reply => 'Reply';

  @override
  String get delete => 'Delete';

  @override
  String get failedToDeleteMessage => 'Failed to delete message. Please try again.';

  @override
  String get failedToSendReaction => 'Failed to send reaction. Please try again.';

  @override
  String get failedToRemoveReaction => 'Failed to remove reaction. Please try again.';

  @override
  String get unknownUser => 'Unknown user';

  @override
  String get unknownGroup => 'Unknown group';

  @override
  String get hasInvitedYouToSecureChat => 'Has invited you to a secure chat';

  @override
  String userInvitedYouToSecureChat(String name) {
    return '$name has invited you to a secure chat';
  }

  @override
  String get youHaveBeenInvitedToSecureChat => 'You have been invited to a secure chat';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageUpdateFailed => 'Failed to save language preference. Please try again.';

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: 'yesterday',
    );
    return '$_temp0';
  }
}
