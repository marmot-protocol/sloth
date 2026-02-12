# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Theme setup [PR #1](https://github.com/marmot-protocol/sloth/pull/1)
- CI github action [PR #2](https://github.com/marmot-protocol/sloth/pull/2)
- Dependabot action [PR #3](https://github.com/marmot-protocol/sloth/pull/3)
- Base components [PR #4](https://github.com/marmot-protocol/sloth/pull/4)
- Coverage CI check [PR #5](https://github.com/marmot-protocol/sloth/pull/5)
- Auth, routing and main screens [PR #6](https://github.com/marmot-protocol/sloth/pull/6)
- Developer settings screen  [PR #8](https://github.com/marmot-protocol/sloth/pull/8)
- Chat screen with streams [PR #12](https://github.com/marmot-protocol/sloth/pull/12)
- Show chats in chat list screen and messages in chat invite screen [PR #15](https://github.com/marmot-protocol/sloth/pull/15)
- Profile (keys, edit, share) screens [PR #22](https://github.com/marmot-protocol/sloth/pull/22)
- Send messages [PR #33](https://github.com/marmot-protocol/sloth/pull/33)
- Network relays screen [PR #43](https://github.com/marmot-protocol/sloth/pull/43)
- Search user by npub [PR #39](https://github.com/marmot-protocol/sloth/pull/39)
- Delete messages [PR #49](https://github.com/marmot-protocol/sloth/pull/49)
- Paste nsec login [PR #59](https://github.com/marmot-protocol/sloth/pull/59)
- Reactions [PR #60](https://github.com/marmot-protocol/sloth/pull/60)
- Add multi-account support [PR #78](https://github.com/marmot-protocol/sloth/pull/78)
- Emoji picker for reactions [PR #81](https://github.com/marmot-protocol/sloth/pull/81)
- Setup Widgetbook [PR #82](https://github.com/marmot-protocol/sloth/pull/82)
- Delete reactions [PR #95](https://github.com/marmot-protocol/sloth/pull/95)
- Add start chat and chat info screens with follow/unfollow [PR #96](https://github.com/marmot-protocol/sloth/pull/96)
- Avatar colors [PR #108](https://github.com/marmot-protocol/sloth/pull/108), [PR #137](https://github.com/marmot-protocol/sloth/pull/137)
- Scan QR for nsec [PR #164](https://github.com/marmot-protocol/sloth/pull/164)
- Copy card [PR #157](https://github.com/marmot-protocol/sloth/pull/157)
- Scan QR for npub [PR #175](https://github.com/marmot-protocol/sloth/pull/175)
- Android signer (NIP-55) support [PR #48](https://github.com/marmot-protocol/sloth/pull/48)
<<<<<<< delete-all-data
- Delete all data [PR #225](https://github.com/marmot-protocol/whitenoise/pull/225)
=======
- Replies [PR #179](https://github.com/marmot-protocol/whitenoise/pull/179)
- Replies scroll [PR #202](https://github.com/marmot-protocol/whitenoise/pull/202)
>>>>>>> master

### Changed

- Replace all snackbars with system notice [PR #168](https://github.com/marmot-protocol/sloth/pull/168)
- Use large size for login and signup buttons [PR #165](https://github.com/marmot-protocol/sloth/pull/165)
- Change hooks that received refs to receive data [PR #27](https://github.com/marmot-protocol/sloth/pull/27)
- Update chat list using streams [PR #36](https://github.com/marmot-protocol/sloth/pull/36)
- Use Rust as source of truth for locale settings, properly persist "System" language preference [PR #109](https://github.com/marmot-protocol/sloth/pull/109)
- Implement isFollowingUser method [PR #132](https://github.com/marmot-protocol/sloth/pull/132)
- Npub formatting [PR #157](https://github.com/marmot-protocol/sloth/pull/157)
- Migrate to whitenoise app bundle id [PR #163](https://github.com/marmot-protocol/sloth/pull/163)

### Deprecated

### Removed

### Fixed

- Adds internet permission in android manifest [PR #7](https://github.com/marmot-protocol/sloth/pull/7)
- Fixes logout not working after app reinstall [PR #31](https://github.com/marmot-protocol/sloth/pull/31)
- Fixes sign out exception and adds dedicated sign out screen with private key backup [PR #45](https://github.com/marmot-protocol/sloth/pull/45)
- QR code color now uses theme-aware color [PR #183](https://github.com/marmot-protocol/sloth/pull/183)
- DM avatar color inconsistency [PR #199](https://github.com/marmot-protocol/sloth/pull/199)

### Security
