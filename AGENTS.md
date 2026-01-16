# AGENTS.md

## Project Overview

Sloth is a playground messaging app for experimenting with the [whitenoise Rust crate](https://github.com/marmot-protocol/whitenoise-rs), which implements secure messaging using the [Marmot Protocol](https://github.com/marmot-protocol/marmot) with MLS (Messaging Layer Security) and Nostr.

**Why "Sloth"?** Sloths are slow but efficient, and you can find them in Costa Rica.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter UI Layer                         │
│  (screens/, widgets/, hooks/, providers/)                   │
├─────────────────────────────────────────────────────────────┤
│              Flutter-Rust Bridge Layer                      │
│  (lib/src/rust/ - auto-generated bindings)                  │
├─────────────────────────────────────────────────────────────┤
│                    Rust API Layer                           │
│  (rust/src/api/ - thin wrapper around whitenoise)           │
├─────────────────────────────────────────────────────────────┤
│                Whitenoise Rust Crate                        │
│  (external dependency - core messaging logic)               │
└─────────────────────────────────────────────────────────────┘
```

## Tech Stack

- **Flutter/Dart** - UI and application logic
- **Rust** - Core messaging/crypto functionality via FFI
- **flutter_rust_bridge** - Dart-Rust FFI bindings
- **Riverpod** - State management (shared state)
- **flutter_hooks** - Ephemeral widget state
- **go_router** - Navigation/routing

## Git Worktrees

**IMPORTANT:** When starting work on a new feature, bug fix, or issue, use the `/create-git-worktree` command to create an isolated development environment.

```
/create-git-worktree <branch-name>
```

This creates a worktree in the `trees/` directory at the repository root. Worktrees allow parallel development without affecting the main working directory.

Example: `/create-git-worktree issue-42-fix-login`

After running, you'll be working in `trees/issue-42-fix-login/` on that branch.

## Directory Structure

```
sloth/
├── lib/                    # Flutter/Dart source code
│   ├── main.dart           # App entry point
│   ├── routes.dart         # Route definitions (go_router)
│   ├── theme.dart          # Theme colors and styles
│   ├── providers/          # Riverpod providers (shared state)
│   ├── hooks/              # Flutter hooks (ephemeral state)
│   ├── screens/            # Full-page UI components
│   ├── widgets/            # Reusable components (prefixed wn_)
│   ├── services/           # Stateless operations (API calls)
│   ├── extensions/         # Dart extensions
│   ├── utils/              # Utility functions
│   └── src/rust/           # Auto-generated Rust bridge code (DO NOT EDIT)
├── rust/                   # Rust source code
│   └── src/api/            # API modules exposed to Flutter
├── test/                   # Flutter tests (mirrors lib/ structure)
├── trees/                  # Git worktrees for parallel development
├── assets/                 # Images, SVGs, fonts
└── scripts/                # Build/CI scripts
```

## Setup Commands

```bash
# Install all dependencies
just deps

# Install Flutter dependencies only
just deps-flutter

# Install Rust dependencies only
just deps-rust
```

## Development Commands

```bash
# Format all code (Rust + Dart)
just format

# Lint all code
just lint

# Run all tests
just test-flutter
just test-rust

# Run tests with coverage (80% minimum)
just coverage

# Generate coverage HTML report
just coverage-report

# Pre-commit checks (run before submitting PRs)
just precommit

# Regenerate flutter_rust_bridge code
just generate
```

## Code Style

### Dart/Flutter

- Single quotes for strings
- `prefer_const_constructors` enabled
- `prefer_final_locals` enabled
- Line width: 100 characters
- Trailing commas: preserve

### Widget Naming

- Reusable widgets prefixed with `wn_` (e.g., `wn_filled_button.dart`)
- Widget class names use `Wn` prefix (e.g., `WnFilledButton`)

### Hook Naming

- Hook files prefixed with `use_` (e.g., `use_chat_list.dart`)
- Hook functions start with `use` (e.g., `useChatList()`)

### Provider Naming

- Files end with `_provider.dart`
- Provider variables end with `Provider` (e.g., `authProvider`)

## Testing

- Test files mirror source structure with `_test.dart` suffix
- Minimum coverage requirement: 80%
- Use helpers from `test/test_helpers.dart`:
  - `setUpTestView(tester)` - Configure test view dimensions
  - `mountTestApp(tester, overrides)` - Mount full app with provider overrides
  - `mountHook(tester, useHook)` - Test individual hooks
  - `mountWidget(child, tester)` - Mount single widget
  - `mountStackedWidget(child, tester)` - Mount widget in Stack
- Mock Rust API using `RustLib.initMock(api: mockApi)`

## Sloth Mode Philosophy

Follow these principles when writing code:

1. **Simplicity over complexity** - Keep the app thin
2. **Test all code** - No untested code
3. **No dead code** - Delete commented/unused code
4. **Whitenoise is source of truth** - Don't duplicate logic from the Rust crate
5. **No caching in Flutter** - Whitenoise persists data in local DB
6. **Shared state in providers** - Use Riverpod for app-wide state
7. **Ephemeral state in hooks** - Use flutter_hooks for widget-local state
8. **Pass data to hooks, not refs** - Hooks receive data, not widget references
9. **Screens watch providers** - Screens observe providers and pass data to hooks
10. **Self-explanatory code** - Avoid comments; write clear, readable code

## State Management Pattern

```
Screen (watches providers)
    │
    ├── Providers (shared/persistent state)
    │   └── Auth, account pubkey, etc.
    │
    └── Hooks (ephemeral/local state)
        └── Chat list, messages, form inputs, etc.
```

## Rust API Guidelines

- Modules in `rust/src/api/` are exposed to Flutter
- Functions use `#[frb]` attribute for bridge generation
- Structs use `#[frb(non_opaque)]` for Flutter compatibility
- Errors wrapped in `ApiError` enum using `thiserror`
- Files in `lib/src/rust/` are auto-generated - DO NOT EDIT manually

## PR Checklist

1. Run `just precommit` before submitting
2. Ensure all tests pass
3. Coverage meets 80% minimum
4. Update `CHANGELOG.md` for user-facing changes
5. Follow existing code patterns and naming conventions
