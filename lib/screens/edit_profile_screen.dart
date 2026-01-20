import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_edit_profile.dart' show EditProfileLoadingState, useEditProfile;
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_filled_button.dart';
import 'package:sloth/widgets/wn_image_picker.dart';
import 'package:sloth/widgets/wn_outlined_button.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';
import 'package:sloth/widgets/wn_text_form_field.dart';
import 'package:sloth/widgets/wn_warning_box.dart';

class EditProfileScreen extends HookConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final (
      :state,
      :displayNameController,
      :aboutController,
      :nip05Controller,
      :loadProfile,
      :onImageSelected,
      :updateProfileData,
      :discardChanges,
    ) = useEditProfile(
      pubkey,
    );

    useEffect(() {
      loadProfile();
      return null;
    }, []);

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlateContainer(
            child: Column(
              spacing: 16.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WnScreenHeader(title: 'Edit profile'),
                if (state.error != null)
                  Center(
                    child: Text(
                      state.currentMetadata == null
                          ? 'Error loading profile: ${state.error}'
                          : 'Error: ${state.error}',
                      style: TextStyle(color: colors.fillDestructive),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Gap(16.h),
                            Center(
                              child: WnImagePicker(
                                imagePath: state.pictureUrl,
                                displayName: state.displayName ?? '',
                                onImageSelected: onImageSelected,
                                loading: state.loadingState == EditProfileLoadingState.saving,
                                disabled: state.loadingState == EditProfileLoadingState.saving,
                              ),
                            ),
                            Gap(36.h),
                            WnTextFormField(
                              label: 'Profile name',
                              placeholder: 'Enter your name',
                              controller: displayNameController,
                            ),
                            Gap(36.h),
                            WnTextFormField(
                              label: 'Nostr address',
                              placeholder: 'example@whitenoise.chat',
                              controller: nip05Controller,
                            ),
                            Gap(36.h),
                            WnTextFormField(
                              label: 'About you',
                              placeholder: 'Write something about yourself',
                              controller: aboutController,
                              maxLines: 3,
                              minLines: 3,
                            ),
                            Gap(36.h),
                            WnWarningBox(
                              title: 'Profile is public',
                              description:
                                  'Your profile information will be visible to everyone on the network.',
                              backgroundColor: colors.fillContentPrimary.withValues(alpha: 0.1),
                              borderColor: colors.borderPrimary,
                              iconColor: colors.backgroundContentPrimary,
                              titleColor: colors.backgroundContentPrimary,
                              descriptionColor: colors.backgroundContentTertiary,
                              icon: Icons.info_outline,
                            ),
                            Gap(16.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (state.loadingState != EditProfileLoadingState.loading && state.error == null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      spacing: 8.h,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.hasUnsavedChanges)
                          WnOutlinedButton(
                            text: 'Discard changes',
                            onPressed: () {
                              discardChanges();
                            },
                            disabled: state.loadingState == EditProfileLoadingState.saving,
                          ),
                        WnFilledButton(
                          text: 'Save',
                          onPressed:
                              state.hasUnsavedChanges &&
                                  state.loadingState != EditProfileLoadingState.saving
                              ? () async {
                                  final success = await updateProfileData();
                                  if (context.mounted && success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Profile updated successfully'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          loading: state.loadingState == EditProfileLoadingState.saving,
                        ),
                      ],
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
