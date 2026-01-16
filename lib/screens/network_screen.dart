import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/hooks/use_network_relays.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/widgets/wn_add_relay_bottom_sheet.dart';
import 'package:sloth/widgets/wn_relay_tile.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class NetworkScreen extends HookConsumerWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final (:state, :fetchAll, :addRelay, :removeRelay) = useNetworkRelays(pubkey);

    useEffect(() {
      fetchAll();
      return null;
    }, const []);

    void showAddRelaySheet(RelayCategory category) {
      WnAddRelayBottomSheet.show(
        context: context,
        onRelayAdded: (url) => addRelay(url, category),
      );
    }

    Widget buildSectionHeader({
      required String title,
      required String helpMessage,
      required Key infoIconKey,
      required Key addIconKey,
      required VoidCallback onAdd,
    }) {
      return Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: colors.foregroundTertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Gap(8.w),
                Tooltip(
                  message: helpMessage,
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: const Duration(minutes: 1),
                  preferBelow: true,
                  verticalOffset: 20.h,
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  textStyle: TextStyle(
                    fontSize: 12.sp,
                    color: colors.foregroundSecondary,
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      key: infoIconKey,
                      Icons.info_outline,
                      color: colors.foregroundTertiary,
                      size: 18.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                key: addIconKey,
                Icons.add,
                color: colors.foregroundPrimary,
                size: 23.w,
              ),
            ),
          ),
        ],
      );
    }

    Widget buildRelayList(RelayListState relayState, RelayCategory category) {
      if (relayState.isLoading && relayState.relays.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (relayState.error != null && relayState.relays.isEmpty) {
        return Center(
          child: Text(
            'Error loading relays',
            style: TextStyle(color: colors.error),
          ),
        );
      }

      if (relayState.relays.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text(
              'No relays configured',
              style: TextStyle(
                fontSize: 14.sp,
                color: colors.foregroundTertiary,
              ),
            ),
          ),
        );
      }

      return Column(
        children: relayState.relays.map((relay) {
          final status = state.relayStatuses[relay.url];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: WnRelayTile(
              relay: relay,
              status: status,
              onDelete: () => removeRelay(relay.url, category),
            ),
          );
        }).toList(),
      );
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlateContainer(
            child: Column(
              children: [
                const WnScreenHeader(title: 'Network Relays'),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(top: 16.h),
                    children: [
                      RepaintBoundary(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildSectionHeader(
                              title: 'My Relays',
                              helpMessage:
                                  'Relays you have defined for use across all your Nostr applications.',
                              infoIconKey: const Key('info_icon_my_relays'),
                              addIconKey: const Key('add_icon_my_relays'),
                              onAdd: () => showAddRelaySheet(RelayCategory.normal),
                            ),
                            Gap(12.h),
                            buildRelayList(state.normalRelays, RelayCategory.normal),
                          ],
                        ),
                      ),
                      Gap(16.h),
                      RepaintBoundary(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildSectionHeader(
                              title: 'Inbox Relays',
                              helpMessage:
                                  'Relays used to receive invitations and start secure conversations with new users.',
                              infoIconKey: const Key('info_icon_inbox_relays'),
                              addIconKey: const Key('add_icon_inbox_relays'),
                              onAdd: () => showAddRelaySheet(RelayCategory.inbox),
                            ),
                            Gap(12.h),
                            buildRelayList(state.inboxRelays, RelayCategory.inbox),
                          ],
                        ),
                      ),
                      Gap(16.h),
                      RepaintBoundary(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildSectionHeader(
                              title: 'Key Package Relays',
                              helpMessage:
                                  'Relays that store your secure key so others can invite you to encrypted conversations.',
                              infoIconKey: const Key('info_icon_key_package_relays'),
                              addIconKey: const Key('add_icon_key_package_relays'),
                              onAdd: () => showAddRelaySheet(RelayCategory.keyPackage),
                            ),
                            Gap(12.h),
                            buildRelayList(state.keyPackageRelays, RelayCategory.keyPackage),
                          ],
                        ),
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
