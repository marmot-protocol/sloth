// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'White Noise';

  @override
  String get tagline1 => 'Descentralizado. Incensurable.';

  @override
  String get tagline2 => 'Mensajería Segura.';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get loginTitle => 'Iniciar sesión en White Noise';

  @override
  String get enterPrivateKey => 'Introduce tu clave privada';

  @override
  String get nsecPlaceholder => 'nsec...';

  @override
  String get setupProfile => 'Configurar perfil';

  @override
  String get chooseName => 'Elige un nombre';

  @override
  String get enterYourName => 'Introduce tu nombre';

  @override
  String get introduceYourself => 'Preséntate';

  @override
  String get writeSomethingAboutYourself => 'Escribe algo sobre ti';

  @override
  String get cancel => 'Cancelar';

  @override
  String get profileReady => '¡Tu perfil está listo!';

  @override
  String get startConversationHint =>
      'Inicia una conversación añadiendo amigos o compartiendo tu perfil.';

  @override
  String get shareYourProfile => 'Compartir tu perfil';

  @override
  String get startChat => 'Iniciar chat';

  @override
  String get settings => 'Configuración';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get profileKeys => 'Claves del perfil';

  @override
  String get networkRelays => 'Relés de red';

  @override
  String get appSettings => 'Ajustes de la app';

  @override
  String get donateToWhiteNoise => 'Donar a White Noise';

  @override
  String get developerSettings => 'Ajustes de desarrollador';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get appSettingsTitle => 'Ajustes de la App';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get profileKeysTitle => 'Claves del perfil';

  @override
  String get publicKey => 'Clave pública';

  @override
  String get publicKeyCopied => 'Clave pública copiada al portapapeles';

  @override
  String get publicKeyDescription =>
      'Tu clave pública (npub) puede compartirse con otros. Se usa para identificarte en la red.';

  @override
  String get privateKey => 'Clave privada';

  @override
  String get privateKeyCopied => 'Clave privada copiada al portapapeles';

  @override
  String get privateKeyDescription =>
      'Tu clave privada (nsec) debe mantenerse en secreto. Cualquiera con acceso a ella puede controlar tu cuenta.';

  @override
  String get keepPrivateKeySecure => 'Mantén tu clave privada segura';

  @override
  String get privateKeyWarning =>
      'No compartas tu clave privada públicamente y úsala solo para iniciar sesión en otras apps de Nostr.';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get profileName => 'Nombre del perfil';

  @override
  String get nostrAddress => 'Dirección Nostr';

  @override
  String get nostrAddressPlaceholder => 'ejemplo@whitenoise.chat';

  @override
  String get aboutYou => 'Sobre ti';

  @override
  String get profileIsPublic => 'El perfil es público';

  @override
  String get profilePublicDescription =>
      'La información de tu perfil será visible para todos en la red.';

  @override
  String get discardChanges => 'Descartar cambios';

  @override
  String get save => 'Guardar';

  @override
  String get profileUpdatedSuccessfully => 'Perfil actualizado correctamente';

  @override
  String errorLoadingProfile(String error) {
    return 'Error al cargar el perfil: $error';
  }

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get profileLoadError => 'No se pudo cargar el perfil. Por favor, inténtelo de nuevo.';

  @override
  String get profileSaveError => 'No se pudo guardar el perfil. Por favor, inténtelo de nuevo.';

  @override
  String get networkRelaysTitle => 'Relés de Red';

  @override
  String get myRelays => 'Mis Relés';

  @override
  String get myRelaysHelp => 'Relés que has definido para usar en todas tus aplicaciones Nostr.';

  @override
  String get inboxRelays => 'Relés de Bandeja de Entrada';

  @override
  String get inboxRelaysHelp =>
      'Relés usados para recibir invitaciones e iniciar conversaciones seguras con nuevos usuarios.';

  @override
  String get keyPackageRelays => 'Relés de Paquete de Claves';

  @override
  String get keyPackageRelaysHelp =>
      'Relés que almacenan tu clave segura para que otros puedan invitarte a conversaciones cifradas.';

  @override
  String get errorLoadingRelays => 'Error al cargar los relés';

  @override
  String get noRelaysConfigured => 'No hay relés configurados';

  @override
  String get donateTitle => 'Donar a White Noise';

  @override
  String get donateDescription =>
      'Como organización sin fines de lucro, White Noise existe únicamente para tu privacidad y libertad, no para obtener ganancias. Tu apoyo nos mantiene independientes y sin compromisos.';

  @override
  String get lightningAddress => 'Dirección Lightning';

  @override
  String get bitcoinSilentPayment => 'Pago Silencioso de Bitcoin';

  @override
  String get copiedToClipboardThankYou => 'Copiado al portapapeles. ¡Gracias! 🦥';

  @override
  String get shareProfileTitle => 'Compartir perfil';

  @override
  String get scanToConnect => 'Escanear para conectar';

  @override
  String get signOutTitle => 'Cerrar sesión';

  @override
  String get signOutConfirmation => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get signOutWarning =>
      'Cuando cierres sesión en White Noise, tus chats se eliminarán de este dispositivo y no podrán restaurarse en otro dispositivo.\n\nSi no has respaldado tu clave privada, no podrás usar este perfil en ningún otro servicio Nostr.';

  @override
  String get backUpPrivateKey => 'Respalda tu clave privada';

  @override
  String get copyPrivateKeyHint =>
      'Copia tu clave privada para restaurar tu cuenta en otro dispositivo.';

  @override
  String get noChatsYet => 'Aún no hay chats';

  @override
  String get startConversation => 'Inicia una conversación';

  @override
  String get noMessagesYet => 'Aún no hay mensajes';

  @override
  String get messagePlaceholder => 'Mensaje';

  @override
  String get failedToSendMessage => 'Error al enviar el mensaje. Por favor, inténtalo de nuevo.';

  @override
  String get invitedToSecureChat => 'Has sido invitado a un chat seguro';

  @override
  String get decline => 'Rechazar';

  @override
  String get accept => 'Aceptar';

  @override
  String failedToAcceptInvitation(String error) {
    return 'Error al aceptar la invitación: $error';
  }

  @override
  String failedToDeclineInvitation(String error) {
    return 'Error al rechazar la invitación: $error';
  }

  @override
  String get startNewChat => 'Iniciar nuevo chat';

  @override
  String get noResults => 'Sin resultados';

  @override
  String get noFollowsYet => 'Aún no hay seguidos';

  @override
  String get developerSettingsTitle => 'Ajustes de Desarrollador';

  @override
  String get publishNewKeyPackage => 'Publicar Nuevo Paquete de Claves';

  @override
  String get refreshKeyPackages => 'Actualizar Paquetes de Claves';

  @override
  String get deleteAllKeyPackages => 'Eliminar Todos los Paquetes de Claves';

  @override
  String keyPackagesCount(int count) {
    return 'Paquetes de Claves ($count)';
  }

  @override
  String get noKeyPackagesFound => 'No se encontraron paquetes de claves';

  @override
  String packageNumber(int number) {
    return 'Paquete $number';
  }

  @override
  String get ohNo => '¡Oh no!';

  @override
  String get goBack => 'Volver';

  @override
  String get reportError => 'Reportar error';

  @override
  String get slothsWorking => 'Perezosos trabajando';

  @override
  String get wipMessage =>
      'Los perezosos están trabajando en esta función. Si quieres que los perezosos vayan más rápido, por favor dona a White Noise';

  @override
  String get donate => 'Donar';

  @override
  String get addRelay => 'Añadir Relé';

  @override
  String get enterRelayAddress => 'Introduce la dirección del relé';

  @override
  String get relayAddressPlaceholder => 'wss://relay.example.com';

  @override
  String get removeRelay => '¿Eliminar Relé?';

  @override
  String get removeRelayConfirmation =>
      '¿Estás seguro de que quieres eliminar este relé? Esta acción no se puede deshacer.';

  @override
  String get remove => 'Eliminar';

  @override
  String get messageActions => 'Acciones del mensaje';

  @override
  String get reply => 'Responder';

  @override
  String get delete => 'Eliminar';

  @override
  String get failedToDeleteMessage =>
      'Error al eliminar el mensaje. Por favor, inténtalo de nuevo.';

  @override
  String get failedToSendReaction => 'Error al enviar la reacción. Por favor, inténtalo de nuevo.';

  @override
  String get unknownUser => 'Usuario desconocido';

  @override
  String get unknownGroup => 'Grupo desconocido';

  @override
  String get hasInvitedYouToSecureChat => 'Te ha invitado a un chat seguro';

  @override
  String userInvitedYouToSecureChat(String name) {
    return '$name te ha invitado a un chat seguro';
  }

  @override
  String get youHaveBeenInvitedToSecureChat => 'Has sido invitado a un chat seguro';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageUpdateFailed =>
      'Error al guardar la preferencia de idioma. Por favor, inténtalo de nuevo.';

  @override
  String get timeJustNow => 'ahora mismo';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count minutos',
      one: 'hace 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count horas',
      one: 'hace 1 hora',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'ayer',
    );
    return '$_temp0';
  }
}
