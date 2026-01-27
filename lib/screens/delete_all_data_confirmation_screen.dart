import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/src/rust/api.dart' as rust_api;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class DeleteAllDataConfirmationScreen extends HookConsumerWidget {
  const DeleteAllDataConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDeleting = useState(false);

    Future<void> deleteAllAppData() async {
      isDeleting.value = true;
      try {
        await rust_api.deleteAllData();
        final storage = ref.read(secureStorageProvider);
        await storage.deleteAll();
        ref.invalidate(authProvider);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Routes.goToHome(context);
          }
        });
      } catch (e) {
        isDeleting.value = false;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.deleteAllAppDataFailed)),
          );
        }
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
                WnScreenHeader(
                  title: context.l10n.deleteAllAppDataConfirmation,
                ),
                Gap(12.h),
                Text(
                  context.l10n.deleteAllAppDataWarning,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                    color: colors.backgroundContentPrimary,
                  ),
                ),
                Gap(20.h),
                SizedBox(
                  width: double.infinity,
                  child: WnButton(
                    key: const Key('cancel_button'),
                    text: context.l10n.cancel,
                    type: WnButtonType.outline,
                    size: WnButtonSize.medium,
                    onPressed: () => Routes.goBack(context),
                  ),
                ),
                Gap(8.h),
                SizedBox(
                  width: double.infinity,
                  child: WnButton(
                    key: const Key('confirm_delete_button'),
                    text: context.l10n.deleteAppData,
                    type: WnButtonType.destructive,
                    size: WnButtonSize.medium,
                    loading: isDeleting.value,
                    onPressed: deleteAllAppData,
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
