import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useEffect;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/hooks/use_key_packages.dart';
import 'package:sloth/src/rust/api/accounts.dart' show FlutterEvent;
import 'package:sloth/widgets/wn_filled_button.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class DeveloperSettingsScreen extends HookConsumerWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final (:state, :fetch, :publish, :delete, :deleteAll) = useKeyPackages(ref);

    useEffect(() {
      fetch();
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlateContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WnScreenHeader(title: 'Developer Settings'),
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
                    style: TextStyle(color: colors.error, fontSize: 14.sp),
                  ),
                ],
                SizedBox(height: 16.h),
                Text(
                  'Key Packages (${state.packages.length})',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.foregroundPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: state.isLoading && state.packages.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(
                            strokeCap: StrokeCap.round,
                            color: colors.foregroundPrimary,
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
        WnFilledButton(
          text: 'Publish New Key Package',
          onPressed: onPublish,
          disabled: isLoading,
        ),
        WnFilledButton(
          text: 'Refresh Key Packages',
          onPressed: onFetch,
          disabled: isLoading,
        ),
        WnFilledButton(
          text: 'Delete All Key Packages',
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
          'No key packages found',
          style: TextStyle(
            fontSize: 14.sp,
            color: colors.foregroundTertiary,
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
        border: Border.all(color: colors.foregroundTertiary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Package ${index + 1}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.foregroundPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  package.id,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colors.foregroundTertiary,
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
            icon: Icon(
              Icons.delete_outline,
              color: disabled ? colors.foregroundTertiary : colors.error,
            ),
            iconSize: 20.w,
          ),
        ],
      ),
    );
  }
}
