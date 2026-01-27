import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'
    show useEffect, useScrollController, useTextEditingController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget, WidgetRef;
import 'package:sloth/hooks/use_signup.dart' show useSignup;
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/auth_provider.dart' show authProvider;
import 'package:sloth/providers/is_adding_account_provider.dart' show isAddingAccountProvider;
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_image_picker.dart' show WnImagePicker;
import 'package:sloth/widgets/wn_pixels_layer.dart' show WnPixelsLayer;
import 'package:sloth/widgets/wn_slate_container.dart' show WnSlateContainer;
import 'package:sloth/widgets/wn_text_form_field.dart' show WnTextFormField;

class SignupScreen extends HookConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final displayNameController = useTextEditingController();
    final bioController = useTextEditingController();
    final scrollController = useScrollController();
    final (:state, :submit, :onImageSelected, :clearErrors) = useSignup(
      () => ref.read(authProvider.notifier).signup(),
    );

    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    useEffect(() {
      if (keyboardHeight > 0 && scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        });
      }
      return null;
    }, [keyboardHeight]);

    Future<void> onSubmit() async {
      final wasAddingAccount = ref.read(isAddingAccountProvider);
      final success = await submit(
        displayName: displayNameController.text.trim(),
        bio: bioController.text.trim(),
      );
      if (success && context.mounted) {
        if (wasAddingAccount) {
          Routes.goToChatList(context);
        } else {
          Routes.goToOnboarding(context);
        }
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
              key: const Key('signup_background'),
              onTap: () => Routes.goBack(context),
              behavior: HitTestBehavior.opaque,
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: WnSlateContainer(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        spacing: 16.h,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            spacing: 4.w,
                            children: [
                              IconButton(
                                key: const Key('back_button'),
                                onPressed: () => Routes.goBack(context),
                                icon: WnIcon(
                                  WnIcons.chevronLeft,
                                  size: 24.sp,
                                  color: colors.backgroundContentTertiary,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  context.l10n.setupProfile,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: colors.backgroundContentTertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Center(
                            child: ValueListenableBuilder(
                              valueListenable: displayNameController,
                              builder: (context, value, child) {
                                return WnImagePicker(
                                  imagePath: state.selectedImagePath,
                                  displayName: value.text,
                                  onImageSelected: onImageSelected,
                                  loading: state.isLoading,
                                  disabled: state.isLoading,
                                );
                              },
                            ),
                          ),
                          WnTextFormField(
                            label: context.l10n.chooseName,
                            placeholder: context.l10n.enterYourName,
                            controller: displayNameController,
                            errorText: state.displayNameError,
                            onChanged: (_) => clearErrors(),
                          ),
                          WnTextFormField(
                            label: context.l10n.introduceYourself,
                            placeholder: context.l10n.writeSomethingAboutYourself,
                            controller: bioController,
                            maxLines: 3,
                            minLines: 3,
                            textInputAction: TextInputAction.done,
                          ),
                          Column(
                            spacing: 8.h,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              WnButton(
                                text: context.l10n.cancel,
                                type: WnButtonType.outline,
                                onPressed: () => Routes.goBack(context),
                                disabled: state.isLoading,
                              ),
                              WnButton(
                                text: context.l10n.signUp,
                                onPressed: onSubmit,
                                loading: state.isLoading,
                                disabled: state.isLoading,
                              ),
                            ],
                          ),
                        ],
                      ),
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
