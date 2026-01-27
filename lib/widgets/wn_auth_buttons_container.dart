import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/widgets/wn_button.dart';

class WnAuthButtonsContainer extends StatelessWidget {
  const WnAuthButtonsContainer({
    super.key,
    this.onLogin,
    this.onSignup,
  });

  final VoidCallback? onLogin;
  final VoidCallback? onSignup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WnButton(
          text: 'Login',
          type: WnButtonType.outline,
          onPressed: onLogin ?? () => Routes.pushToLogin(context),
        ),
        Gap(8.h),
        WnButton(
          text: 'Sign Up',
          onPressed: onSignup ?? () => Routes.pushToSignup(context),
        ),
      ],
    );
  }
}
