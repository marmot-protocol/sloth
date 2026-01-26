//! External signer support for NIP-55 (Amber) integration.
//!
//! This module provides a bridge between Rust's `NostrSigner` trait and
//! Flutter/Dart callbacks, allowing external signers like Amber to be used
//! for signing Nostr events.

use flutter_rust_bridge::DartFnFuture;
use flutter_rust_bridge::frb;
use nostr_sdk::prelude::*;
use std::borrow::Cow;
use std::fmt::Debug;
use std::sync::Arc;

use crate::api::error::ApiError;

/// An external signer that delegates signing operations to Dart callbacks.
///
/// This struct implements the `NostrSigner` trait by calling back into Dart
/// for all cryptographic operations. This allows external signers like Amber
/// (NIP-55) to be used without the private key ever touching the Rust code.
#[derive(Clone)]
pub struct DartSigner {
    pubkey: PublicKey,
    sign_event: Arc<dyn Fn(String) -> DartFnFuture<String> + Send + Sync>,
    nip04_encrypt: Arc<dyn Fn(String, String) -> DartFnFuture<String> + Send + Sync>,
    nip04_decrypt: Arc<dyn Fn(String, String) -> DartFnFuture<String> + Send + Sync>,
    nip44_encrypt: Arc<dyn Fn(String, String) -> DartFnFuture<String> + Send + Sync>,
    nip44_decrypt: Arc<dyn Fn(String, String) -> DartFnFuture<String> + Send + Sync>,
}

impl Debug for DartSigner {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("DartSigner")
            .field("pubkey", &self.pubkey)
            .finish()
    }
}

impl DartSigner {
    /// Creates a new DartSigner with the given callbacks.
    pub fn new(
        pubkey: PublicKey,
        sign_event: impl Fn(String) -> DartFnFuture<String> + Send + Sync + 'static,
        nip04_encrypt: impl Fn(String, String) -> DartFnFuture<String> + Send + Sync + 'static,
        nip04_decrypt: impl Fn(String, String) -> DartFnFuture<String> + Send + Sync + 'static,
        nip44_encrypt: impl Fn(String, String) -> DartFnFuture<String> + Send + Sync + 'static,
        nip44_decrypt: impl Fn(String, String) -> DartFnFuture<String> + Send + Sync + 'static,
    ) -> Self {
        Self {
            pubkey,
            sign_event: Arc::new(sign_event),
            nip04_encrypt: Arc::new(nip04_encrypt),
            nip04_decrypt: Arc::new(nip04_decrypt),
            nip44_encrypt: Arc::new(nip44_encrypt),
            nip44_decrypt: Arc::new(nip44_decrypt),
        }
    }
}

impl NostrSigner for DartSigner {
    fn backend(&self) -> SignerBackend<'_> {
        SignerBackend::Custom(Cow::Borrowed("DartSigner (NIP-55/Amber)"))
    }

    fn get_public_key(&self) -> BoxedFuture<'_, Result<PublicKey, SignerError>> {
        Box::pin(async move { Ok(self.pubkey) })
    }

    fn sign_event(&self, unsigned: UnsignedEvent) -> BoxedFuture<'_, Result<Event, SignerError>> {
        let sign_fn = self.sign_event.clone();
        Box::pin(async move {
            // Serialize the unsigned event to JSON
            let unsigned_json = serde_json::to_string(&unsigned).map_err(SignerError::backend)?;

            // Call the Dart callback to sign
            let signed_json = sign_fn(unsigned_json).await;

            // Parse the signed event
            let event: Event = serde_json::from_str(&signed_json).map_err(SignerError::backend)?;

            Ok(event)
        })
    }

    fn nip04_encrypt<'a>(
        &'a self,
        public_key: &'a PublicKey,
        content: &'a str,
    ) -> BoxedFuture<'a, Result<String, SignerError>> {
        let encrypt_fn = self.nip04_encrypt.clone();
        let pubkey_hex = public_key.to_hex();
        let content_owned = content.to_owned();
        Box::pin(async move {
            let result = encrypt_fn(content_owned, pubkey_hex).await;
            Ok(result)
        })
    }

    fn nip04_decrypt<'a>(
        &'a self,
        public_key: &'a PublicKey,
        encrypted_content: &'a str,
    ) -> BoxedFuture<'a, Result<String, SignerError>> {
        let decrypt_fn = self.nip04_decrypt.clone();
        let pubkey_hex = public_key.to_hex();
        let content_owned = encrypted_content.to_owned();
        Box::pin(async move {
            let result = decrypt_fn(content_owned, pubkey_hex).await;
            Ok(result)
        })
    }

    fn nip44_encrypt<'a>(
        &'a self,
        public_key: &'a PublicKey,
        content: &'a str,
    ) -> BoxedFuture<'a, Result<String, SignerError>> {
        let encrypt_fn = self.nip44_encrypt.clone();
        let pubkey_hex = public_key.to_hex();
        let content_owned = content.to_owned();
        Box::pin(async move {
            let result = encrypt_fn(content_owned, pubkey_hex).await;
            Ok(result)
        })
    }

    fn nip44_decrypt<'a>(
        &'a self,
        public_key: &'a PublicKey,
        payload: &'a str,
    ) -> BoxedFuture<'a, Result<String, SignerError>> {
        let decrypt_fn = self.nip44_decrypt.clone();
        let pubkey_hex = public_key.to_hex();
        let payload_owned = payload.to_owned();
        Box::pin(async move {
            let result = decrypt_fn(payload_owned, pubkey_hex).await;
            Ok(result)
        })
    }
}

/// Login with an external signer (like Amber via NIP-55) and publish key package.
///
/// This function creates an account for the given public key and uses the provided
/// callbacks to sign the key package event, allowing the account to receive MLS
/// messages.
///
/// # Arguments
///
/// * `pubkey` - The user's public key (hex format) obtained from the external signer.
/// * `sign_event` - Callback to sign unsigned events. Takes unsigned event JSON, returns signed event JSON.
/// * `nip04_encrypt` - Callback for NIP-04 encryption. Takes (plaintext, recipient_pubkey), returns ciphertext.
/// * `nip04_decrypt` - Callback for NIP-04 decryption. Takes (ciphertext, sender_pubkey), returns plaintext.
/// * `nip44_encrypt` - Callback for NIP-44 encryption. Takes (plaintext, recipient_pubkey), returns ciphertext.
/// * `nip44_decrypt` - Callback for NIP-44 decryption. Takes (ciphertext, sender_pubkey), returns plaintext.
///
/// # TODO
///
/// This orchestration (login → register → publish) should ideally be moved into the
/// `whitenoise` crate as a single method to keep this API layer thin. The API layer
/// should only handle translation between Dart and Rust types, not business logic.
#[frb]
pub async fn login_with_external_signer_and_callbacks(
    pubkey: String,
    sign_event: impl Fn(String) -> DartFnFuture<String> + Send + Sync + 'static,
    nip04_encrypt: impl Fn(String, String) -> DartFnFuture<String> + Send + Sync + 'static,
    nip04_decrypt: impl Fn(String, String) -> DartFnFuture<String> + Send + Sync + 'static,
    nip44_encrypt: impl Fn(String, String) -> DartFnFuture<String> + Send + Sync + 'static,
    nip44_decrypt: impl Fn(String, String) -> DartFnFuture<String> + Send + Sync + 'static,
) -> Result<crate::api::accounts::Account, ApiError> {
    let whitenoise = whitenoise::Whitenoise::get_instance()?;
    let pubkey = PublicKey::parse(&pubkey)?;

    // Create the signer - DartSigner is Clone since it uses Arc internally
    let signer = DartSigner::new(
        pubkey,
        sign_event,
        nip04_encrypt,
        nip04_decrypt,
        nip44_encrypt,
        nip44_decrypt,
    );

    // Login with the external signer (this creates the account without publishing)
    let account = whitenoise.login_with_external_signer(pubkey).await?;

    // Register a clone of the signer for ongoing use (e.g., giftwrap decryption)
    whitenoise.register_external_signer(pubkey, signer.clone());

    // Now publish the key package using our Dart signer
    // This requires the signer to sign the key package event
    whitenoise
        .publish_key_package_for_account_with_signer(&account, signer)
        .await?;

    Ok(account.into())
}
