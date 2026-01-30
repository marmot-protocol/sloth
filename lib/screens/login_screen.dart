import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget, WidgetRef;
import 'package:sloth/hooks/use_login.dart' show useLogin;
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/auth_provider.dart' show authProvider;
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_pixels_layer.dart' show WnPixelsLayer;
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';
import 'package:sloth/widgets/wn_text_form_field.dart' show WnTextFormField;

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final (:controller, :state, :paste, :submit, :clearError) = useLogin(
      (nsec) => ref.read(authProvider.notifier).login(nsec),
    );

    Future<void> onSubmit() async {
      final success = await submit();
      if (success && context.mounted) {
        Routes.goToChatList(context);
      }
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          WnPixelsLayer(isAnimating: state.isLoading),
          Positioned.fill(
            child: GestureDetector(
              key: const Key('login_background'),
              onTap: () => Routes.goBack(context),
              behavior: HitTestBehavior.opaque,
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                WnSlate(
                  header: WnSlateNavigationHeader(
                    title: context.l10n.loginTitle,
                    type: WnSlateNavigationType.back,
                    onNavigate: () => Routes.goBack(context),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.w),
                    child: Column(
                      spacing: 8.h,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WnTextFormField(
                          label: context.l10n.enterPrivateKey,
                          placeholder: context.l10n.nsecPlaceholder,
                          controller: controller,
                          autofocus: true,
                          obscureText: true,
                          errorText: state.error,
                          onChanged: (_) => clearError(),
                          onPaste: paste,
                        ),
                        WnButton(
                          text: context.l10n.login,
                          onPressed: onSubmit,
                          loading: state.isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
                Gap(16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
