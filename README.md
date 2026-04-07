# Chanced Pigeon

A SwiftUI iOS game launcher inspired by GamePigeon, with a playable mini-golf game and a GitHub Actions workflow to build a sideloadable IPA.

## What is included

- Native iOS SwiftUI app
- Game selection UI with a mini-golf experience
- GitHub Actions workflow that generates an Xcode project and exports an IPA

## Build on GitHub Actions

This repository is configured to build on `macos-latest` using `xcodegen` and `xcodebuild`.

### Required repository secrets

- `APPLE_TEAM_ID` — your Apple Developer team ID
- `P12_BASE64` — base64-encoded Apple Development `.p12` signing certificate
- `P12_PASSWORD` — password for your `.p12` certificate
- `PROVISIONING_PROFILE_BASE64` — base64-encoded provisioning profile matching the app bundle ID
- `PROVISIONING_PROFILE_SPECIFIER` — the name of the provisioning profile

### How to run

1. Push the repository to GitHub.
2. Add the required secrets in `Settings > Secrets and variables > Actions`.
3. Trigger the workflow manually via the `Build IPA` workflow or push to `main`.
4. Download the generated `GamePigeonClone.ipa` artifact.

> Note: This workflow requires Apple signing assets and a valid provisioning profile. It cannot generate a signed IPA without those credentials.
