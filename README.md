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

> Note: A signed IPA requires valid Apple signing assets. Without a certificate and provisioning profile, GitHub Actions cannot create a sideloadable IPA.

## Unsigned build without certificate

If signing secrets are not provided, the workflow now builds an unsigned App bundle and packages it into `GamePigeonClone-unsigned.ipa`. You can download that artifact and sign it later on a Mac or with a signing tool.

> Note: `AltStore` and other installers typically require a properly signed IPA. An unsigned IPA may still appear invalid for install until it is signed.
### How to run

1. Push the repository to GitHub.
2. Add the required secrets in `Settings > Secrets and variables > Actions`.
3. Trigger the workflow manually via the `Build IPA` workflow or push to `main`.
4. Download the generated `GamePigeonClone.ipa` artifact.

> Note: This workflow requires Apple signing assets and a valid provisioning profile. It cannot generate a signed IPA without those credentials.
