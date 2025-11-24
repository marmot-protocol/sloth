# Sloth 🦥

A playground app for experimenting the whitenoise crate, using [WhiteNoise Flutter repo](https://github.com/marmot-protocol/whitenoise) as reference.
 
## 🏗️ Stack

- **Flutter** - Cross-platform UI framework
- **Rust** - "Backend" logic via the whitenoise crate
- **flutter_rust_bridge** - Dart ↔ Rust integration
- **whitenoise crate** - Secure messaging with MLS and Nostr protocols


### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24.x or later)
- [Rust](https://rustup.rs/) (latest stable)
- [Just](https://github.com/casey/just) - `cargo install just`
- flutter_rust_bridge_codegen - `cargo install flutter_rust_bridge_codegen`


## 🛠️ Commands
```bash
# Install dependencies
just deps              # Install both Flutter and Rust deps
just deps-flutter      # Flutter dependencies only
just deps-rust         # Rust dependencies only
```
## 📚 Resources

- [Flutter Docs](https://docs.flutter.dev/)
- [White Noise Rust crate](https://github.com/marmot-protocol/whitenoise-rs)
- [White Noise Flutter](https://github.com/marmot-protocol/whitenoise)
