use crate::api::error::ApiError;
use crate::api::utils::group_id_to_string;
use crate::frb_generated::StreamSink;
use chrono::{DateTime, Utc};
use flutter_rust_bridge::frb;
use whitenoise::Whitenoise;
use whitenoise::whitenoise::notification_streaming::{
    NotificationTrigger as WhitenoiseNotificationTrigger,
    NotificationUpdate as WhitenoiseNotificationUpdate,
    NotificationUser as WhitenoiseNotificationUser,
};

#[frb]
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum NotificationTrigger {
    NewMessage,
    GroupInvite,
}

impl From<WhitenoiseNotificationTrigger> for NotificationTrigger {
    fn from(trigger: WhitenoiseNotificationTrigger) -> Self {
        match trigger {
            WhitenoiseNotificationTrigger::NewMessage => Self::NewMessage,
            WhitenoiseNotificationTrigger::GroupInvite => Self::GroupInvite,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct NotificationUser {
    pub pubkey: String,
    pub display_name: Option<String>,
    pub picture_url: Option<String>,
}

impl From<WhitenoiseNotificationUser> for NotificationUser {
    fn from(user: WhitenoiseNotificationUser) -> Self {
        Self {
            pubkey: user.pubkey.to_hex(),
            display_name: user.display_name,
            picture_url: user.picture_url,
        }
    }
}

#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct NotificationUpdate {
    pub trigger: NotificationTrigger,
    pub mls_group_id: String,
    pub group_name: Option<String>,
    pub is_dm: bool,
    pub receiver: NotificationUser,
    pub sender: NotificationUser,
    pub content: String,
    pub timestamp: DateTime<Utc>,
}

impl From<WhitenoiseNotificationUpdate> for NotificationUpdate {
    fn from(update: WhitenoiseNotificationUpdate) -> Self {
        Self {
            trigger: update.trigger.into(),
            mls_group_id: group_id_to_string(&update.mls_group_id),
            group_name: update.group_name,
            is_dm: update.is_dm,
            receiver: update.receiver.into(),
            sender: update.sender.into(),
            content: update.content,
            timestamp: update.timestamp,
        }
    }
}

#[frb]
pub async fn subscribe_to_notifications(
    sink: StreamSink<NotificationUpdate>,
) -> Result<(), ApiError> {
    let whitenoise = Whitenoise::get_instance()?;
    let subscription = whitenoise.subscribe_to_notifications();
    let mut rx = subscription.updates;

    loop {
        match rx.recv().await {
            Ok(update) => {
                let item: NotificationUpdate = update.into();
                if sink.add(item).is_err() {
                    break; // Sink closed
                }
            }
            Err(tokio::sync::broadcast::error::RecvError::Lagged(_)) => {
                continue;
            }
            Err(tokio::sync::broadcast::error::RecvError::Closed) => {
                break;
            }
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_notification_trigger_conversion_new_message() {
        let trigger: NotificationTrigger = WhitenoiseNotificationTrigger::NewMessage.into();
        assert_eq!(trigger, NotificationTrigger::NewMessage);
    }

    #[test]
    fn test_notification_trigger_conversion_group_invite() {
        let trigger: NotificationTrigger = WhitenoiseNotificationTrigger::GroupInvite.into();
        assert_eq!(trigger, NotificationTrigger::GroupInvite);
    }
}
