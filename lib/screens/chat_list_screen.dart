import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/hooks/use_route_refresh.dart';
import 'package:sloth/hooks/use_welcomes.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/src/rust/api/welcomes.dart' show Welcome;
import 'package:sloth/widgets/chat_list_welcome_tile.dart';
import 'package:sloth/widgets/wn_account_bar.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class ChatListScreen extends HookConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final welcomesResult = useWelcomes(pubkey);

    useRouteRefresh(context, welcomesResult.refresh);

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const WnSlateContainer(child: WnAccountBar()),
            Expanded(
              child: _buildContent(
                context,
                welcomesResult.snapshot,
                welcomesResult.refresh,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AsyncSnapshot<List<Welcome>> welcomesSnapshot,
    VoidCallback onRefresh,
  ) {
    final colors = context.colors;

    final welcomes = welcomesSnapshot.data ?? [];

    if (welcomes.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh(),
        color: colors.foregroundPrimary,
        backgroundColor: colors.backgroundTertiary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No chats yet',
                        style: TextStyle(
                          color: colors.foregroundPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(
                          color: colors.foregroundTertiary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: colors.foregroundPrimary,
      backgroundColor: colors.backgroundTertiary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: welcomes.length,
        itemBuilder: (context, index) {
          final welcome = welcomes[index];
          return ChatListWelcomeTile(
            welcome: welcome,
            onTap: () {
              Routes.pushToWelcome(context, welcome.id);
            },
          );
        },
      ),
    );
  }
}
