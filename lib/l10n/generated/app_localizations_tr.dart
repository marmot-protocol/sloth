// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'White Noise';

  @override
  String get tagline1 => 'Merkezi Olmayan. Sansürlenemez.';

  @override
  String get tagline2 => 'Güvenli Mesajlaşma.';

  @override
  String get login => 'Giriş Yap';

  @override
  String get signUp => 'Kayıt Ol';

  @override
  String get loginTitle => 'White Noise\'a Giriş Yap';

  @override
  String get enterPrivateKey => 'Özel anahtarınızı girin';

  @override
  String get nsecPlaceholder => 'nsec...';

  @override
  String get setupProfile => 'Profil ayarla';

  @override
  String get chooseName => 'Bir isim seçin';

  @override
  String get enterYourName => 'Adınızı girin';

  @override
  String get introduceYourself => 'Kendinizi tanıtın';

  @override
  String get writeSomethingAboutYourself => 'Kendiniz hakkında bir şeyler yazın';

  @override
  String get cancel => 'İptal';

  @override
  String get profileReady => 'Profiliniz hazır!';

  @override
  String get startConversationHint =>
      'Arkadaş ekleyerek veya profilinizi paylaşarak bir sohbet başlatın.';

  @override
  String get shareYourProfile => 'Profilini paylaş';

  @override
  String get startChat => 'Sohbet başlat';

  @override
  String get settings => 'Ayarlar';

  @override
  String get shareAndConnect => 'Paylaş ve bağlan';

  @override
  String get switchProfile => 'Profil değiştir';

  @override
  String get addNewProfile => 'Yeni profil ekle';

  @override
  String get editProfile => 'Profili düzenle';

  @override
  String get profileKeys => 'Profil anahtarları';

  @override
  String get networkRelays => 'Ağ röleleri';

  @override
  String get appSettings => 'Uygulama ayarları';

  @override
  String get donateToWhiteNoise => 'White Noise\'a bağış yap';

  @override
  String get developerSettings => 'Geliştirici ayarları';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get appSettingsTitle => 'Uygulama Ayarları';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get profileKeysTitle => 'Profil anahtarları';

  @override
  String get publicKey => 'Açık anahtar';

  @override
  String get publicKeyCopied => 'Açık anahtar panoya kopyalandı';

  @override
  String get publicKeyDescription =>
      'Açık anahtarınız (npub) başkalarıyla paylaşılabilir. Ağda sizi tanımlamak için kullanılır.';

  @override
  String get privateKey => 'Özel anahtar';

  @override
  String get privateKeyCopied => 'Özel anahtar panoya kopyalandı';

  @override
  String get privateKeyDescription =>
      'Özel anahtarınız (nsec) gizli tutulmalıdır. Erişimi olan herkes hesabınızı kontrol edebilir.';

  @override
  String get keepPrivateKeySecure => 'Özel anahtarınızı güvende tutun';

  @override
  String get privateKeyWarning =>
      'Özel anahtarınızı herkese açık paylaşmayın ve yalnızca diğer Nostr uygulamalarına giriş yapmak için kullanın.';

  @override
  String get editProfileTitle => 'Profili düzenle';

  @override
  String get profileName => 'Profil adı';

  @override
  String get nostrAddress => 'Nostr adresi';

  @override
  String get nostrAddressPlaceholder => 'ornek@whitenoise.chat';

  @override
  String get aboutYou => 'Hakkınızda';

  @override
  String get profileIsPublic => 'Profil herkese açık';

  @override
  String get profilePublicDescription =>
      'Profil bilgileriniz ağdaki herkes tarafından görülebilir.';

  @override
  String get discard => 'At';

  @override
  String get discardChanges => 'Değişiklikleri at';

  @override
  String get save => 'Kaydet';

  @override
  String get profileUpdatedSuccessfully => 'Profil başarıyla güncellendi';

  @override
  String errorLoadingProfile(String error) {
    return 'Profil yüklenirken hata: $error';
  }

  @override
  String error(String error) {
    return 'Hata: $error';
  }

  @override
  String get profileLoadError => 'Profil yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get profileSaveError => 'Profil kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get networkRelaysTitle => 'Ağ Röleleri';

  @override
  String get myRelays => 'Rölelerim';

  @override
  String get myRelaysHelp => 'Tüm Nostr uygulamalarınızda kullanmak üzere tanımladığınız röleler.';

  @override
  String get inboxRelays => 'Gelen Kutusu Röleleri';

  @override
  String get inboxRelaysHelp =>
      'Davet almak ve yeni kullanıcılarla güvenli sohbetler başlatmak için kullanılan röleler.';

  @override
  String get keyPackageRelays => 'Anahtar Paketi Röleleri';

  @override
  String get keyPackageRelaysHelp =>
      'Başkalarının sizi şifreli sohbetlere davet edebilmesi için güvenli anahtarınızı saklayan röleler.';

  @override
  String get errorLoadingRelays => 'Röleler yüklenirken hata';

  @override
  String get noRelaysConfigured => 'Yapılandırılmış röle yok';

  @override
  String get donateTitle => 'White Noise\'a Bağış Yap';

  @override
  String get donateDescription =>
      'Kar amacı gütmeyen bir kuruluş olarak White Noise, yalnızca gizliliğiniz ve özgürlüğünüz için var, kar için değil. Desteğiniz bizi bağımsız ve taviz vermeden tutar.';

  @override
  String get lightningAddress => 'Lightning Adresi';

  @override
  String get bitcoinSilentPayment => 'Bitcoin Sessiz Ödeme';

  @override
  String get copiedToClipboardThankYou => 'Panoya kopyalandı. Teşekkürler! 🦥';

  @override
  String get shareProfileTitle => 'Profili paylaş';

  @override
  String get scanToConnect => 'Bağlanmak için tarayın';

  @override
  String get signOutTitle => 'Çıkış yap';

  @override
  String get signOutConfirmation => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get signOutWarning =>
      'White Noise\'dan çıkış yaptığınızda, sohbetleriniz bu cihazdan silinecek ve başka bir cihazda geri yüklenemeyecektir.\n\nÖzel anahtarınızı yedeklemediyseniz, bu profili başka hiçbir Nostr hizmetinde kullanamazsınız.';

  @override
  String get backUpPrivateKey => 'Özel anahtarınızı yedekleyin';

  @override
  String get copyPrivateKeyHint =>
      'Hesabınızı başka bir cihazda geri yüklemek için özel anahtarınızı kopyalayın.';

  @override
  String get noChatsYet => 'Henüz sohbet yok';

  @override
  String get startConversation => 'Bir sohbet başlatın';

  @override
  String get noMessagesYet => 'Henüz mesaj yok';

  @override
  String get messagePlaceholder => 'Mesaj';

  @override
  String get failedToSendMessage => 'Mesaj gönderilemedi. Lütfen tekrar deneyin.';

  @override
  String get invitedToSecureChat => 'Güvenli bir sohbete davet edildiniz';

  @override
  String get decline => 'Reddet';

  @override
  String get accept => 'Kabul et';

  @override
  String failedToAcceptInvitation(String error) {
    return 'Davet kabul edilemedi: $error';
  }

  @override
  String failedToDeclineInvitation(String error) {
    return 'Davet reddedilemedi: $error';
  }

  @override
  String get startNewChat => 'Yeni sohbet';

  @override
  String get noResults => 'Sonuç yok';

  @override
  String get noFollowsYet => 'Henüz takip yok';

  @override
  String get developerSettingsTitle => 'Geliştirici Ayarları';

  @override
  String get publishNewKeyPackage => 'Yeni Anahtar Paketi Yayınla';

  @override
  String get refreshKeyPackages => 'Anahtar Paketlerini Yenile';

  @override
  String get deleteAllKeyPackages => 'Tüm Anahtar Paketlerini Sil';

  @override
  String keyPackagesCount(int count) {
    return 'Anahtar Paketleri ($count)';
  }

  @override
  String get noKeyPackagesFound => 'Anahtar paketi bulunamadı';

  @override
  String get keyPackagePublished => 'Anahtar paketi yayınlandı';

  @override
  String get keyPackagesRefreshed => 'Anahtar paketleri yenilendi';

  @override
  String get keyPackagesDeleted => 'Tüm anahtar paketleri silindi';

  @override
  String get keyPackageDeleted => 'Anahtar paketi silindi';

  @override
  String packageNumber(int number) {
    return 'Paket $number';
  }

  @override
  String get ohNo => 'Ah hayır!';

  @override
  String get goBack => 'Geri dön';

  @override
  String get reportError => 'Hata bildir';

  @override
  String get slothsWorking => 'Tembel hayvanlar çalışıyor';

  @override
  String get wipMessage =>
      'Tembel hayvanlar bu özellik üzerinde çalışıyor. Tembel hayvanların daha hızlı gitmesini istiyorsanız, lütfen White Noise\'a bağış yapın';

  @override
  String get donate => 'Bağış yap';

  @override
  String get addRelay => 'Röle Ekle';

  @override
  String get enterRelayAddress => 'Röle adresini girin';

  @override
  String get relayAddressPlaceholder => 'wss://relay.example.com';

  @override
  String get removeRelay => 'Röle Kaldırılsın mı?';

  @override
  String get removeRelayConfirmation =>
      'Bu röleyi kaldırmak istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get remove => 'Kaldır';

  @override
  String get messageActions => 'Mesaj işlemleri';

  @override
  String get reply => 'Yanıtla';

  @override
  String get delete => 'Sil';

  @override
  String get failedToDeleteMessage => 'Mesaj silinemedi. Lütfen tekrar deneyin.';

  @override
  String get failedToSendReaction => 'Tepki gönderilemedi. Lütfen tekrar deneyin.';

  @override
  String get failedToRemoveReaction => 'Tepki kaldırılamadı. Lütfen tekrar deneyin.';

  @override
  String get unknownUser => 'Bilinmeyen kullanıcı';

  @override
  String get unknownGroup => 'Bilinmeyen grup';

  @override
  String get hasInvitedYouToSecureChat => 'Sizi güvenli bir sohbete davet etti';

  @override
  String userInvitedYouToSecureChat(String name) {
    return '$name sizi güvenli bir sohbete davet etti';
  }

  @override
  String get youHaveBeenInvitedToSecureChat => 'Güvenli bir sohbete davet edildiniz';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get languageUpdateFailed => 'Dil tercihi kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get timeJustNow => 'şimdi';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dakika önce',
      one: '1 dakika önce',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saat önce',
      one: '1 saat önce',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün önce',
      one: 'dün',
    );
    return '$_temp0';
  }

  @override
  String get profile => 'Profil';

  @override
  String get follow => 'Takip et';

  @override
  String get unfollow => 'Takibi bırak';

  @override
  String get failedToStartChat => 'Sohbet başlatılamadı. Lütfen tekrar deneyin.';

  @override
  String get userNotOnWhiteNoise => 'Bu kullanıcı henüz White Noise\'da değil.';

  @override
  String get failedToUpdateFollow => 'Takip durumu güncellenemedi. Lütfen tekrar deneyin.';

  @override
  String get imagePickerError => 'Görsel seçilemedi. Lütfen tekrar deneyin.';
}
