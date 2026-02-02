import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/is_adding_account_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_auth_buttons_container.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';

class AddProfileScreen extends ConsumerWidget {
  const AddProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    void navigateToLogin() {
      ref.read(isAddingAccountProvider.notifier).set(true);
      Routes.pushToLogin(context);
    }

    void navigateToSignup() {
      ref.read(isAddingAccountProvider.notifier).set(true);
      Routes.pushToSignup(context);
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlate(
            header: WnSlateNavigationHeader(
              title: context.l10n.addNewProfile,
              onNavigate: () => Routes.goBack(context),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  WnAuthButtonsContainer(
                    onLogin: navigateToLogin,
                    onSignup: navigateToSignup,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
