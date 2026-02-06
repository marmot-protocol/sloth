# White Noise

A secure, private, and decentralized chat app using the [marmot protocol 🦫](https://github.com/marmot-protocol/marmot) to build secure messaging with MLS and Nostr

## 📱 Supported Platforms

- ✅ **Android** - Fully supported
- ✅ **iOS** - Fully supported
- ⏳ **macOS** - Not supported yet
- ⏳ **Windows** - Not supported yet
- ⏳ **Linux** - Not supported yet
- ⏳ **Web** - Not supported yet

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


## Development philosophy
- We keep complexity low.
- We keep the app thin.
- We test our code.
- We delete dead code. Commented code is dead code.
- We use the Whitenoise Rust crate as the source of truth.
- We avoid caching in Flutter; the Whitenoise crate already persists data in a local DB.
- We put shared app state in providers.
- We put ephemeral widget state in hooks.
- We pass data to hooks, not widget refs.
- We let screens watch providers and pass data to hooks.
- We avoid comments unless strictly necessary and write self-explanatory code.

## 📚 Resources
- [Flutter Docs](https://docs.flutter.dev/)
- [White Noise Rust crate](https://github.com/marmot-protocol/whitenoise-rs)
- [White Noise Flutter](https://github.com/marmot-protocol/whitenoise)
