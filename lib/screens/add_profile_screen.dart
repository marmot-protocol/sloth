import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_auth_buttons_container.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

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
          child: WnSlateContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WnScreenHeader(title: 'Add a New Profile'),
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
    );
  }
}
