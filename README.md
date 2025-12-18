# Sloth 🦥

A playground messaging app for experimenting with the [whitenoise rust crate 🦀](https://github.com/marmot-protocol/whitenoise-rs), which uses the [marmot protocol 🦫](https://github.com/marmot-protocol/marmot) to build secure messaging with MLS and Nostr


**Why sloth?**
Cause sloths are slow but efficient, and you can find them in Costa Rica 🤙

## Structure

```
lib/
├── providers/     # Shared state
├── hooks/         # Ephemeral widget state
├── services/      # Stateless operations (API calls)
├── screens/       # Full-page components
├── widgets/       # Reusable components
```



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

# Format code
just format            # Format both Rust and Dart
just format-rust       # Format Rust only
just format-dart       # Format Dart only

# Coverage
just coverage          # Checks tests coverage
```

### Coverage Report

You need to install lcov to generate report
```bash
# Mac OS
brew install lcov

# Linux
apt-get install lcov
```

```bash
# First run tests with coverage option
flutter test --coverage
# Generate coverage html report
genhtml coverage/lcov.info -o coverage/html 
# Open coverage/html/index.html in your browser
```


## Sloth mode 🦥
- Sloths know complexity is bad, very bad.
- Sloths work hard to keep this app thin. 
- Sloths test their code.
- Sloths delete dead code. Commented code is dead code.
- Sloths use the White Noise Rust crate 🦀 as the source of truth.
- Sloths avoid caching in flutter side. Sloths remember that White Noise crate already persists data in a local DB.
- Sloths put shared app state in providers.
- Sloths put ephemeral widget state in hooks.
- Sloths don't add code comments unless strictly necessary. Instead, they make big effort on writing code that is self-explanatory.

## 📚 Resources
- [Flutter Docs](https://docs.flutter.dev/)
- [White Noise Rust crate](https://github.com/marmot-protocol/whitenoise-rs)
- [White Noise Flutter](https://github.com/marmot-protocol/whitenoise)
