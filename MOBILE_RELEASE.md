# Mobile release checklist

## Billing and policy boundary

The iOS and Android builds are consumption-only. They do not show Chapa checkout buttons, payment URLs, or instructions for bypassing store billing. A user signs in with the same Firebase-backed account used on the web, and the API decides whether that account has premium or purchased-content access.

This is appropriate only if the store submission is treated as a reader/media app that lets users access content purchased elsewhere. If the app starts selling digital subscriptions or individual digital books/audio inside the app, implement Apple In-App Purchase and Google Play Billing instead; do not reuse the Chapa web checkout in those builds. Store policy and regional availability must be rechecked during submission because Apple and Google can change storefront rules.

## Required configuration

1. Set `API_BASE_URL` to the cPanel API, including `/api`.
2. Configure the backend `PAYMENT_RETURN_URL` to the production website payment-result route.
3. Replace the placeholder Android application ID and iOS bundle identifier with identifiers owned by your developer accounts.
4. Confirm Firebase has Android and iOS apps registered for those exact identifiers and replace the generated Firebase config files if needed.
5. Configure production Chapa credentials, MongoDB, Cloudinary, Firebase Admin credentials, CORS origins, and HTTPS on cPanel. Never commit `.env` or service-account JSON.

## Cloud iOS build and signing

You do not need a Mac locally. Codemagic can build on a hosted macOS runner. Create an Apple Developer Program membership, an App Store Connect app record, and an App Store Connect API key. Add the key, issuer ID, and key ID to Codemagic, then let Codemagic manage the distribution certificate and provisioning profile for the registered bundle ID. For a manual setup, upload a distribution certificate and App Store provisioning profile instead.

For Google Play, create a Play Console app, generate an upload keystore, store it as a protected Codemagic variable/secure file, and enable Play App Signing. Do not use the current debug signing configuration for a release artifact.

## Validation before claiming store readiness

- Run `flutter analyze` and `flutter test` on CI.
- Test registration, email verification, login, logout, profile updates, subscription refresh, library access, offline book reading, offline audio playback, expired entitlements, and network failures on real Android and iOS devices.
- Verify Chapa web checkout, callback verification, duplicate callback idempotency, amount checks, and account-to-purchase association against production-like data.
- Complete App Store review metadata, privacy disclosures, age rating, account-deletion behavior, screenshots, and Google Play Data safety declarations.
- Submit only after a signed Android App Bundle and signed iOS IPA have passed the platform test tracks/TestFlight review. This repository is not store-ready until those external signing and submission checks pass.
