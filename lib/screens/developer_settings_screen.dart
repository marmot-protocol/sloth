import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useEffect;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_key_packages.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/src/rust/api/accounts.dart' show FlutterEvent;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_icon.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';

class DeveloperSettingsScreen extends HookConsumerWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final (:state, :fetch, :publish, :delete, :deleteAll) = useKeyPackages(pubkey);

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
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  _ActionButtons(
                    isLoading: state.isLoading,
                    onPublish: publish,
                    onFetch: fetch,
                    onDeleteAll: deleteAll,
                  ),
                  if (state.error != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      state.error!,
                      style: TextStyle(color: colors.fillDestructive, fontSize: 14.sp),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  Text(
                    context.l10n.keyPackagesCount(state.packages.length),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
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
                            onDelete: delete,
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
        ),
        WnButton(
          text: context.l10n.refreshKeyPackages,
          onPressed: onFetch,
          disabled: isLoading,
        ),
        WnButton(
          text: context.l10n.deleteAllKeyPackages,
          onPressed: onDeleteAll,
          disabled: isLoading,
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

    if (packages.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noKeyPackagesFound,
          style: TextStyle(
            fontSize: 14.sp,
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
        return _KeyPackageTile(
          package: package,
          index: index,
          onDelete: () => onDelete(package.id),
          disabled: disabled,
        );
      },
    );
  }
}

class _KeyPackageTile extends StatelessWidget {
  const _KeyPackageTile({
    required this.package,
    required this.index,
    required this.onDelete,
    required this.disabled,
  });

  final FlutterEvent package;
  final int index;
  final VoidCallback onDelete;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.borderTertiary),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.packageNumber(index + 1),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.backgroundContentPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  package.id,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colors.backgroundContentSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            key: Key('delete_key_package_${package.id}'),
            onPressed: disabled ? null : onDelete,
            icon: WnIcon(
              WnIcons.trashCan,
              size: 20.w,
              color: disabled ? colors.backgroundContentTertiary : colors.fillDestructive,
            ),
          ),
        ],
      ),
    );
  }
}
