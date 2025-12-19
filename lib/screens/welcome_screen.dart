import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/error_screen.dart';
import 'package:sloth/src/rust/api/welcomes.dart' as welcomes_api;
import 'package:sloth/widgets/wn_animated_avatar.dart';
import 'package:sloth/widgets/wn_filled_button.dart';
import 'package:sloth/widgets/wn_outlined_button.dart';
import 'package:sloth/widgets/wn_screen_header.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class WelcomeScreen extends HookConsumerWidget {
  final String welcomeId;

  const WelcomeScreen({super.key, required this.welcomeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);

    final welcomeSnapshot = useFuture(
      useMemoized(
        () => welcomes_api.findWelcomeByEventId(
          pubkey: pubkey,
          welcomeEventId: welcomeId,
        ),
        [welcomeId, pubkey],
      ),
    );

    final isAccepting = useState(false);
    final isDeclining = useState(false);
    final isProcessing = isAccepting.value || isDeclining.value;

    if (welcomeSnapshot.connectionState == ConnectionState.waiting) {
      return Scaffold(
        backgroundColor: colors.backgroundPrimary,
        body: Center(
          child: CircularProgressIndicator(
            key: const Key('welcome_loading_indicator'),
            color: colors.foregroundPrimary,
          ),
        ),
      );
    }

    final welcome = welcomeSnapshot.data;
    if (welcomeSnapshot.hasError || welcome == null) {
      return const ErrorScreen(
        title: 'Invitation not found',
        description:
            'We couldn\'t find the invitation you were looking for. Please go back and try again.',
      );
    }

    Future<void> handleAccept() async {
      isAccepting.value = true;
      try {
        await welcomes_api.acceptWelcome(
          pubkey: pubkey,
          welcomeEventId: welcomeId,
        );
        if (context.mounted) {
          Routes.goToChatList(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to accept invitation: $e')),
          );
        }
      } finally {
        isAccepting.value = false;
      }
    }

    Future<void> handleDecline() async {
      isDeclining.value = true;
      try {
        await welcomes_api.declineWelcome(
          pubkey: pubkey,
          welcomeEventId: welcomeId,
        );
        if (context.mounted) {
          Routes.goToChatList(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to decline invitation: $e')),
          );
        }
      } finally {
        isDeclining.value = false;
      }
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: WnSlateContainer(
            child: Column(
              children: [
                const WnScreenHeader(title: 'Chat Invitation'),
                Expanded(
                  child: Center(
                    child: _InviteContent(welcome: welcome),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12.h,
                  children: [
                    WnOutlinedButton(
                      text: 'Decline',
                      loading: isDeclining.value,
                      disabled: isProcessing,
                      onPressed: handleDecline,
                    ),
                    WnFilledButton(
                      text: 'Accept',
                      loading: isAccepting.value,
                      disabled: isProcessing,
                      onPressed: handleAccept,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InviteContent extends HookWidget {
  final welcomes_api.Welcome welcome;

  const _InviteContent({required this.welcome});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final welcomerMetadata = useUserMetadata(context, welcome.welcomer).data;

    final welcomerName = welcomerMetadata?.displayName ?? welcomerMetadata?.name;
    final hasGroupName = welcome.groupName.isNotEmpty;

    final String avatarDisplayName;
    final String? avatarPictureUrl;
    final String title;
    final String subtitle;

    if (hasGroupName) {
      avatarDisplayName = welcome.groupName;
      avatarPictureUrl = null;
      title = welcome.groupName;
      subtitle = welcomerName != null ? '$welcomerName invited you' : 'You were invited to join';
    } else {
      avatarDisplayName = welcomerName ?? '';
      avatarPictureUrl = welcomerMetadata?.picture;
      title = welcomerName ?? 'Unknown User';
      subtitle = 'Invited you to a secure chat';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WnAnimatedAvatar(
          pictureUrl: avatarPictureUrl,
          displayName: avatarDisplayName,
          size: 80.w,
        ),
        SizedBox(height: 16.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: colors.foregroundPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14.sp,
            color: colors.foregroundTertiary,
          ),
          textAlign: TextAlign.center,
        ),
        if (hasGroupName && welcome.groupDescription.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Text(
            welcome.groupDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: colors.foregroundPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (hasGroupName) ...[
          SizedBox(height: 12.h),
          Text(
            '${welcome.memberCount} members',
            style: TextStyle(
              fontSize: 12.sp,
              color: colors.foregroundTertiary,
            ),
          ),
        ],
        SizedBox(height: 8.h),
      ],
    );
  }
}
