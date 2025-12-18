import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/widgets/wn_account_bar.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class ChatListScreen extends HookConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: const SafeArea(
        child: Column(
          children: [
            WnSlateContainer(child: WnAccountBar()),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
