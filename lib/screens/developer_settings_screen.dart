import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useEffect, useState;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_key_packages.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/src/rust/api/accounts.dart' show FlutterEvent;
import 'package:sloth/theme.dart';
import 'package:sloth/theme/app_typography.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_key_package_card.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';
import 'package:sloth/widgets/wn_system_notice.dart';

class DeveloperSettingsScreen extends HookConsumerWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typographyScaled;
    final pubkey = ref.watch(accountPubkeyProvider);
    final (:state, :fetch, :publish, :delete, :deleteAll) = useKeyPackages(pubkey);

    final noticeMessage = useState<String?>(null);
    final noticeType = useState<WnSystemNoticeType>(WnSystemNoticeType.success);

    void showNotice(String message, {bool isError = false}) {
      noticeMessage.value = message;
      noticeType.value = isError ? WnSystemNoticeType.error : WnSystemNoticeType.success;
    }

    void dismissNotice() {
      noticeMessage.value = null;
    }

    String getSuccessMessage(KeyPackageAction action) {
      return switch (action) {
        KeyPackageAction.fetch => context.l10n.keyPackagesRefreshed,
        KeyPackageAction.publish => context.l10n.keyPackagePublished,
        KeyPackageAction.delete => context.l10n.keyPackageDeleted,
        KeyPackageAction.deleteAll => context.l10n.keyPackagesDeleted,
      };
    }

    Future<void> handleAction(Future<KeyPackageResult> Function() action) async {
      try {
        final result = await action();
        if (context.mounted) {
          if (result.success) {
            showNotice(getSuccessMessage(result.action));
          } else if (state.error != null) {
            showNotice(state.error!, isError: true);
          }
        }
      } catch (e) {
        if (context.mounted) {
          showNotice(context.l10n.error(e.toString()), isError: true);
        }
      }
    }

    Future<void> handleDelete(String id) async {
      final result = await delete(id);
      if (context.mounted && result.success) {
        showNotice(getSuccessMessage(result.action));
      }
    }

    useEffect(() {
      fetch();
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlate(
            header: WnSlateNavigationHeader(
              title: context.l10n.developerSettingsTitle,
              type: WnSlateNavigationType.back,
              onNavigate: () => Routes.goBack(context),
            ),
            systemNotice: noticeMessage.value != null
                ? WnSystemNotice(
                    key: ValueKey(noticeMessage.value),
                    title: noticeMessage.value!,
                    type: noticeType.value,
                    onDismiss: dismissNotice,
                  )
                : null,
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  _ActionButtons(
                    isLoading: state.isLoading,
                    onPublish: () => handleAction(publish),
                    onFetch: () => handleAction(fetch),
                    onDeleteAll: () => handleAction(deleteAll),
                  ),
                  if (state.error != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      state.error!,
                      style: typography.medium14.copyWith(
                        color: colors.fillDestructive,
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  Text(
                    context.l10n.keyPackagesCount(state.packages.length),
                    style: typography.semiBold14.copyWith(
                      color: colors.backgroundContentPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: state.isLoading && state.packages.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(
                              strokeCap: StrokeCap.round,
                              color: colors.backgroundContentPrimary,
                            ),
                          )
                        : _KeyPackagesList(
                            packages: state.packages,
                            onDelete: handleDelete,
                            disabled: state.isLoading,
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

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isLoading,
    required this.onPublish,
    required this.onFetch,
    required this.onDeleteAll,
  });

  final bool isLoading;
  final VoidCallback onPublish;
  final VoidCallback onFetch;
  final VoidCallback onDeleteAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.h,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WnButton(
          text: context.l10n.publishNewKeyPackage,
          onPressed: onPublish,
          disabled: isLoading,
          size: WnButtonSize.medium,
        ),
        WnButton(
          text: context.l10n.refreshKeyPackages,
          onPressed: onFetch,
          disabled: isLoading,
          size: WnButtonSize.medium,
        ),
        WnButton(
          text: context.l10n.deleteAllKeyPackages,
          onPressed: onDeleteAll,
          disabled: isLoading,
          size: WnButtonSize.medium,
        ),
      ],
    );
  }
}

class _KeyPackagesList extends StatelessWidget {
  const _KeyPackagesList({
    required this.packages,
    required this.onDelete,
    required this.disabled,
  });

  final List<FlutterEvent> packages;
  final void Function(String id) onDelete;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typographyScaled;

    if (packages.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noKeyPackagesFound,
          style: typography.medium14.copyWith(
            color: colors.backgroundContentTertiary,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: packages.length,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final package = packages[index];
        return WnKeyPackageCard(
          key: Key('key_package_card_${package.id}'),
          title: context.l10n.packageNumber(index + 1),
          packageId: package.id,
          createdAt: package.createdAt.toIso8601String(),
          onDelete: () => onDelete(package.id),
          disabled: disabled,
          deleteButtonKey: Key('delete_key_package_${package.id}'),
        );
      },
    );
  }
}
