# Sloth 🦥

A playground messaging app for experimenting with the [whitenoise rust crate 🦀](https://github.com/marmot-protocol/whitenoise-rs), which uses the [marmot protocol 🦫](https://github.com/marmot-protocol/marmot) to build secure messaging with MLS and Nostr


**Why sloth?**
Cause sloths are slow but efficient, and you can find them in Costa Rica 🤙


## 🏗️ Stack
- [Flutter](https://docs.flutter.dev/)
- Rust
- flutter_rust_bridge - Dart ↔ Rust integration
- [whitenoise rust crate 🦀](https://github.com/marmot-protocol/whitenoise-rs)

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
