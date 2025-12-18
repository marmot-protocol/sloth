import 'package:flutter/material.dart'
    show BuildContext, CurvedAnimation, Curves, FadeTransition, Widget;
import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;
import 'package:go_router/go_router.dart'
    show CustomTransitionPage, GoRouter, GoRoute, GoRouterState;
import 'package:sloth/providers/auth_provider.dart' show authProvider;
import 'package:sloth/screens/chat_list_screen.dart' show ChatListScreen;
import 'package:sloth/screens/donate_screen.dart' show DonateScreen;
import 'package:sloth/screens/home_screen.dart' show HomeScreen;
import 'package:sloth/screens/login_screen.dart' show LoginScreen;
import 'package:sloth/screens/onboarding_screen.dart' show OnboardingScreen;
import 'package:sloth/screens/settings_screen.dart' show SettingsScreen;
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
  static const _publicRoutes = {_home, _login, _signup};

  static GoRouter build(WidgetRef ref) {
    return GoRouter(
      initialLocation: _home,
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
    GoRouter.of(context).pop();
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
}
