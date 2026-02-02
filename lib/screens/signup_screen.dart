import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'
    show useEffect, useScrollController, useTextEditingController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget, WidgetRef;
import 'package:sloth/hooks/use_image_picker.dart';
import 'package:sloth/hooks/use_signup.dart' show useSignup;
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/auth_provider.dart' show authProvider;
import 'package:sloth/providers/is_adding_account_provider.dart' show isAddingAccountProvider;
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_avatar.dart' show WnAvatar, WnAvatarSize;
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_input.dart' show WnInput;
import 'package:sloth/widgets/wn_input_text_area.dart' show WnInputTextArea;
import 'package:sloth/widgets/wn_pixels_layer.dart' show WnPixelsLayer;
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';

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
    final (:pickImage, error: imagePickerError, clearError: clearImagePickerError) = useImagePicker(
      onImageSelected: onImageSelected,
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

    useEffect(() {
      if (imagePickerError != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.imagePickerError)),
            );
          }
        });
        clearImagePickerError();
      }
      return null;
    }, [imagePickerError]);

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
                  child: WnSlate(
                    header: WnSlateNavigationHeader(
                      title: context.l10n.setupProfile,
                      type: WnSlateNavigationType.back,
                      onNavigate: () => Routes.goBack(context),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                        child: Column(
                          spacing: 16.h,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: ValueListenableBuilder(
                                valueListenable: displayNameController,
                                builder: (context, value, child) {
                                  return WnAvatar(
                                    pictureUrl: state.selectedImagePath,
                                    displayName: value.text,
                                    size: WnAvatarSize.large,
                                    onEditTap: state.isLoading ? null : pickImage,
                                  );
                                },
                              ),
                            ),
                            WnInput(
                              label: context.l10n.chooseName,
                              placeholder: context.l10n.enterYourName,
                              controller: displayNameController,
                              errorText: state.displayNameError,
                              onChanged: (_) => clearErrors(),
                            ),
                            WnInputTextArea(
                              label: context.l10n.introduceYourself,
                              placeholder: context.l10n.writeSomethingAboutYourself,
                              controller: bioController,
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
                                  size: WnButtonSize.medium,
                                ),
                                WnButton(
                                  text: context.l10n.signUp,
                                  onPressed: onSubmit,
                                  loading: state.isLoading,
                                  disabled: state.isLoading,
                                  size: WnButtonSize.medium,
                                ),
                              ],
                            ),
                          ],
                        ),
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
