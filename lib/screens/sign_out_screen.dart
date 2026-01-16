import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/hooks/use_nsec.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/widgets/wn_filled_button.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';
import 'package:sloth/widgets/wn_text_form_field.dart';
import 'package:sloth/widgets/wn_warning_box.dart';

class SignOutScreen extends HookConsumerWidget {
  const SignOutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(authProvider).value;

    if (pubkey == null) {
      return const SizedBox.shrink();
    }
    final (:state, :loadNsec) = useNsec(pubkey);
    final obscurePrivateKey = useState(true);
    final privateKeyController = useTextEditingController();
    final isLoggingOut = useState(false);

    useEffect(() {
      loadNsec();
      return () {
        privateKeyController.clear();
      };
    }, [pubkey]);

    useEffect(() {
      if (state.nsec != null) {
        privateKeyController.text = state.nsec!;
      } else {
        privateKeyController.clear();
      }
      return null;
    }, [state.nsec]);

    void copyPrivateKey() {
      final nsec = state.nsec;
      if (nsec != null) {
        Clipboard.setData(ClipboardData(text: nsec));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Private key copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    void togglePrivateKeyVisibility() {
      obscurePrivateKey.value = !obscurePrivateKey.value;
    }

    Future<void> signOut() async {
      isLoggingOut.value = true;
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        Routes.goToHome(context);
      }
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
                const WnScreenHeader(title: 'Sign out'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(24.h),
                          const WnWarningBox(
                            title: 'Are you sure you want to sign out?',
                            description:
                                'When you sign out of White Noise, your chats will be deleted from this device and cannot be restored on another device.\n\nIf you haven\'t backed up your private key, you won\'t be able to use this profile on any other Nostr service.',
                          ),
                          Gap(24.h),
                          Text(
                            'Back up your private key',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: colors.foregroundPrimary,
                            ),
                          ),
                          Gap(8.h),
                          Text(
                            'Copy your private key to restore your account on another device.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: colors.foregroundTertiary,
                            ),
                          ),
                          Gap(16.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: WnTextFormField(
                                  label: 'Private key',
                                  placeholder: '',
                                  controller: privateKeyController,
                                  readOnly: true,
                                  obscureText: obscurePrivateKey.value,
                                  suffixIcon: IconButton(
                                    onPressed: togglePrivateKeyVisibility,
                                    icon: Icon(
                                      obscurePrivateKey.value
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 20.w,
                                      color: colors.foregroundPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              Gap(4.w),
                              Padding(
                                padding: EdgeInsets.only(bottom: 4.h),
                                child: IconButton(
                                  onPressed: copyPrivateKey,
                                  icon: Icon(
                                    Icons.copy,
                                    color: colors.foregroundPrimary,
                                    size: 20.w,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: colors.backgroundPrimary,
                                    minimumSize: Size(44.w, 44.h),
                                    padding: EdgeInsets.all(14.w),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Gap(32.h),
                          SizedBox(
                            width: double.infinity,
                            child: WnFilledButton(
                              text: 'Sign out',
                              onPressed: signOut,
                              loading: isLoggingOut.value,
                            ),
                          ),
                          Gap(24.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
