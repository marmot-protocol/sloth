use crate::api::error::ApiError;
use crate::api::groups::GroupType;
use crate::api::messages::ChatMessageSummary;
use crate::api::utils::group_id_to_string;
use crate::frb_generated::StreamSink;
use chrono::{DateTime, Utc};
use flutter_rust_bridge::frb;
use nostr_sdk::PublicKey;
use whitenoise::whitenoise::chat_list::ChatListItem as WhitenoiseChatListItem;
use whitenoise::{
    ChatListUpdate as WhitenoiseChatListUpdate,
    ChatListUpdateTrigger as WhitenoiseChatListUpdateTrigger, Whitenoise,
};

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct ChatSummary {
    /// MLS group identifier (hex string)
    pub mls_group_id: String,
    /// Display name for this chat:
    /// - Groups: The group name (may be empty)
    /// - DMs: The other user's display name (None if no metadata)
    pub name: Option<String>,
    /// Type of chat: Group or DirectMessage
    pub group_type: GroupType,
    /// When this group was created
    pub created_at: DateTime<Utc>,
    /// Path to cached decrypted group image (Groups only)
    pub group_image_path: Option<String>,
    /// Profile picture URL of the other user (DMs only)
    pub group_image_url: Option<String>,
    /// Preview of the last message (None if no messages)
    pub last_message: Option<ChatMessageSummary>,
    /// Whether the group is pending user confirmation
    pub pending_confirmation: bool,
    /// Public key (hex) of the user who invited this account to the group.
    /// `Some` when invited by another user, `None` when the user created the group.
    pub welcomer_pubkey: Option<String>,
}

impl From<WhitenoiseChatListItem> for ChatSummary {
    fn from(item: WhitenoiseChatListItem) -> Self {
        Self {
            mls_group_id: group_id_to_string(&item.mls_group_id),
            name: item.name,
            group_type: item.group_type.into(),
            created_at: item.created_at,
            group_image_path: item
                .group_image_path
                .map(|p| p.to_string_lossy().to_string()),
            group_image_url: item.group_image_url,
            last_message: item.last_message.map(|m| m.into()),
            pending_confirmation: item.pending_confirmation,
            welcomer_pubkey: item.welcomer_pubkey.map(|pk| pk.to_hex()),
        }
    }
}

/// What triggered a chat list update in the stream.
#[frb]
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ChatListUpdateTrigger {
    /// A new group was created or joined
    NewGroup,
    /// A new message updated the chat's last message preview
    NewLastMessage,
    /// The last message in a chat was deleted
    LastMessageDeleted,
}

impl From<WhitenoiseChatListUpdateTrigger> for ChatListUpdateTrigger {
    fn from(trigger: WhitenoiseChatListUpdateTrigger) -> Self {
        match trigger {
            WhitenoiseChatListUpdateTrigger::NewGroup => Self::NewGroup,
            WhitenoiseChatListUpdateTrigger::NewLastMessage => Self::NewLastMessage,
            WhitenoiseChatListUpdateTrigger::LastMessageDeleted => Self::LastMessageDeleted,
        }
    }
}

/// A real-time update for the chat list.
///
/// Contains the trigger indicating what changed and the complete,
/// current state of the affected chat item.
#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct ChatListUpdate {
    pub trigger: ChatListUpdateTrigger,
    pub item: ChatSummary,
}

impl From<WhitenoiseChatListUpdate> for ChatListUpdate {
    fn from(update: WhitenoiseChatListUpdate) -> Self {
        Self {
            trigger: update.trigger.into(),
            item: update.item.into(),
        }
    }
}

/// Stream item emitted by `subscribe_to_chat_list`.
///
/// The first item is always `InitialSnapshot` containing all current chats.
/// Subsequent items are `Update` containing real-time changes.
#[frb]
#[derive(Debug, Clone)]
pub enum ChatListStreamItem {
    /// Initial snapshot of all chats at subscription time
    InitialSnapshot { items: Vec<ChatSummary> },
    /// Real-time update for a single chat
    Update { update: ChatListUpdate },
}

/// Retrieves the chat list for an account.
///
/// Returns a list of chat summaries sorted by last activity (most recent first).
/// Groups without messages are sorted by creation date.
#[frb]
pub async fn get_chat_list(account_pubkey: String) -> Result<Vec<ChatSummary>, ApiError> {
    let whitenoise = Whitenoise::get_instance()?;
    let pubkey = PublicKey::parse(&account_pubkey)?;
    let account = whitenoise.find_account_by_pubkey(&pubkey).await?;
    let chat_list = whitenoise.get_chat_list(&account).await?;
    Ok(chat_list.into_iter().map(|item| item.into()).collect())
}

/// Subscribe to real-time chat list updates for an account.
///
/// The stream first emits an `InitialSnapshot` containing all current chats,
/// then emits `Update` items as chats are created, receive new messages, or have messages deleted.
///
/// The initial snapshot is race-condition free: any updates that arrive between
/// subscribing and fetching are merged into the snapshot.
#[frb]
pub async fn subscribe_to_chat_list(
    account_pubkey: String,
    sink: StreamSink<ChatListStreamItem>,
) -> Result<(), ApiError> {
    let whitenoise = Whitenoise::get_instance()?;
    let pubkey = PublicKey::parse(&account_pubkey)?;
    let account = whitenoise.find_account_by_pubkey(&pubkey).await?;

    let subscription = whitenoise.subscribe_to_chat_list(&account).await?;

    // Emit initial snapshot first
    let initial_items: Vec<ChatSummary> = subscription
        .initial_items
        .into_iter()
        .map(|item| item.into())
        .collect();

    if sink
        .add(ChatListStreamItem::InitialSnapshot {
            items: initial_items,
        })
        .is_err()
    {
        return Ok(()); // Sink closed, exit gracefully
    }

    // Stream real-time updates
    let mut rx = subscription.updates;
    loop {
        match rx.recv().await {
            Ok(update) => {
                let item = ChatListStreamItem::Update {
                    update: update.into(),
                };
                if sink.add(item).is_err() {
                    break; // Sink closed
                }
            }
            Err(tokio::sync::broadcast::error::RecvError::Lagged(_)) => {
                // Slow consumer missed some updates - safe to continue since
                // each update contains the complete chat item state
                continue;
            }
            Err(tokio::sync::broadcast::error::RecvError::Closed) => {
                break; // Channel closed
            }
        }
    }

    Ok(())
}

// ============================================================================
// Tests
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_chat_list_update_trigger_conversion_new_group() {
        let trigger: ChatListUpdateTrigger = WhitenoiseChatListUpdateTrigger::NewGroup.into();
        assert_eq!(trigger, ChatListUpdateTrigger::NewGroup);
    }

    #[test]
    fn test_chat_list_update_trigger_conversion_new_last_message() {
        let trigger: ChatListUpdateTrigger = WhitenoiseChatListUpdateTrigger::NewLastMessage.into();
        assert_eq!(trigger, ChatListUpdateTrigger::NewLastMessage);
    }

    #[test]
    fn test_chat_list_update_trigger_conversion_last_message_deleted() {
        let trigger: ChatListUpdateTrigger =
            WhitenoiseChatListUpdateTrigger::LastMessageDeleted.into();
        assert_eq!(trigger, ChatListUpdateTrigger::LastMessageDeleted);
    }
}
