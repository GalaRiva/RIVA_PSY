# Apple Root CA - G3

`AppleRootCA-G3.cer` is Apple's own published root certificate (DER-encoded),
downloaded from https://www.apple.com/certificateauthority/AppleRootCA-G3.cer
on 2026-09-08. This is the root that App Store Server Notifications'
signing certificate chain leads back to — `SignedDataVerifier` in
`../index.js` uses it to confirm a notification actually came from Apple.

Valid until 2039-04-30 — nothing to rotate for a long time. If it ever needs
refreshing, re-download from the same Apple PKI page (Apple Root Certificates
section) and replace this file; no code changes needed.
