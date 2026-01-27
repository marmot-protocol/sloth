// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'White Noise';

  @override
  String get tagline1 => 'Descentralizado. Incensurável.';

  @override
  String get tagline2 => 'Mensagens Seguras.';

  @override
  String get login => 'Entrar';

  @override
  String get signUp => 'Cadastrar';

  @override
  String get loginTitle => 'Entrar no White Noise';

  @override
  String get enterPrivateKey => 'Digite sua chave privada';

  @override
  String get nsecPlaceholder => 'nsec...';

  @override
  String get setupProfile => 'Configurar perfil';

  @override
  String get chooseName => 'Escolha um nome';

  @override
  String get enterYourName => 'Digite seu nome';

  @override
  String get introduceYourself => 'Apresente-se';

  @override
  String get writeSomethingAboutYourself => 'Escreva algo sobre você';

  @override
  String get cancel => 'Cancelar';

  @override
  String get profileReady => 'Seu perfil está pronto!';

  @override
  String get startConversationHint =>
      'Inicie uma conversa adicionando amigos ou compartilhando seu perfil.';

  @override
  String get shareYourProfile => 'Compartilhar seu perfil';

  @override
  String get startChat => 'Iniciar conversa';

  @override
  String get settings => 'Configurações';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get profileKeys => 'Chaves do perfil';

  @override
  String get networkRelays => 'Relays de rede';

  @override
  String get appSettings => 'Configurações do app';

  @override
  String get donateToWhiteNoise => 'Doar para o White Noise';

  @override
  String get developerSettings => 'Configurações de desenvolvedor';

  @override
  String get signOut => 'Sair';

  @override
  String get appSettingsTitle => 'Configurações do App';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get profileKeysTitle => 'Chaves do perfil';

  @override
  String get publicKey => 'Chave pública';

  @override
  String get publicKeyCopied => 'Chave pública copiada para a área de transferência';

  @override
  String get publicKeyDescription =>
      'Sua chave pública (npub) pode ser compartilhada com outros. Ela é usada para identificá-lo na rede.';

  @override
  String get privateKey => 'Chave privada';

  @override
  String get privateKeyCopied => 'Chave privada copiada para a área de transferência';

  @override
  String get privateKeyDescription =>
      'Sua chave privada (nsec) deve ser mantida em segredo. Qualquer pessoa com acesso a ela pode controlar sua conta.';

  @override
  String get keepPrivateKeySecure => 'Mantenha sua chave privada segura';

  @override
  String get privateKeyWarning =>
      'Não compartilhe sua chave privada publicamente e use-a apenas para entrar em outros apps Nostr.';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get profileName => 'Nome do perfil';

  @override
  String get nostrAddress => 'Endereço Nostr';

  @override
  String get nostrAddressPlaceholder => 'exemplo@whitenoise.chat';

  @override
  String get aboutYou => 'Sobre você';

  @override
  String get profileIsPublic => 'O perfil é público';

  @override
  String get profilePublicDescription =>
      'As informações do seu perfil serão visíveis para todos na rede.';

  @override
  String get discardChanges => 'Descartar alterações';

  @override
  String get save => 'Salvar';

  @override
  String get profileUpdatedSuccessfully => 'Perfil atualizado com sucesso';

  @override
  String errorLoadingProfile(String error) {
    return 'Erro ao carregar o perfil: $error';
  }

  @override
  String error(String error) {
    return 'Erro: $error';
  }

  @override
  String get profileLoadError => 'Não foi possível carregar o perfil. Por favor, tente novamente.';

  @override
  String get profileSaveError => 'Não foi possível salvar o perfil. Por favor, tente novamente.';

  @override
  String get networkRelaysTitle => 'Relays de Rede';

  @override
  String get myRelays => 'Meus Relays';

  @override
  String get myRelaysHelp => 'Relays que você definiu para uso em todas as suas aplicações Nostr.';

  @override
  String get inboxRelays => 'Relays de Caixa de Entrada';

  @override
  String get inboxRelaysHelp =>
      'Relays usados para receber convites e iniciar conversas seguras com novos usuários.';

  @override
  String get keyPackageRelays => 'Relays de Pacote de Chaves';

  @override
  String get keyPackageRelaysHelp =>
      'Relays que armazenam sua chave segura para que outros possam convidá-lo para conversas criptografadas.';

  @override
  String get errorLoadingRelays => 'Erro ao carregar os relays';

  @override
  String get noRelaysConfigured => 'Nenhum relay configurado';

  @override
  String get donateTitle => 'Doar para o White Noise';

  @override
  String get donateDescription =>
      'Como uma organização sem fins lucrativos, o White Noise existe apenas para sua privacidade e liberdade, não para lucro. Seu apoio nos mantém independentes e sem compromissos.';

  @override
  String get lightningAddress => 'Endereço Lightning';

  @override
  String get bitcoinSilentPayment => 'Pagamento Silencioso Bitcoin';

  @override
  String get copiedToClipboardThankYou => 'Copiado para a área de transferência. Obrigado! 🦥';

  @override
  String get shareProfileTitle => 'Compartilhar perfil';

  @override
  String get scanToConnect => 'Escaneie para conectar';

  @override
  String get signOutTitle => 'Sair';

  @override
  String get signOutConfirmation => 'Tem certeza de que deseja sair?';

  @override
  String get signOutWarning =>
      'Quando você sair do White Noise, suas conversas serão excluídas deste dispositivo e não poderão ser restauradas em outro dispositivo.\n\nSe você não fez backup da sua chave privada, não poderá usar este perfil em nenhum outro serviço Nostr.';

  @override
  String get backUpPrivateKey => 'Faça backup da sua chave privada';

  @override
  String get copyPrivateKeyHint =>
      'Copie sua chave privada para restaurar sua conta em outro dispositivo.';

  @override
  String get noChatsYet => 'Ainda não há conversas';

  @override
  String get startConversation => 'Inicie uma conversa';

  @override
  String get noMessagesYet => 'Ainda não há mensagens';

  @override
  String get messagePlaceholder => 'Mensagem';

  @override
  String get failedToSendMessage => 'Falha ao enviar mensagem. Por favor, tente novamente.';

  @override
  String get invitedToSecureChat => 'Você foi convidado para uma conversa segura';

  @override
  String get decline => 'Recusar';

  @override
  String get accept => 'Aceitar';

  @override
  String failedToAcceptInvitation(String error) {
    return 'Falha ao aceitar o convite: $error';
  }

  @override
  String failedToDeclineInvitation(String error) {
    return 'Falha ao recusar o convite: $error';
  }

  @override
  String get startNewChat => 'Nova conversa';

  @override
  String get noResults => 'Sem resultados';

  @override
  String get noFollowsYet => 'Ainda não há seguidos';

  @override
  String get developerSettingsTitle => 'Configurações de Desenvolvedor';

  @override
  String get publishNewKeyPackage => 'Publicar Novo Pacote de Chaves';

  @override
  String get refreshKeyPackages => 'Atualizar Pacotes de Chaves';

  @override
  String get deleteAllKeyPackages => 'Excluir Todos os Pacotes de Chaves';

  @override
  String keyPackagesCount(int count) {
    return 'Pacotes de Chaves ($count)';
  }

  @override
  String get noKeyPackagesFound => 'Nenhum pacote de chaves encontrado';

  @override
  String packageNumber(int number) {
    return 'Pacote $number';
  }

  @override
  String get ohNo => 'Oh não!';

  @override
  String get goBack => 'Voltar';

  @override
  String get reportError => 'Reportar erro';

  @override
  String get slothsWorking => 'Preguiças trabalhando';

  @override
  String get wipMessage =>
      'As preguiças estão trabalhando nesta funcionalidade. Se você quer que as preguiças sejam mais rápidas, por favor doe para o White Noise';

  @override
  String get donate => 'Doar';

  @override
  String get addRelay => 'Adicionar Relay';

  @override
  String get enterRelayAddress => 'Digite o endereço do relay';

  @override
  String get relayAddressPlaceholder => 'wss://relay.example.com';

  @override
  String get removeRelay => 'Remover Relay?';

  @override
  String get removeRelayConfirmation =>
      'Tem certeza de que deseja remover este relay? Esta ação não pode ser desfeita.';

  @override
  String get remove => 'Remover';

  @override
  String get messageActions => 'Ações da mensagem';

  @override
  String get reply => 'Responder';

  @override
  String get delete => 'Excluir';

  @override
  String get failedToDeleteMessage => 'Falha ao excluir mensagem. Por favor, tente novamente.';

  @override
  String get failedToSendReaction => 'Falha ao enviar reação. Por favor, tente novamente.';

  @override
  String get failedToRemoveReaction => 'Falha ao remover reação. Por favor, tente novamente.';

  @override
  String get unknownUser => 'Usuário desconhecido';

  @override
  String get unknownGroup => 'Grupo desconhecido';

  @override
  String get hasInvitedYouToSecureChat => 'Convidou você para uma conversa segura';

  @override
  String userInvitedYouToSecureChat(String name) {
    return '$name convidou você para uma conversa segura';
  }

  @override
  String get youHaveBeenInvitedToSecureChat => 'Você foi convidado para uma conversa segura';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageUpdateFailed =>
      'Falha ao salvar preferência de idioma. Por favor, tente novamente.';

  @override
  String get timeJustNow => 'agora mesmo';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count minutos',
      one: 'há 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count horas',
      one: 'há 1 hora',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count dias',
      one: 'ontem',
    );
    return '$_temp0';
  }
}
