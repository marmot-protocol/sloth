import 'package:flutter/material.dart'
    show BuildContext, CurvedAnimation, Curves, FadeTransition, Widget, Navigator;
import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;
import 'package:go_router/go_router.dart'
    show CustomTransitionPage, GoRouter, GoRoute, GoRouterState;
import 'package:sloth/hooks/use_route_refresh.dart' show routeObserver;
import 'package:sloth/providers/auth_provider.dart' show authProvider;
import 'package:sloth/screens/chat_invite_screen.dart' show ChatInviteScreen;
import 'package:sloth/screens/chat_list_screen.dart' show ChatListScreen;
import 'package:sloth/screens/chat_screen.dart' show ChatScreen;
import 'package:sloth/screens/developer_settings_screen.dart' show DeveloperSettingsScreen;
import 'package:sloth/screens/donate_screen.dart' show DonateScreen;
import 'package:sloth/screens/edit_profile_screen.dart' show EditProfileScreen;
import 'package:sloth/screens/home_screen.dart' show HomeScreen;
import 'package:sloth/screens/login_screen.dart' show LoginScreen;
import 'package:sloth/screens/onboarding_screen.dart' show OnboardingScreen;
import 'package:sloth/screens/profile_keys_screen.dart' show ProfileKeysScreen;
import 'package:sloth/screens/settings_screen.dart' show SettingsScreen;
import 'package:sloth/screens/share_profile_screen.dart' show ShareProfileScreen;
import 'package:sloth/screens/signup_screen.dart' show SignupScreen;
import 'package:sloth/screens/wip_screen.dart' show WipScreen;

abstract final class Routes {
  static const _home = '/';
  static const _login = '/login';
  static const _signup = '/signup';
  static const _chatList = '/chats';
  static const _settings = '/settings';
  static const _donate = '/donate';
  static const _wip = '/wip';
  static const _onboarding = '/onboarding';
  static const _developerSettings = '/developer-settings';
  static const _profileKeys = '/profile-keys';
  static const _shareProfile = '/share-profile';
  static const _editProfile = '/edit-profile';
  static const _invite = '/invites/:mlsGroupId';
  static const _chat = '/chats/:groupId';
  static const _publicRoutes = {_home, _login, _signup};

  static GoRouter build(WidgetRef ref) {
    return GoRouter(
      initialLocation: _home,
      observers: [routeObserver],
      redirect: (context, state) {
        final pubkey = ref.read(authProvider).value;
        final isOnPublicPage = _publicRoutes.contains(state.matchedLocation);

        if (pubkey == null && !isOnPublicPage) return _login;
        if (pubkey != null && isOnPublicPage) return _chatList;

        return null;
      },
      routes: [
        GoRoute(
          path: _home,
          pageBuilder: (context, state) => _navigationTransition(
            state: state,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: _login,
          pageBuilder: (context, state) => _navigationTransition(
            state: state,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: _signup,
          pageBuilder: (context, state) => _navigationTransition(
            state: state,
            child: const SignupScreen(),
          ),
        ),
        GoRoute(
          path: _chatList,
          pageBuilder: (context, state) => _navigationTransition(
            state: state,
            child: const ChatListScreen(),
          ),
        ),
        GoRoute(
          path: _settings,
          pageBuilder: (context, state) => _navigationTransition(
            state: state,
            child: const SettingsScreen(),
          ),
        ),
        GoRoute(
          path: _donate,
          pageBuilder: (context, state) => _navigationTransition(
            state: state,
            child: const DonateScreen(),
          ),
        ),
        GoRoute(
          path: _wip,
          pageBuilder: (context, state) => _navigationTransition(
            state: state,
            child: const WipScreen(),
          ),
        ),
        GoRoute(
          path: _onboarding,
          pageBuilder: (context, state) => _navigationTransition(
            state: state,
            child: const OnboardingScreen(),
          ),
        ),
        GoRoute(
          path: _developerSettings,
          pageBuilder: (context, state) => _navigationTransition(
            state: state,
            child: const DeveloperSettingsScreen(),
          ),
        ),
        GoRoute(
          path: _profileKeys,
          pageBuilder: (context, state) => _navigationTransition(
            state: state,
            child: const ProfileKeysScreen(),
          ),
        ),
        GoRoute(
          path: _shareProfile,
          pageBuilder: (context, state) => _navigationTransition(
            state: state,
            child: const ShareProfileScreen(),
          ),
        ),
        GoRoute(
          path: _editProfile,
          pageBuilder: (context, state) => _navigationTransition(
            state: state,
            child: const EditProfileScreen(),
          ),
        ),
        GoRoute(
          name: 'invite',
          path: _invite,
          pageBuilder: (context, state) => _navigationTransition(
            state: state,
            child: ChatInviteScreen(mlsGroupId: state.pathParameters['mlsGroupId']!),
          ),
        ),
        GoRoute(
          name: 'chat',
          path: _chat,
          pageBuilder: (context, state) => _navigationTransition(
            state: state,
            child: ChatScreen(groupId: state.pathParameters['groupId']!),
          ),
        ),
      ],
    );
  }

  static CustomTransitionPage<void> _navigationTransition({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      GoRouter.of(context).pop();
    } else {
      GoRouter.of(context).go(_home);
    }
  }

  static void goToHome(BuildContext context) {
    GoRouter.of(context).go(_home);
  }

  static void pushToHome(BuildContext context) {
    GoRouter.of(context).push(_home);
  }

  static void goToLogin(BuildContext context) {
    GoRouter.of(context).go(_login);
  }

  static void pushToLogin(BuildContext context) {
    GoRouter.of(context).push(_login);
  }

  static void goToSignup(BuildContext context) {
    GoRouter.of(context).go(_signup);
  }

  static void pushToSignup(BuildContext context) {
    GoRouter.of(context).push(_signup);
  }

  static void goToChatList(BuildContext context) {
    GoRouter.of(context).go(_chatList);
  }

  static void pushToChatList(BuildContext context) {
    GoRouter.of(context).push(_chatList);
  }

  static void pushToSettings(BuildContext context) {
    GoRouter.of(context).push(_settings);
  }

  static void pushToWip(BuildContext context) {
    GoRouter.of(context).push(_wip);
  }

  static void pushToDonate(BuildContext context) {
    GoRouter.of(context).push(_donate);
  }

  static void goToOnboarding(BuildContext context) {
    GoRouter.of(context).go(_onboarding);
  }

  static void pushToDeveloperSettings(BuildContext context) {
    GoRouter.of(context).push(_developerSettings);
  }

  static void pushToProfileKeys(BuildContext context) {
    GoRouter.of(context).push(_profileKeys);
  }

  static void pushToShareProfile(BuildContext context) {
    GoRouter.of(context).push(_shareProfile);
  }

  static void pushToEditProfile(BuildContext context) {
    GoRouter.of(context).push(_editProfile);
  }

  static void pushToInvite(BuildContext context, String mlsGroupId) {
    GoRouter.of(context).pushNamed('invite', pathParameters: {'mlsGroupId': mlsGroupId});
  }

  static void goToChat(BuildContext context, String groupId) {
    GoRouter.of(context).goNamed('chat', pathParameters: {'groupId': groupId});
  }
}
