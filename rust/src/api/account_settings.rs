use crate::api::error::ApiError;
use chrono::{DateTime, Utc};
use flutter_rust_bridge::frb;
use nostr_sdk::PublicKey;
use whitenoise::{AccountSettings as WhitenoiseAccountSettings, Whitenoise};

/// Per-account settings exposed to Flutter.
#[frb(non_opaque)]
#[derive(Debug, Clone)]
pub struct AccountSettings {
    pub notifications_enabled: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl From<WhitenoiseAccountSettings> for AccountSettings {
    fn from(settings: WhitenoiseAccountSettings) -> Self {
        Self {
            notifications_enabled: settings.notifications_enabled,
            created_at: settings.created_at,
            updated_at: settings.updated_at,
        }
    }
}

#[frb]
pub async fn get_account_settings(pubkey: String) -> Result<AccountSettings, ApiError> {
    let whitenoise = Whitenoise::get_instance()?;
    let pubkey = PublicKey::parse(&pubkey)?;
    let account = whitenoise.find_account_by_pubkey(&pubkey).await?;
    let settings = whitenoise.account_settings(&account).await?;
    Ok(settings.into())
}

#[frb]
pub async fn update_notifications_enabled(
    pubkey: String,
    enabled: bool,
) -> Result<AccountSettings, ApiError> {
    let whitenoise = Whitenoise::get_instance()?;
    let pubkey = PublicKey::parse(&pubkey)?;
    let account = whitenoise.find_account_by_pubkey(&pubkey).await?;
    let settings = whitenoise
        .update_notifications_enabled(&account, enabled)
        .await?;
    Ok(settings.into())
}
