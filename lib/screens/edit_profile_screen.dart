import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sloth/hooks/use_edit_profile.dart' show EditProfileLoadingState, useEditProfile;
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_image_picker.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';
import 'package:sloth/widgets/wn_text_form_field.dart';
import 'package:sloth/widgets/wn_warning_box.dart';

final _logger = Logger('EditProfileScreen');

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
          child: WnSlate(
            header: WnSlateNavigationHeader(
              title: context.l10n.editProfile,
              onNavigate: () => Routes.goBack(context),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.w),
              child: Column(
                spacing: 16.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.error != null)
                    Builder(
                      builder: (context) {
                        _logger.warning('Profile error: ${state.error}');
                        final message = state.currentMetadata == null
                            ? context.l10n.profileLoadError
                            : context.l10n.profileSaveError;
                        return Center(
                          child: Text(
                            message,
                            style: TextStyle(color: colors.fillDestructive),
                          ),
                        );
                      },
                    )
                  else
                    Padding(
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
                            label: context.l10n.profileName,
                            placeholder: context.l10n.enterYourName,
                            controller: displayNameController,
                          ),
                          Gap(36.h),
                          WnTextFormField(
                            label: context.l10n.nostrAddress,
                            placeholder: 'example@whitenoise.chat',
                            controller: nip05Controller,
                          ),
                          Gap(36.h),
                          WnTextFormField(
                            label: context.l10n.aboutYou,
                            placeholder: context.l10n.writeSomethingAboutYourself,
                            controller: aboutController,
                            maxLines: 3,
                            minLines: 3,
                          ),
                          Gap(36.h),
                          WnWarningBox(
                            title: context.l10n.profileIsPublic,
                            description: context.l10n.profilePublicDescription,
                            backgroundColor: colors.backgroundTertiary,
                            borderColor: colors.borderPrimary,
                            iconColor: colors.backgroundContentPrimary,
                            titleColor: colors.backgroundContentPrimary,
                            descriptionColor: colors.backgroundContentTertiary,
                            icon: WnIcons.information,
                          ),
                          Gap(16.h),
                        ],
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
                            WnButton(
                              text: context.l10n.discardChanges,
                              type: WnButtonType.outline,
                              onPressed: () {
                                discardChanges();
                              },
                              disabled: state.loadingState == EditProfileLoadingState.saving,
                            ),
                          WnButton(
                            text: context.l10n.save,
                            onPressed:
                                state.hasUnsavedChanges &&
                                    state.loadingState != EditProfileLoadingState.saving
                                ? () async {
                                    final success = await updateProfileData();
                                    if (context.mounted && success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(context.l10n.profileUpdatedSuccessfully),
                                          duration: const Duration(seconds: 2),
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
      ),
    );
  }
}
